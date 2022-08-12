class   Api::ApiController < Api::ApplicationController
    before_action :authenticate_user!
    
    def index 
        accounts = Account.all
        render json: accounts
    end
    
    def show
        # byebug
        id = params[:id].to_i
        @user = User.find(id)

        render json:  {
            "user": @user,
            "account": @user.accounts
        }
        
    end

    def loan_details
        id = params[:id].to_i
        @user = User.find(id)
        @loan_account = @user.accounts.where(account_type: "Loan Account")

        if @loan_account.count!=0
            render json: {
                "loan_account": @loan_account.first.loans 
            }
        else
            render json: {
                "alert": "You have not any loan account"
            }
        end
    end

    def create 
        id  = params[:id].to_i 
        @user = User.find(id)
        if ((params[:account_type] == 'Saving Account' && params[:amount].to_i < 10000) || (params[:account_type] == 'Current Account' && params[:amount].to_i < 100000))
            render json: {
                "alert": "Please deposit minimum account"
            }
        elsif params[:account_type] == 'Current Account' && ((Time.now.to_date -  @user.dob.to_date).to_i/365) < 18
            render json: {
                "alert": "Minimum age for Current account is 18"
            }
        else
            @account = Account.create(user_id: @user.id, type_of_account: params[:account_type], branch_id: (params[:branch_id]).to_i,amount: (params[:amount]).to_f, number: rand(1111111..9999999))
            Transaction.create(medium_of_transaction: "direct", credit_debit: "credit",account_id: @account.id,amount: (params[:amount]).to_f)
            @atm = Atm.create(account_id: @account.id,expiry_date: DateTime.now.next_year(5).to_date,cvv: rand(111..999),number: rand(1111111..9999999))
            render json: {
                "notice": "Your account sucessfully opened"
            }
        end
    end 


    def transaction_history
        @account = Account.where(user_id: params[:user_id], account_type: params[:account_type])
        
        if @account.count != 0
            render json: {
                "transactions": @account.first.transactions
            }
        else
            render json: {
                "alert": "You have entered wrong account"
            }
        end

    end

    
    def direct_withdraw
        @account = Account.where(params[:account_number])
        if @account.count!=0
            if  params[:amount].to_f < 0
                message_and_render("alert","Wrong Amount")
            elsif (@account.first.amount - params[:amount].to_f) < 0 
                render json: {
                    "alert": "Insufficient balance"
                }
            else
                @account.first.amount = @account.amount - params[:amount].to_f
                @account.save
                Transaction.create(type_of_transaction: "direct", medium: "debit",account_id: @account.id,amount: (params[:amount]).to_f)
                render json: {
                    "alert": "Insufficient balance"
                }
            end
        elsif
            render json: {
                "alert": "You have entered wrong account"
            }
        end
    end



    def deposit 
        @user = params[:user_id]
        if params[:account_type] == "Current Account"
            temp = params[:deposit_amount]
            deposit_amount = temp.to_f
            if (Account.where(user_id: @user.id, account_type: "Current Account")).count !=0 and deposit_amount>0
                @account = (Account.where(user_id: @user.id, account_type: "Current Account")).first
                Transaction.create(medium_of_transaction: "direct" , amount: deposit_amount , credit_debit: "credit", account_id: @account.id )
                @account.amount+=deposit_amount
                @account.save
                render json: {
                    "notice": "You have deposit the money"
                }
            elsif
                render json: {
                    "alert": "You have not Current Account"
                }
            end
        elsif params[:account_type] == "Saving Account"
            temp = params[:deposit_amount]
            deposit_amount = temp.to_f
            if (Account.where(user_id: @user.id, account_type: "Saving Account")).count !=0 and deposit_amount>0
                @account = (Account.where(user_id: @user.id, account_type: "Saving Account")).first
                Transaction.create(medium_of_transaction: "direct" , amount: deposit_amount , credit_debit: "credit", account_id: @account.id )
                @account.amount+=deposit_amount
                @account.save
                render json: {
                    "notice": "You have deposit the money"
                }
            elsif 
                render json: {
                    "alert": "You have not Saving Account"
                }  
            end
        end
    end



    def atm_withdraw
        @user = params[:user_id]
        @account = (Account.where(user_id: @user.id, account_type: "Saving Account")).first
        @atm  = Atm.where(account_id: @account.id).first

        if ( @user.first_name == params[:first_name] and @user.email == params[:email] and @atm.atm_card == params[:atm_card].to_i and @atm.cvv == (params[:cvv].to_i) and params[:withdrawal_amount].to_f>0)
            
            # @account = (Account.where(user_id: @user.id, account_type: "Saving Account")).first
            temp = params[:withdrawal_amount]
            withdrawal_amount = temp.to_f
            

            #total amount withdrawal in saving account in a day by a user
            total_amount_withdraw_in_a_day = 0

            if(Time.new.day<10)
                transaction = Transaction.where( "strftime('%d', created_at) = ?", "#{"0"+Time.new.day.to_s}")
                total_amount_withdraw_in_a_day =  transaction.where(account_id: @account.id, credit_debit: "debit").sum(:amount)
            elsif
                transaction = Transaction.where( "strftime('%d', created_at) = ?", "#{Time.new.day.to_s}")
                total_amount_withdraw_in_a_day =  transaction.where(account_id: @account.id, credit_debit: "debit").sum(:amount)
            end

            total_amount_withdraw_in_a_day+=withdrawal_amount

        
            #total number of withdrawal by atm in a month by a user
            number_of_transaction_by_atm_in_a_month = 0
            transaction_charge = 0
            if(Time.new.month<10)
                transaction = Transaction.where( "strftime('%m', created_at) = ?", "#{"0"+Time.new.month.to_s}")
                number_of_transaction_by_atm_in_a_month =  transaction.where(account_id: @account.id, credit_debit: "debit", medium_of_transaction: "atm").count
            elsif
                transaction = Transaction.where( "strftime('%m', created_at) = ?", "#{Time.new.month.to_s}")
                number_of_amount_withdraw_in_a_day =  transaction.where(account_id: @account.id, credit_debit: "debit", medium_of_transaction: "atm" ).count
            end
            
            if(number_of_transaction_by_atm_in_a_month>=5)
                transaction_charge = 500
            end


            if(withdrawal_amount<=20000 and  @account.amount >= (withdrawal_amount+transaction_charge) and total_amount_withdraw_in_a_day <=50000 ) 
                
                @account.with_lock do
                    @account.amount-=(withdrawal_amount+transaction_charge)
                    @account.save
                    Transaction.create(medium_of_transaction: "atm" , amount: withdrawal_amount , credit_debit: "debit", account_id: @account.id )
                    render json: {
                        "notice": "Succesfully Withdraw"
                    }
                end

            elsif
                render json: {
                    "alert": "No Sufficient balance or wrong amount"
                }
            end

        elsif
            render json: {
                "alert": "You have not Saving Account"
            }
        end
    end





    def create_loan_account
        
        @user = params[:user_id]

        # if user have already a loan account
        if Account.where(user_id: @user.id , account_type:"Loan Account").count!=0
            @account = Account.where(user_id: @user.id , account_type:"Loan Account").first
            
            #total_loan_amount
            required_loan_amount = params[:amount].to_f
            outstanding_loan_amount  = Loan.where(account_id: @account.id).sum(:principal).to_f
            total_loan_amount = required_loan_amount+outstanding_loan_amount
            
            #total_deposit_amount
            saving_amount = Account.where(user_id: @user.id , account_type: "Saving Account").first.amount.to_f
            current_amount = Account.where(user_id: @user.id , account_type: "Current Account").first.amount.to_f
            total_deposit_amount = saving_amount + current_amount

            loan_canbe_given = total_deposit_amount*0.4
            
            if (total_loan_amount<=loan_canbe_given and required_loan_amount>=500000 and params[:duration].to_i>=24)
                Transaction.create(medium_of_transaction: "direct" , amount: -1*required_loan_amount   , credit_debit: "#{params[:loan_type]} Taken", account_id: @account.id )
                principle = 0
                if(params[:loan_type]=="Home Loan") 
                    principle = required_loan_amount+required_loan_amount*(params[:duration].to_i/12)*0.07
                    #if user have already Home Loan Account
                    if @account.loans.where(loan_type: "Home Loan").count!=0
                        @home_loan = @account.loans.where(loan_type: "Home Loan").first
                        outstanding_home_loan_amount  = @home_loan.principal.to_f
                        principle += outstanding_home_loan_amount
                        @home_loan.principal = principle
                        @home_loan.save
                    elsif
                        Loan.create(loan_type: params[:loan_type], amount: params[:amount].to_f , duration: params[:duration].to_i , account_id: @account.id, principal: principle)
                    end
                    
                    render json: {
                        "notice": "Loan Approved"
                    }

                elsif (params[:loan_type]=="Car Loan")
                    
                    principle = required_loan_amount+required_loan_amount*(params[:duration].to_i/12)*0.08
                    #if user have already Car Loan Account
                    if @account.loans.where(loan_type: "Car Loan").count!=0
                        @home_loan = @account.loans.where(loan_type: "Car Loan").first
                        outstanding_home_loan_amount  = @home_loan.principal.to_f
                        principle += outstanding_home_loan_amount
                        @home_loan.principal = principle
                        @home_loan.save
                    elsif
                        Loan.create(loan_type: params[:loan_type], amount: params[:amount].to_f , duration: params[:duration].to_i , account_id: @account.id, principal: principle)
                    end

                    render json: {
                        "notice": "Loan Approved"
                    }

                elsif (params[:loan_type]=="Personal Loan")
                    
                    principle = required_loan_amount+required_loan_amount*(params[:duration].to_i/12)*0.12
                    #if user have already Car Loan Account
                    if @account.loans.where(loan_type: "Personal Loan").count!=0
                        @home_loan = @account.loans.where(loan_type: "Personal Loan").first
                        outstanding_home_loan_amount  = @home_loan.principal.to_f
                        principle += outstanding_home_loan_amount
                        @home_loan.principal = principle
                        @home_loan.save
                    elsif
                        Loan.create(loan_type: params[:loan_type], amount: params[:amount].to_f , duration: params[:duration].to_i , account_id: @account.id, principal: principle)
                    end
                    
                    render json: {
                        "notice": "Loan Approved"
                    }
                    
                elsif (params[:loan_type]=="Business Loan")
                    principle = required_loan_amount+required_loan_amount*(params[:duration].to_i/12)*0.15
                    #if user have already Car Loan Account
                    if @account.loans.where(loan_type: "Business Loan").count!=0
                        @home_loan = @account.loans.where(loan_type: "Business Loan").first
                        outstanding_home_loan_amount  = @home_loan.principal.to_f
                        principle += outstanding_home_loan_amount
                        @home_loan.principal = principle
                        @home_loan.save
                    elsif
                        Loan.create(loan_type: params[:loan_type], amount: params[:amount].to_f , duration: params[:duration].to_i , account_id: @account.id, principal: principle)
                    end
                    
                    render json: {
                        "notice": "Loan Approved"
                    }

                end

            else
                render json: {
                    "alert": "Sorry, You have not sufficient amount or sufficient criteria by bank to take loan"
                }
            end

        else
            
            required_loan_amount = params[:amount].to_f
            #total_deposit_account
            saving_amount = Account.where(user_id: @user.id , account_type: "Saving Account").first.amount.to_f
            current_amount = Account.where(user_id: @user.id , account_type: "Current Account").first.amount.to_f
            total_deposit_amount = saving_amount + current_amount

            loan_canbe_given = total_deposit_amount*0.4
            
            if (required_loan_amount <= loan_canbe_given and required_loan_amount >= 500000 and params[:duration].to_i >= 24)
                @account = Account.create(user_id: @user.id , account_number: rand(1111111..9999999) ,  account_type: "Loan Account" , branch_id: params[:branch].to_i )
                Transaction.create(medium_of_transaction: "direct" , amount: -1*required_loan_amount   , credit_debit: " #{params[:loan_type]} Taken", account_id: @account.id )
                principle = 0
                if(params[:loan_type]=="Home Loan") 
                    principle = required_loan_amount+required_loan_amount*(params[:duration].to_i/12)*0.07
                elsif (params[:loan_type]=="Car Loan")
                    principle = required_loan_amount+required_loan_amount*(params[:duration].to_i/12)*0.08
                elsif (params[:loan_type]=="Personal Loan")
                    principle = required_loan_amount+required_loan_amount*(params[:duration].to_i/12)*0.12
                elsif (params[:loan_type]=="Business Loan") 
                    principle = required_loan_amount+required_loan_amount*(params[:duration].to_i/12)*0.15
                end

                Loan.create(loan_type: params[:loan_type], amount: params[:amount].to_f , duration: params[:duration].to_i , account_id: @account.id ,principal: principle )
                render json: {
                    "notice": "Loan Approved"
                }
            else
                render json: {
                    "alert": "Sorry, You have not sufficient amount or sufficient criteria by bank to take loan"
                }
            end

        end

    end

   


    def loan_deposit
        @user = params[:user_id]
        
        #if user have no loan account
       if @user.accounts.where(account_type: "Loan Account").count==0
            render json: {
                "alert": "You have no loan account"
            }

        # Home loan deposit
        elsif params[:loan_type] == "Home Loan" 
           
           user = User.find(@user.id)
           deposit_amount = params[:amount].to_f
           
           #if user have Home loan account 
           if user.accounts.where(account_type: "Loan Account").first.loans.where(loan_type: "Home Loan").count!=0 and deposit_amount>0 

               loan =  user.accounts.where(account_type: "Loan Account").first.loans.find_by(loan_type: "Home Loan")
               @account = user.accounts.where(account_type: "Loan Account").first
               
               if loan.principal*0.1>=deposit_amount
                   remaining_loan =  loan.principal.to_d - deposit_amount    
                   loan.principal = remaining_loan
                   loan.save
                   Transaction.create(medium_of_transaction: "direct" , amount: deposit_amount   , credit_debit: " #{params[:loan_type]} Deposit", account_id: @account.id )
                   render json: {
                        "notice": "Loan Deposited"
                    }
               elsif
                    render json: {
                        "alert": "can't deposit more than 10%"
                    }
               end

           elsif
                render json: {
                    "alert": "You have Home Loan Account"
                }
           end  

        # Car loan deposit
        elsif params[:loan_type] ==  "Car Loan"
           user = User.find(@user.id)
           deposit_amount = params[:amount].to_f

           #if user have Car loan account 
           if user.accounts.where(account_type: "Loan Account").first.loans.find_by(loan_type: "Car Loan").count!=0 and deposit_amount>0 
               loan =  user.accounts.where(account_type: "Loan Account").first.loans.find_by(loan_type: "Car Loan")
               @account = user.accounts.where(account_type: "Loan Account").first

               if loan.principal*0.1>=deposit_amount
                   remaining_loan =  loan.principal.to_d - deposit_amount    
                   loan.principal = remaining_loan
                   loan.save
                   Transaction.create(medium_of_transaction: "direct" , amount: deposit_amount   , credit_debit: " #{params[:loan_type]} Deposit", account_id: @account.id )
                   render json: {
                        "notice": "Loan Deposited"
                    }
               elsif
                    render json: {
                        "alert": "can't deposit more than 10%"
                    }
               end

           elsif
                render json: {
                    "alert": "You have Car Loan Account"
                }
           end
       
        # Personal loan deposit
        elsif params[:loan_type] ==  "Personal Loan"
           user = User.find(@user.id)
           deposit_amount = params[:amount].to_f
           
           #if user have Personal loan account 
           if user.accounts.where(account_type: "Loan Account").first.loans.find_by(loan_type: "Personal Loan").count!=0  and deposit_amount>0
               loan =  user.accounts.where(account_type: "Loan Account").first.loans.find_by(loan_type: "Personal Loan")
               @account = user.accounts.where(account_type: "Loan Account").first

               if loan.principal*0.1>=deposit_amount
                   remaining_loan =  loan.principal.to_d - deposit_amount    
                   loan.principal = remaining_loan
                   loan.save
                   Transaction.create(medium_of_transaction: "direct" , amount: deposit_amount   , credit_debit: " #{params[:loan_type]} Deposit", account_id: @account.id )
                    render json: {
                        "notice": "Loan Deposited"
                    }
               elsif
                    render json: {
                        "alert": "can't deposit more than 10%"
                    }
               end
 
           elsif
                render json: {
                    "alert": "You have Personal Loan Account"
                }
           end 
       
        # Business loan deposit
        elsif params[:loan_type] ==  "Business Loan"
           user = User.find(@user.id)
           deposit_amount = params[:amount].to_f
           
           #if user have Personal loan account 
           if user.accounts.where(account_type: "Loan Account").first.loans.find_by(loan_type: "Business Loan").count!=0  and deposit_amount>0
               loan =  user.accounts.where(account_type: "Loan Account").first.loans.find_by(loan_type: "Business Loan")
               @account = user.accounts.where(account_type: "Loan Account").first
               
               if loan.principal*0.1>=deposit_amount
                   remaining_loan =  loan.principal.to_d - deposit_amount    
                   loan.principal = remaining_loan
                   loan.save
                   Transaction.create(medium_of_transaction: "direct" , amount: deposit_amount   , credit_debit: " #{params[:loan_type]} Deposit", account_id: @account.id )
                   render json: {
                        "notice": "Loan Deposited"
                    }
               elsif
                    render json: {
                        "alert": "can't deposit more than 10%"
                    }
               end

           elsif
                render json: {
                    "alert": "You have Business Loan Account"
                }
           end  

        end
    end





    


    
end
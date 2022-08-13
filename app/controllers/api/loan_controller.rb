class   Api::LoanController < Api::ApplicationController

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
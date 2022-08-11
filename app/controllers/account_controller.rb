class AccountController<ApplicationController
    
    def new
        @user = current_user
    end

    def index
        @user = current_user
    end

    def show
        @user = current_user
    end
    
    #open saving and current account 
    def create
        # byebug
        @user = current_user
        
        #if there is to open current account  
        if params[:account_type] == "Current Account"

            # byebug
            open_current_account(current_user,params)

            # if (Account.where(user_id: @user.id, account_type: "Current Account")).count == 0

            #     temp = params[:minimumn_deposit]
            #     amount = temp.to_f
            #     if amount>=100000
            #         Account.create(user_id: @user.id, account_number: rand(1111111..9999999) , branch_id: (params[:branch]).to_i , amount: amount, account_type: "Current Account")
            #         @account = Account.last
            #         Transaction.create(medium_of_transaction: "direct" , amount: amount , credit_debit: "credit", account_id: @account.id )
            #         Atm.create(expiry_date: 5.year.since ,  atm_card: rand(11111111..99999999), cvv: rand(111..999),  account_id: @account.id )
            #         flash[:notice] = "Current Account Created Successfully, Your Current Account Number is #{@account.account_number    }"
            #         redirect_to root_path
            #     elsif
            #         flash[:alert] = "Minimum deposit should be 100000 for opening of Saving Account."
            #         redirect_to root_path
            #     end

            # elsif
            #     flash[:alert] = "You have already a Current Account."
            #     redirect_to root_path
            # end

        #if there is to open saving account  
        elsif params[:account_type] == "Saving Account"
            
            open_saving_account(current_user,params)

            # if (Account.where(user_id: @user.id, account_type: "Saving Account")).count == 0

            #     temp = params[:minimumn_deposit]
            #     amount = temp.to_f
            #     if amount>=10000
            #         Account.create(user_id: @user.id,  account_number: rand(1111111..9999999) , branch_id: (params[:branch]).to_i , amount: amount, account_type: "Saving Account")
            #         @account = Account.last
            #         Transaction.create(medium_of_transaction: "direct" , amount: amount , credit_debit: "credit", account_id: @account.id )
            #         Atm.create(expiry_date: 5.year.since ,  atm_card: rand(11111111..99999999), cvv: rand(111..999),  account_id: @account.id )
            #         flash[:notice] = "Current Account Created Successfully, Your Saving Account Number is  #{@account.account_number    }"
            #         redirect_to root_path
            #     elsif
                    
            #         flash[:alert] = "Minimum deposit should be 10000 for opening of Saving Account."
            #         redirect_to root_path

            #     end

            # elsif
            #     flash[:alert] = "You have already a Saving Account."
            #     redirect_to root_path
            # end

        end


    end


    def credit_form   
    end

    def credit
        # byebug
        @user = current_user
        if params[:account_type] == "Current Account"
            temp = params[:deposit_amount]
            deposit_amount = temp.to_f
            if (Account.where(user_id: @user.id, account_type: "Current Account")).count !=0 and deposit_amount>0
                @account = (Account.where(user_id: @user.id, account_type: "Current Account")).first
                Transaction.create(medium_of_transaction: "direct" , amount: deposit_amount , credit_debit: "credit", account_id: @account.id )
                @account.amount+=deposit_amount
                @account.save
                flash[:notice] = "Hi #{@user.first_name},   #{deposit_amount} is successfully deposited in your Current Account"
                redirect_to root_path
            elsif
                flash[:alert] = "First open the current account then deposit or Enter correct amount."
                redirect_to root_path
            end
        elsif params[:account_type] == "Saving Account"
            temp = params[:deposit_amount]
            deposit_amount = temp.to_f
            if (Account.where(user_id: @user.id, account_type: "Saving Account")).count !=0 and deposit_amount>0
                @account = (Account.where(user_id: @user.id, account_type: "Saving Account")).first
                Transaction.create(medium_of_transaction: "direct" , amount: deposit_amount , credit_debit: "credit", account_id: @account.id )
                @account.amount+=deposit_amount
                @account.save
                flash[:notice] = "Hi #{@user.first_name},   #{deposit_amount} is successfully deposited in your Saving Account"
                redirect_to root_path
            elsif   
                flash[:alert] = "First open the saving account then deposit or Enter correct amount."
                redirect_to root_path
            end
        end

    end

    def withdrawal_page
        @user = current_user
    end

    def current_account_withdrawal_form 
        @user = current_user
        if (Account.where(user_id: @user.id, account_type: "Current Account")).count ==0
            flash[:alert] = "First open the current account then withdrawal."
            redirect_to root_path
        end
    end

    def current_account_withdrawal

        @user = current_user

        if ( @user.first_name == params[:first_name] and @user.email == params[:email] and @user.dob == params[:dob]  )
            
            @account = (Account.where(user_id: @user.id, account_type: "Current Account")).first
            temp = params[:withdrawal_amount]
            withdrawal_amount = temp.to_f
            transaction_charge = withdrawal_amount*0.005
            #count the number of transactions of current account in a month by a user
            count_transaction_in_a_month = 0
            if(Time.new.month<10)
                transactions = Transaction.where( "strftime('%m', created_at) = ?", "#{"0"+Time.new.month.to_s}")
                count_transaction_in_a_month = transactions.where(account_id: @account.id, credit_debit: "debit").count
            elsif
                transactions = Transaction.where( "strftime('%m', created_at) = ?", "#{Time.new.month.to_s}")
                count_transaction_in_a_month = transactions.where(account_id: @account.id).count
            end

            if(transaction_charge>500) 
                transaction_charge=500
            end
            
            if(count_transaction_in_a_month>=3) 
                transaction_charge+=500
            end

            # is_process =    

            if(@account.amount >= (withdrawal_amount+transaction_charge))
                
                # lock_account = Account.where(user_id: @user.id , account_type: "Current Account").first
                
                @account.with_lock do
                    @account.amount-=(withdrawal_amount+transaction_charge)
                    @account.save
                    Transaction.create(medium_of_transaction: "direct" , amount: withdrawal_amount , credit_debit: "debit", account_id: @account.id )
                    flash[:notice] = "#{@user.first_name},  You succesfully withdrawal #{withdrawal_amount} from your Current Account"
                    redirect_to root_path
                end

            elsif
                flash[:alert] = "Sorry, You have not sufficient amount to withdrawal"
                redirect_to root_path
            end

        elsif 

            flash[:alert] = "Sorry, Wrong Credentials"
            redirect_to root_path

        end

    end
    
    def saving_account_withdrawal_page
        @user = current_user
        if (Account.where(user_id: @user.id, account_type: "Saving Account")).count ==0
            flash[:alert] = "First open the saving account then withdrawal."
            redirect_to root_path
        end
    end

    def saving_account_withdrawal_atm_form
    end

    def saving_account_withdrawal_atm
        
        @user = current_user
        @account = (Account.where(user_id: @user.id, account_type: "Saving Account")).first
        @atm  = Atm.where(account_id: @account.id).first

        if ( @user.first_name == params[:first_name] and @user.email == params[:email] and @user.dob == params[:dob] and @atm.atm_card == params[:atm_card].to_i and @atm.cvv == (params[:cvv]) and params[:withdrawal_amount].to_f>0)
            
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
                    flash[:notice] = "#{@user.first_name},  You succesfully withdrawal #{withdrawal_amount} from your Saving Account"
                    redirect_to root_path
                end

            elsif
                flash[:alert] = "Sorry, You have not sufficient amount to withdrawal or You can't withdraw more than 50000 in a day or You can't withdraw more than 20000 through atm" 
                redirect_to root_path
            end

        elsif 

            flash[:alert] = "Sorry, Wrong Credentials"
            redirect_to root_path

        end

    end

    def saving_account_withdrawal_direct_form   
    end

    def saving_account_withdrawal_direct
        
        @user = current_user

        if ( @user.first_name == params[:first_name] and @user.email == params[:email] and @user.dob == params[:dob] and params[:withdrawal_amount].to_f>0 )
            
            @account = (Account.where(user_id: @user.id, account_type: "Saving Account")).first
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

            if(@account.amount >= withdrawal_amount and total_amount_withdraw_in_a_day <=50000 ) 
                
                @account.with_lock do
                    @account.amount-=(withdrawal_amount)
                    @account.save
                    Transaction.create(medium_of_transaction: "direct" , amount: withdrawal_amount , credit_debit: "debit", account_id: @account.id )
                    flash[:notice] = "#{@user.first_name},  You succesfully withdrawal #{withdrawal_amount} from your Saving Account"
                    redirect_to root_path
                end

            elsif
                flash[:alert] = "Sorry, You have not sufficient amount to withdrawal or You can't withdraw more than 50000 in a day" 
                redirect_to root_path
            end

        elsif 

            flash[:alert] = "Sorry, Wrong Credentials"
            redirect_to root_path

        end

    end

    def new_loan_account 

        @user = current_user
        if Account.where(user_id: @user.id).count==0
            flash[:alert] = "Sorry, First open a Saving Account or Current Account."
            redirect_to root_path
        end

    end

    def create_loan_account
        
        @user = current_user

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
                    flash[:notice] = "Hi #{@current_user.first_name} ,  Your #{params[:loan_type]} of amount #{params[:amount].to_f } is approved" 


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
                    flash[:notice] = "Hi #{@current_user.first_name} ,  Your #{params[:loan_type]} of amount #{params[:amount].to_f } is approved" 


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
                    flash[:notice] = "Hi #{@current_user.first_name} ,  Your #{params[:loan_type]} of amount #{params[:amount].to_f } is approved" 

                    
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
                    flash[:notice] = "Hi #{@current_user.first_name} ,  Your #{params[:loan_type]} of amount #{params[:amount].to_f } is approved" 

                end

                # Loan.create(loan_type: params[:loan_type], amount: params[:amount].to_f , duration: params[:duration].to_i , account_id: @account.id, principal: principle)
                redirect_to root_path
            else
                flash[:alert] = "Sorry, You have not sufficient amount or sufficient criteria by bank to take loan" 
                redirect_to root_path
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
                flash[:notice] = "Hi #{@current_user.first_name} ,  Your #{params[:loan_type]} of amount #{params[:amount].to_f } is approved" 
                redirect_to root_path
            else
                flash[:alert] = "Sorry, You have not sufficient amount or sufficient criteria by bank to take loan" 
                redirect_to root_path
            end

        end

    end


    def new_loan_deposit  
    end

    def create_loan_deposit

        @user = current_user
        
         #if user have no loan
        if @user.accounts.where(account_type: "Loan Account").count==0
            flash[:alert] = "Sorry, You haven't loan account " 
            redirect_to root_path

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
                    flash[:notice] = " You have successfully deposited #{deposit_amount} in your #{params[:loan_type]} account " 
                    redirect_to root_path
                elsif
                    flash[:alert] = "Sorry, You can't deposit more than 10% amount of total loan " 
                    redirect_to root_path
                end

            elsif
                flash[:alert] = "Sorry, You have not Home Loan or enter wrong amount." 
                redirect_to root_path
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
                    flash[:notice] = " You have successfully deposited #{deposit_amount} in your #{params[:loan_type]} account " 
                    redirect_to root_path
                elsif
                    flash[:alert] = "Sorry, You can't deposit more than 10% amount of total loan " 
                    redirect_to root_path
                end

            elsif
                flash[:alert] = "Sorry, You have not Car Loan or enter wrong amount." 
                redirect_to root_path
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
                    flash[:notice] = " You have successfully deposited #{deposit_amount} in your #{params[:loan_type]} account" 
                    redirect_to root_path
                elsif
                    flash[:alert] = "Sorry, You can't deposit more than 10% amount of total loan " 
                    redirect_to root_path
                end
  
            elsif
                flash[:alert] = "Sorry, You have not Personal Loan or enter wrong amount." 
                redirect_to root_path
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
                    flash[:notice] = " You have successfully deposited #{deposit_amount} in your #{params[:loan_type]} account " 
                    redirect_to root_path
                elsif
                    flash[:alert] = "Sorry, You can't deposit more than 10% amount of total loan " 
                    redirect_to root_path
                end

            elsif
                flash[:alert] = "Sorry, You have not Business Loan or enter wrong amount." 
                redirect_to root_path
            end  

        end

    end

    def loan_details
    end



    def open_current_account(current_user,params)
        if (Account.where(user_id: current_user.id, account_type: "Current Account")).count == 0
            temp = params[:minimumn_deposit]
            amount = temp.to_f
            if amount>=100000
                Account.create(user_id: current_user.id, account_number: rand(1111111..9999999) , branch_id: (params[:branch]).to_i , amount: amount, account_type: "Current Account")
                @account = Account.last
                Transaction.create(medium_of_transaction: "direct" , amount: amount , credit_debit: "credit", account_id: @account.id )
                Atm.create(expiry_date: 5.year.since ,  atm_card: rand(11111111..99999999), cvv: rand(111..999),  account_id: @account.id )
                flash[:notice] = "Current Account Created Successfully, Your Current Account Number is #{@account.account_number    }"
                redirect_to root_path
            elsif
                flash[:alert] = "Minimum deposit should be 100000 for opening of Saving Account."
                redirect_to root_path
            end
        elsif
            flash[:alert] = "You have already a Current Account."
            redirect_to root_path
        end
    end


    def open_saving_account(current_user,params)
        if (Account.where(user_id: current_user.id, account_type: "Saving Account")).count == 0
            temp = params[:minimumn_deposit]
            amount = temp.to_f
            if amount>=10000
                Account.create(user_id: current_user.id,  account_number: rand(1111111..9999999) , branch_id: (params[:branch]).to_i , amount: amount, account_type: "Saving Account")
                @account = Account.last
                Transaction.create(medium_of_transaction: "direct" , amount: amount , credit_debit: "credit", account_id: @account.id )
                Atm.create(expiry_date: 5.year.since ,  atm_card: rand(11111111..99999999), cvv: rand(111..999),  account_id: @account.id )
                flash[:notice] = "Current Account Created Successfully, Your Saving Account Number is  #{@account.account_number    }"
                redirect_to root_path
            elsif 
                flash[:alert] = "Minimum deposit should be 10000 for opening of Saving Account."
                redirect_to root_path
            end
        elsif
            flash[:alert] = "You have already a Saving Account."
            redirect_to root_path
        end
    end


end


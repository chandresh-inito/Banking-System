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
    
    def create    # open saving and current account 
        @user = current_user
        if params[:account_type] == "Current Account"
            if (Account.where(user_id: @user.id, account_type: "Current Account")).count == 0
                temp = params[:minimumn_deposit]
                amount = temp.to_f
                Account.open_current_account(current_user, params, amount) 
            end
        elsif params[:account_type] == "Saving Account"
            if (Account.where(user_id: @user.id, account_type: "Saving Account")).count == 0
                temp = params[:minimumn_deposit]
                amount = temp.to_f
                Account.open_saving_account(current_user,params,amount)
            end
        end
        redirect_to root_path
    end

    def credit_form  
    end

    def credit
        if params[:account_type] == "Current Account"
            temp = params[:deposit_amount]
            deposit_amount = temp.to_f
            if (Account.where(user_id: current_user.id, account_type: "Current Account")).count !=0 and deposit_amount>0
                Account.deposit_in_current(deposit_amount,current_user)
                flash[:notice] = "#{deposit_amount} is successfully deposited in your Current Account"
            end
        elsif params[:account_type] == "Saving Account"
            temp = params[:deposit_amount]
            deposit_amount = temp.to_f
            if (Account.where(user_id: current_user.id, account_type: "Saving Account")).count !=0 and deposit_amount>0
                Account.deposit_in_saving(deposit_amount,current_user)
            end
        end
        redirect_to root_path
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
            transaction_charge = Account.current_withdraw_transaction_charges(withdrawal_amount,current_user)
            if(@account.amount >= (withdrawal_amount+transaction_charge))
                @account.with_lock do
                    @account.amount-=(withdrawal_amount+transaction_charge)
                    @account.save
                    Transaction.create(medium_of_transaction: "direct" , amount: withdrawal_amount , credit_debit: "debit", account_id: @account.id )
                    flash[:notice] = "#{@user.first_name},  You succesfully withdrawal #{withdrawal_amount} from your Current Account"
                end
            end
        end
        redirect_to root_path
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
            temp = params[:withdrawal_amount]
            withdrawal_amount = temp.to_f
            
            #total amount withdrawal in saving account in a day by a user
            total_amount_withdraw_in_a_day = Account.total_amount_withdraw_in_a_day(current_user)
            total_amount_withdraw_in_a_day+=withdrawal_amount

            number_of_transaction_by_atm_in_a_month = Account.count_withdraw_in_a_month(current_user)
            transaction_charge = 0
            if number_of_transaction_by_atm_in_a_month >= 5 
                transaction_charge = 500
            end

            if(withdrawal_amount<=20000 and  @account.amount >= (withdrawal_amount+transaction_charge) and total_amount_withdraw_in_a_day <=50000 ) 
                @account.with_lock do
                    @account.amount-=(withdrawal_amount+transaction_charge)
                    @account.save
                    Transaction.create(medium_of_transaction: "atm" , amount: withdrawal_amount , credit_debit: "debit", account_id: @account.id )
                    flash[:notice] = "#{@user.first_name},  You succesfully withdrawal #{withdrawal_amount} from your Saving Account"
                end
            elsif
                flash[:alert] = "Sorry, You have not sufficient amount to withdrawal or You can't withdraw more than 50000 in a day or You can't withdraw more than 20000 through atm" 
            end

        elsif 
            flash[:alert] = "Sorry, Wrong Credentials"
        end
        redirect_to root_path
    end

    def saving_account_withdrawal_direct_form   
    end

    def saving_account_withdrawal_direct
        @user = current_user
        if ( @user.first_name == params[:first_name] and @user.email == params[:email] and @user.dob == params[:dob] and params[:withdrawal_amount].to_f>0 )
            temp = params[:withdrawal_amount]
            withdrawal_amount = temp.to_f
            @account = (Account.where(user_id: @user.id, account_type: "Saving Account")).first
            #total amount withdrawal in saving account in a day by a user
            total_amount_withdraw_in_a_day = Account.total_amount_withdraw_in_a_day(current_user)
            total_amount_withdraw_in_a_day+=withdrawal_amount
            if(@account.amount >= withdrawal_amount and total_amount_withdraw_in_a_day <=50000 ) 
                @account.with_lock do
                    @account.amount-=(withdrawal_amount)
                    @account.save
                    Transaction.create(medium_of_transaction: "direct" , amount: withdrawal_amount , credit_debit: "debit", account_id: @account.id )
                    flash[:notice] = "#{@user.first_name},  You succesfully withdrawal #{withdrawal_amount} from your Saving Account"
                end
            elsif
                flash[:alert] = "Sorry, You have not sufficient amount to withdrawal or You can't withdraw more than 50000 in a day" 
            end
        elsif 
            flash[:alert] = "Sorry, Wrong Credentials"
        end
        redirect_to root_path
    end

    def new_loan_account 
        @user = current_user
        if Account.where(user_id: @user.id).count==0
            flash[:alert] = "Sorry, First open a Saving Account or Current Account."
            redirect_to root_path
        end
    end

    def create_loan_deposit
        @user = current_user
         #if user have no loan
        if @user.accounts.where(account_type: "Loan Account").count==0
            flash[:alert] = "Sorry, You haven't loan account "
        elsif params[:loan_type] == "Home Loan" 
            Account.deposit_in_home_loan(current_user,params)
        elsif params[:loan_type] ==  "Car Loan"
            Account.deposit_in_car_loan(current_user,params)
        elsif params[:loan_type] ==  "Personal Loan"
            Account.deposit_in_personal_loan(current_user,params)
        elsif params[:loan_type] ==  "Business Loan"
            Account.deposit_in_business_loan(current_user,params)
        end
        redirect_to root_path
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
            total_deposit_amount = Account.total_deposit(current_user)
            loan_canbe_given = total_deposit_amount*0.4

            if (total_loan_amount<=loan_canbe_given and required_loan_amount>=500000 and params[:duration].to_i>=24)
                Transaction.create(medium_of_transaction: "direct" , amount: -1*required_loan_amount   , credit_debit: "debit", account_id: @account.id )
                principle = 0
                if(params[:loan_type]=="Home Loan") 
                    principle = required_loan_amount+required_loan_amount*(params[:duration].to_i/12)*0.07
                    Account.home_loan(current_user, params, principle)
                elsif (params[:loan_type]=="Car Loan")
                    principle = required_loan_amount+required_loan_amount*(params[:duration].to_i/12)*0.08
                    Account.car_loan(current_user, params, principle)
                elsif (params[:loan_type]=="Personal Loan")
                    principle = required_loan_amount+required_loan_amount*(params[:duration].to_i/12)*0.12
                    Account.personal_loan(current_user, params, principle)
                elsif (params[:loan_type]=="Business Loan")
                    principle = required_loan_amount+required_loan_amount*(params[:duration].to_i/12)*0.15
                    Account.business_loan(current_user, params, principle)
                end
            else
                flash[:alert] = "Sorry, You have not sufficient amount or sufficient criteria by bank to take loan" 
            end
        else
            Account.open_new_loan_account(current_user,params)
        end
        redirect_to root_path
    end

    def new_loan_deposit  
    end

    def loan_details
    end

end


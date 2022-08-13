class   Api::WithdrawController < Api::ApplicationController

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

    
    

end
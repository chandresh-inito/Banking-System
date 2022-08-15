class   Api::TransactionController < Api::ApplicationController
    
    def index
        @transaction = Transaction.all
        render json: {
            "transactions": @transaction
        }
    end

    def show
        @user = User.find(params[:id].to_i)
        
        if @user.accounts.count != 0
            render json: {
                # "users": @user
                "transaction1": Account.where(user_id: @user.id , account_type: "Saving Account").first.transactions,
                "transaction2": Account.where(user_id: @user.id , account_type: "Current Account").first.transactions,
                "transaction3": Account.where(user_id: @user.id , account_type: "Loan Account").first.transactions

            }
        else
            render json: {
                "alert": "You have entered wrong account"
            }
        end
    end

end
class   Api::LoanController < Api::ApplicationController

    def show
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

end
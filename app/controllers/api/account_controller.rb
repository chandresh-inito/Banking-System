class   Api::AccountController < Api::ApplicationController
    before_action :authenticate_user!
    protect_from_forgery with: :null_session

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

  
    def create 
        id  = params[:id].to_i 
        @user = User.find(id)
        if ((params[:account_type] == 'Saving Account' && params[:amount].to_i < 10000) || (params[:account_type] == 'Current Account' && params[:amount].to_i < 100000))
            render json: {
                "alert": "Please deposit minimum account"
            }
        elsif params[:account_type] == 'Current Account' && ((Time.now.year -  @user.dob.to_time.year)) < 18
            render json: {
                "alert": "Minimum age for Current account is 18"
            }
        else
            @account = Account.create(user_id: @user.id, account_type: params[:account_type], branch_id: (params[:branch_id]).to_i,amount: (params[:amount]).to_f, account_number: rand(1111111..9999999))
            Transaction.create(medium_of_transaction: "direct", credit_debit: "credit",account_id: @account.id,amount: (params[:amount]).to_f)
            @atm = Atm.create(account_id: @account.id,expiry_date: DateTime.now.next_year(5).to_date,cvv: rand(111..999),atm_card: rand(1111111..9999999))
            render json: {
                "notice": "Your account sucessfully opened"
            }
        end
    end 


    def deposit 
        @user = User.find(params[:user_id].to_i)
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
 
end
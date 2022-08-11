class Account<ApplicationRecord
    belongs_to :branch
    belongs_to :user
    has_many :transactions, dependent: :destroy
    has_one :atm, dependent: :destroy
    has_many :loans , dependent: :destroy

    # def self.open_current_account(current_user,params)

    #     if (Account.where(user_id: current_user.id, account_type: "Current Account")).count == 0

    #         temp = params[:minimumn_deposit]
    #         amount = temp.to_f
    #         if amount>=100000
    #             Account.create(user_id: current_user.id, account_number: rand(1111111..9999999) , branch_id: (params[:branch]).to_i , amount: amount, account_type: "Current Account")
    #             @account = Account.last
    #             Transaction.create(medium_of_transaction: "direct" , amount: amount , credit_debit: "credit", account_id: @account.id )
    #             Atm.create(expiry_date: 5.year.since ,  atm_card: rand(11111111..99999999), cvv: rand(111..999),  account_id: @account.id )
    #             flash[:notice] = "Current Account Created Successfully, Your Current Account Number is #{@account.account_number    }"
    #             redirect_to root_path
    #         elsif
    #             flash[:alert] = "Minimum deposit should be 100000 for opening of Saving Account."
    #             redirect_to root_path
    #         end

    #     elsif

    #         flash[:alert] = "You have already a Current Account."
    #         redirect_to root_path

    #     end

    # end


end
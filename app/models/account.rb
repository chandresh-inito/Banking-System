class Account<ApplicationRecord
    belongs_to :branch
    belongs_to :user
    has_many :transactions, dependent: :destroy
    has_one :atm, dependent: :destroy
    has_many :loans , dependent: :destroy
    after_create :transaction_and_atm
    validate :validate_account_before_opening
    validates :account_number , :amount , :presence => true
    

    def validate_account_before_opening
        # byebug
        if (self.account_type=="Current Account" and self.amount.to_f >= 100000 and (Time.now.year - User.find(self.user_id).dob.year) >=18 ) || (self.account_type=="Saving Account"  and self.amount.to_f >= 10000 ) || (self.account_type == "Loan Account"  and (Time.now.year - User.find(self.user_id).dob.year) >=25 )
            # self.errors.add(:base ,  "There is no availability of this type of account")
        else
            self.errors.add(:base ,  "There is no availability of this type of account")
        end
    end

    def transaction_and_atm
        @account = Account.last
        Transaction.create(medium_of_transaction: "direct" , amount: @account.amount , credit_debit: "credit", account_id: @account.id )
        Atm.create(expiry_date: 5.year.since ,  atm_card: rand(11111111..99999999), cvv: rand(111..999),  account_id: @account.id )
    end

    
    def self.open_current_account(current_user, params, amount)
        Account.create(user_id: current_user.id, account_number: rand(1111111..9999999) , branch_id: (params[:branch]).to_i , amount: amount, account_type: "Current Account")
    end

    def self.open_saving_account(current_user, params, amount) 
        Account.create(user_id: current_user.id,  account_number: rand(1111111..9999999) , branch_id: (params[:branch]).to_i , amount: amount, account_type: "Saving Account")
    end

    def self.deposit_in_current(deposit_amount, current_user)
        @account = (Account.where(user_id: current_user.id, account_type: "Current Account")).first
        Transaction.create(medium_of_transaction: "direct" , amount: deposit_amount , credit_debit: "credit", account_id: @account.id )
        @account.amount+=deposit_amount
        @account.save
    end

    def self.deposit_in_saving(deposit_amount,current_user)
        @account = (Account.where(user_id: current_user.id, account_type: "Saving Account")).first
        Transaction.create(medium_of_transaction: "direct" , amount: deposit_amount , credit_debit: "credit", account_id: @account.id )
        @account.amount+=deposit_amount
        @account.save
    end

    def self.current_withdraw_transaction_charges(withdrawal_amount,current_user)
        transaction_charge = withdrawal_amount*0.005
        #count the number of transactions of current account in a month by a user
        @account = Account.where(user_id: current_user.id, account_type: "Current Account").first
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

        transaction_charge
    end

    def self.count_withdraw_in_a_month(current_user)
        @account = Account.where(user_id: current_user.id, account_type: "Saving Account").first
        number_of_transaction_by_atm_in_a_month = 0
        if(Time.new.month<10)
            transaction = Transaction.where( "strftime('%m', created_at) = ?", "#{"0"+Time.new.month.to_s}")
            number_of_transaction_by_atm_in_a_month =  transaction.where(account_id: @account.id, credit_debit: "debit", medium_of_transaction: "atm").count
        elsif
            transaction = Transaction.where( "strftime('%m', created_at) = ?", "#{Time.new.month.to_s}")
            number_of_amount_withdraw_in_a_day =  transaction.where(account_id: @account.id, credit_debit: "debit", medium_of_transaction: "atm" ).count
        end
        number_of_transaction_by_atm_in_a_month
    end

    def self.total_amount_withdraw_in_a_day(current_user)
        @account  =Account.where(user_id: current_user.id , account_type: "Saving Account").first
        total_amount_withdraw_in_a_day = 0
        if(Time.new.day<10)
            transaction = Transaction.where( "strftime('%d', created_at) = ?", "#{"0"+Time.new.day.to_s}")
            total_amount_withdraw_in_a_day =  transaction.where(account_id: @account.id, credit_debit: "debit").sum(:amount)
        elsif
            transaction = Transaction.where( "strftime('%d', created_at) = ?", "#{Time.new.day.to_s}")
            total_amount_withdraw_in_a_day =  transaction.where(account_id: @account.id, credit_debit: "debit").sum(:amount)
        end
        total_amount_withdraw_in_a_day
    end

    def self.home_loan(current_user, params, principle)

        @account = Account.where(user_id: current_user.id , account_type:"Loan Account").first
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

    end

    def self.car_loan(current_user, params, principle)
        @account = Account.where(user_id: current_user.id , account_type:"Loan Account").first
        if @account.loans.where(loan_type: "Car Loan").count!=0
            @home_loan = @account.loans.where(loan_type: "Car Loan").first
            outstanding_home_loan_amount  = @home_loan.principal.to_f
            principle += outstanding_home_loan_amount
            @home_loan.principal = principle
            @home_loan.save
        elsif
            Loan.create(loan_type: params[:loan_type], amount: params[:amount].to_f , duration: params[:duration].to_i , account_id: @account.id, principal: principle)
        end
    end

    def self.personal_loan(current_user, params,principle)
        @account = Account.where(user_id: current_user.id , account_type:"Loan Account").first
        if @account.loans.where(loan_type: "Personal Loan").count!=0
            @home_loan = @account.loans.where(loan_type: "Personal Loan").first
            outstanding_home_loan_amount  = @home_loan.principal.to_f
            principle += outstanding_home_loan_amount
            @home_loan.principal = principle
            @home_loan.save
        elsif
            Loan.create(loan_type: params[:loan_type], amount: params[:amount].to_f , duration: params[:duration].to_i , account_id: @account.id, principal: principle)
        end
    end

    def self.business_loan(current_user, params, principle)
        @account = Account.where(user_id: current_user.id , account_type:"Loan Account").first
        if @account.loans.where(loan_type: "Business Loan").count!=0
            @home_loan = @account.loans.where(loan_type: "Business Loan").first
            outstanding_home_loan_amount  = @home_loan.principal.to_f
            principle += outstanding_home_loan_amount
            @home_loan.principal = principle
            @home_loan.save
        elsif
            Loan.create(loan_type: params[:loan_type], amount: params[:amount].to_f , duration: params[:duration].to_i , account_id: @account.id, principal: principle)
        end
    end

    def self.total_deposit(current_user)
        saving_amount = Account.where(user_id: current_user.id , account_type: "Saving Account").first.amount.to_f
        current_amount = Account.where(user_id: current_user.id , account_type: "Current Account").first.amount.to_f
        total_deposit_amount = saving_amount + current_amount
        total_deposit_amount
    end

    def self.open_new_loan_account(current_user, params)

        required_loan_amount = params[:amount].to_f
        #total_deposit_account
        saving_amount = Account.where(user_id: current_user.id , account_type: "Saving Account").first.amount.to_f
        current_amount = Account.where(user_id: current_user.id , account_type: "Current Account").first.amount.to_f
        total_deposit_amount = saving_amount + current_amount

        loan_canbe_given = total_deposit_amount*0.4
        
        if (required_loan_amount <= loan_canbe_given and required_loan_amount >= 500000 and params[:duration].to_i >= 24)
            # byebug
            @account = Account.create(user_id: current_user.id , account_number: rand(1111111..9999999) ,  account_type: "Loan Account" , branch_id: params[:branch].to_i , amount: params[:amount].to_i )
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
        end
        
    end

    def self.deposit_in_home_loan(current_user,params)
        
        user = User.find(current_user.id)
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
            end

        end

    end

    def self.deposit_in_car_loan(current_user, params)
        user = User.find(current_user.id)
        deposit_amount = params[:amount].to_f

        #if user have Car loan account 
        if user.accounts.where(account_type: "Loan Account").first.loans.find_by(loan_type: "Car Loan") != nil and deposit_amount>0 
            loan =  user.accounts.where(account_type: "Loan Account").first.loans.find_by(loan_type: "Car Loan")
            @account = user.accounts.where(account_type: "Loan Account").first

            if loan.principal*0.1>=deposit_amount
                remaining_loan =  loan.principal.to_d - deposit_amount    
                loan.principal = remaining_loan
                loan.save
                Transaction.create(medium_of_transaction: "direct" , amount: deposit_amount   , credit_debit: " #{params[:loan_type]} Deposit", account_id: @account.id )
 
            end
        end
    
    end


    def self.deposit_in_personal_loan(current_user,params)
        user = User.find(current_user.id)
        deposit_amount = params[:amount].to_f
        
        #if user have Personal loan account 
        if user.accounts.where(account_type: "Loan Account").first.loans.find_by(loan_type: "Personal Loan") != nil  and deposit_amount>0
            loan =  user.accounts.where(account_type: "Loan Account").first.loans.find_by(loan_type: "Personal Loan")
            @account = user.accounts.where(account_type: "Loan Account").first

            if loan.principal*0.1>=deposit_amount
                remaining_loan =  loan.principal.to_d - deposit_amount    
                loan.principal = remaining_loan
                loan.save
                Transaction.create(medium_of_transaction: "direct" , amount: deposit_amount   , credit_debit: " #{params[:loan_type]} Deposit", account_id: @account.id )
    
            end
        end
    end

    def self.deposit_in_business_loan(current_user, params)
        
        user = User.find(current_user.id)
        deposit_amount = params[:amount].to_f
        
        #if user have Personal loan account 
        if user.accounts.where(account_type: "Loan Account").first.loans.find_by(loan_type: "Business Loan") != nil  and deposit_amount>0
            loan =  user.accounts.where(account_type: "Loan Account").first.loans.find_by(loan_type: "Business Loan")
            @account = user.accounts.where(account_type: "Loan Account").first
            
            if loan.principal*0.1>=deposit_amount
                remaining_loan =  loan.principal.to_d - deposit_amount    
                loan.principal = remaining_loan
                loan.save
                Transaction.create(medium_of_transaction: "direct" , amount: deposit_amount   , credit_debit: " #{params[:loan_type]} Deposit", account_id: @account.id )
            end
      
        end  

    end

end
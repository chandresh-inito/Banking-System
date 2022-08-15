class Transaction<ApplicationRecord
    belongs_to :account
    validates :medium_of_transaction, :credit_debit , :amount , :presence =>true
    validate :validation_before_create_transaction
    
    def validation_before_create_transaction
        if self.amount>=0 and (self.credit_debit == "credit" or self.credit_debit == "debit") and (self.medium_of_transaction =="direct" or  self.medium_of_transaction =="atm")
        else  
            self.errors.add(:base , "Invalid Credential to withdraw or credit amount")
        end
    end


end
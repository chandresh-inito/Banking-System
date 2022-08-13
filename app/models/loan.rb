class Loan<ApplicationRecord
    belongs_to :account
    validates :loan_type, :amount , :duration, :principal ,  :presence=>true
    validate :loan_type_before_opening

    def loan_type_before_opening
        if(self.loan_type == "Home Loan") || (self.loan_type == "Car Loan"  ) || (self.loan_type == "Personal Loan") || (self.loan_type == "Business Loan") 
        
        else
            errors.add(:account, "There is no availability of this type of loan")
        end
    end
    



end


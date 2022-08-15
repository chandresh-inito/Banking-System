class Loan<ApplicationRecord
    belongs_to :account
    validates :loan_type, :amount , :duration,    :presence=>true
    validate :loan_type_before_opening

    def loan_type_before_opening
        if ((self.loan_type == "Home Loan") || (self.loan_type == "Car Loan"  ) || (self.loan_type == "Personal Loan") || (self.loan_type == "Business Loan") ) && (self.duration>=24) && (self.amount>=500000)
        
        else
            self.errors.add(:base, "There is no availability of this type of loan")
        end
    end
    



end


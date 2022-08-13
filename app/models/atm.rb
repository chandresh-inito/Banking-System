class Atm<ApplicationRecord
    validates :expiray_date , :atm_card , :cvv, :presence => true
    validate :does_not_have_multiple_atm_card_of_a_account

    def does_not_have_multiple_atm_card_of_a_account
        account_id = self.account_id
        
        if Atm.where(account_id: account_id).count!=0
        else
            errors.add("CAn't have multiple atm card to a account")
        end

    end

end
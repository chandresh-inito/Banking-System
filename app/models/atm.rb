class Atm<ApplicationRecord
    has_one :account
    validates :expiry_date , :atm_card , :cvv, :presence => true
   

end
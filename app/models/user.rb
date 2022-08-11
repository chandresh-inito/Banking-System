class User < ApplicationRecord
            # Include default devise modules.
            # devise :database_authenticatable, :registerable,
            #         :recoverable, :rememberable, :trackable, :validatable,
            #         :confirmable, :omniauthable
            # include DeviseTokenAuth::Concerns::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # TODO: validation , fname, lname, email, password 
  has_many :accounts, dependent: :destroy
  
  def self.search(param)
    param.strip!
    to_send_back = (first_name_matches(param)+ last_name_matches(param) + email_matches(param)).uniq
    return nil unless to_send_back
    to_send_back
  end


  def self.first_name_matches(param)
    matches('first_name', param)
  end

  def self.last_name_matches(param)
    matches('last_name', param)
  end

  def self.email_matches(param)
    matches('email', param)
  end


  def self.matches(field_name, param)
    where("#{field_name} like ?", "%#{param}")
  end

end

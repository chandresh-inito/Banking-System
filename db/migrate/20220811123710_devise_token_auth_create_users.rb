class DeviseTokenAuthCreateUsers < ActiveRecord::Migration[6.0]
  def change
    
    ## Required
    add_column :users , :provider , :string ,  default: :email
    # t.string :provider, :null => false, :default => "email"
    # t.string :uid, :null => false, :default => ""
    add_column :users, :uid , :string

    ## Database authenticatable
    # t.string :encrypted_password, :null => false, :default => ""

    ## Recoverable
    # t.string   :reset_password_token
    # t.datetime :reset_password_sent_at
    # t.boolean  :allow_password_change, :default => false
    add_column :users , :allow_password_change , :boolean

    ## Rememberable
    # t.datetime :remember_created_at

    ## Confirmable
    # t.string   :confirmation_token
    add_column :users , :confirmation_token , :string
    # t.datetime :confirmed_at
    add_column :users , :confirmed_at ,  :datetime
    # t.datetime :confirmation_sent_at
    add_column :users , :confirmation_sent_at , :datetime
    # t.string   :unconfirmed_email # Only if using reconfirmable
    add_column :users , :unconfirmed_email , :string


    ## Lockable
    # t.integer  :failed_attempts, :default => 0, :null => false # Only if lock strategy is :failed_attempts
    # t.string   :unlock_token # Only if unlock strategy is :email or :both
    # t.datetime :locked_at

    ## User Info
    # t.string :name
    # t.string :nickname
    # t.string :image
    # t.string :email

    ## Tokens
    # t.text :tokens  
    add_column :users , :tokens , :text

    # t.timestamps

    # add_index :users, :email,                unique: true
    add_index :users, [:uid, :provider],     unique: true
    # add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true

  end
end

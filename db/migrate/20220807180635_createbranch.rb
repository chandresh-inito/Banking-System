class Createbranch < ActiveRecord::Migration[6.0]
  def change
    create_table :branches do |t|
      t.string  :name
      t.string  :address
      t.integer :pincode
      t.timestamps
    end


    create_table :accounts do |t|
      t.integer  :account_number
      t.decimal :amount
      t.string  :account_type
      t.integer :loan_id
      t.references :user, foreign_key: true
      t.references :branch, foreign_key: true
      t.timestamps
    end

    create_table :atms do |t|
      t.date  :expiry_date
      t.integer :atm_card
      t.string  :cvv
      t.references :account, foreign_key: true
      t.timestamps
    end

    create_table :transactions do |t|
      t.string  :medium_of_transaction
      t.integer :amount
      t.string  :credit_debit
      t.string :from
      t.string :where
      t.references :account, foreign_key: true
      t.timestamps
    end

  end
end

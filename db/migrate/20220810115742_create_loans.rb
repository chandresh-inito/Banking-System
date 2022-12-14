class CreateLoans < ActiveRecord::Migration[6.0]
  def change
    create_table :loans do |t|
      t.string :loan_type
      t.decimal :amount
      t.integer :duration
      t.references :account, foreign_key: true
      t.timestamps
    end
  end
end

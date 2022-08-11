class DropLoanIdFromAccount < ActiveRecord::Migration[6.0]
  def change
    remove_column :accounts, :loan_id
  end
end

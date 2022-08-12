class AddColumnToUsers < ActiveRecord::Migration[6.0]
  def change
    
    # t.integer  :sign_in_count, default: 0, null: false
    # t.datetime :current_sign_in_at
    # t.datetime :last_sign_in_at
    # t.inet     :current_sign_in_ip
    # t.inet     :last_sign_in_ip

    
    add_column :users , :sign_in_count , :integer
    add_column :users , :current_sign_in_at , :datetime
    add_column :users , :last_sign_in_at , :datetime
    add_column :users , :current_sign_in_ip , :inet
    add_column :users , :last_sign_in_ip , :inet

  end
end

class Addcolumntousers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :current_sign_in_ip, :inem
    add_column :users, :last_sign_in_ip, :inem

    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end

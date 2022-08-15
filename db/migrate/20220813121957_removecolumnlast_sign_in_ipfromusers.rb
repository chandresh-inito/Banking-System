class RemovecolumnlastSignInIpfromusers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users , :last_sign_in_ip
  end
end

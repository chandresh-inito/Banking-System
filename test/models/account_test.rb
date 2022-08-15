require 'test_helper.rb'

class AccountTest < ActiveSupport::TestCase

    test "saving_account_should_be_valid" do
        @user  = User.create(first_name: "abdwefsddsqwec", last_name: "asdf" , password: "12334456" , email: "adssd2@gmail.com" , dob: "16/12/2000".to_time )
        @branch = Branch.create(name: "Kormangala" , address: "1st block" , pincode: 123456)
        @account = Account.create(user_id: @user.id , branch_id: @branch.id , amount: 10006 , account_type: "Saving Account" , account_number: 12345678)
        assert @account.valid?
    end


    test "saving_account_should_have_opening_amount_more_than_10000" do
        @user  = User.create(first_name: "abdwefsddsqwec", last_name: "asdf" , password: "12334456" , email: "adssd2@gmail.com" , dob: "16/12/2000".to_time )
        @branch = Branch.create(name: "Kormangala" , address: "1st block" , pincode: 123456)
        @account = Account.create(user_id: @user.id , branch_id: @branch.id , amount: 100 , account_type: "Saving Account", account_number: 12345678)
        assert_not @account.valid?
    end

    test "current_account_should_have_opening_account_amount_more_than_100000" do
        @user  = User.create(first_name: "abdwefsddsqwec", last_name: "asdf" , password: "12334456" , email: "adssd2@gmail.com", dob: "16/12/2000".to_time)
        @branch = Branch.create(name: "Kormangala" , address: "1st block" , pincode: 123456)
        @account = Account.create(user_id: @user.id , branch_id: @branch.id , amount: 5000 , account_type: "Current Account", account_number: 12345678)
        assert_not @account.valid?
    end

    test "age_for_current_account_greater_than_18" do 
        @user  = User.create(first_name: "abdwefsddsqwec", last_name: "asdf" , password: "12334456" , email: "adssd2@gmail.com" , dob: "16/12/2005".to_time )
        @branch = Branch.create(name: "Kormangala" , address: "1st block" , pincode: 123456)
        @account = Account.create(user_id: @user.id , branch_id: @branch.id , amount: 100001 , account_type: "Current Account", account_number: 12345678)
        assert_not @account.valid?
    end

end

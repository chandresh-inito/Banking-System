require 'test_helper.rb'

class LoanTest < ActiveSupport::TestCase

  test "age_should_be_greate_than_25_for_loan_account" do
    @user  = User.create(first_name: "abdwefsddsqwec", last_name: "asdf" , password: "12334456" , email: "adssd2@gmail.com",  dob: "16/12/2000".to_time)
    @branch = Branch.create(name: "Kormangala" , address: "1st block" , pincode: 123456)
    @account = Account.create(user_id: @user.id , branch_id: @branch.id  , account_type: "Loan Account" , amount: 500000,  account_number: 12345678)
    assert_not @account.valid?
  end

  test "home_car_personal_business_loan_is_valid_loan_type" do
    @user  = User.create(first_name: "abdwefsddsqwec", last_name: "asdf" , password: "12334456" , email: "adssd2@gmail.com",  dob: "16/12/1970".to_time)
    @branch = Branch.create(name: "Kormangala" , address: "1st block" , pincode: 123456)
    @account = Account.create(user_id: @user.id , branch_id: @branch.id , amount: 500000,  account_type: "Loan Account" , account_number: 12345678)
    @loan = Loan.create(loan_type: "abc" , amount: 500000 , duration: 25 ,account_id: @account.id)
    assert_not @loan.valid?
  end

  test "loan_amount_should_be_greater_than_5lacks" do
    @user  = User.create(first_name: "abdwefsddsqwec", last_name: "asdf" , password: "12334456" , email: "adssd2@gmail.com",  dob: "16/12/1970".to_time)
    @branch = Branch.create(name: "Kormangala" , address: "1st block" , pincode: 123456)
    @account = Account.create(user_id: @user.id , branch_id: @branch.id  , amount: 500000,  account_type: "Loan Account" , account_number: 12345678)
    @loan = Loan.create(loan_type: "abc" , amount: 5000 , duration: 25 ,account_id: @account.id)
    assert_not @loan.valid?
  end

  test "loan_duration_greater_than_2_years" do
    @user  = User.create(first_name: "abdwefsddsqwec", last_name: "asdf" , password: "12334456" , email: "adssd2@gmail.com",  dob: "16/12/1970".to_time)
    @branch = Branch.create(name: "Kormangala" , address: "1st block" , pincode: 123456)
    @account = Account.create(user_id: @user.id , branch_id: @branch.id  , amount: 500000,  account_type: "Loan Account" , account_number: 12345678)
    @loan = Loan.create(loan_type: "abc" , amount: 500000 , duration: 15 ,account_id: @account.id)
    assert_not @loan.valid?
  end

end
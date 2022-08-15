require 'test_helper.rb'

class TransactionTest < ActiveSupport::TestCase

  test "transaction_amount_should_be_positive" do
    @user  = User.create(first_name: "abdwefsddsqwec", last_name: "asdf" , password: "12334456" , email: "adssd2@gmail.com" , dob: "16/12/2000".to_time )
    @branch = Branch.create(name: "Kormangala" , address: "1st block" , pincode: 123456)
    @account = Account.create(user_id: @user.id , branch_id: @branch.id , amount: 10006 , account_type: "Saving Account" , account_number: 12345678)
    @transaction = Transaction.create(medium_of_transaction: "direct" , amount: -10 , credit_debit: "credit" ,account_id:@account.id )
    assert_not @transaction.valid?
  end

  test "medium_of_transaction_should_be_valid" do
    @user  = User.create(first_name: "abdwefsddsqwec", last_name: "asdf" , password: "12334456" , email: "adssd2@gmail.com" , dob: "16/12/2000".to_time )
    @branch = Branch.create(name: "Kormangala" , address: "1st block" , pincode: 123456)
    @account = Account.create(user_id: @user.id , branch_id: @branch.id , amount: 10006 , account_type: "Saving Account" , account_number: 12345678)
    @transaction = Transaction.create(medium_of_transaction: "abc" , amount: 10 , credit_debit: "credit" ,account_id:@account.id )
    assert_not @transaction.valid?
  end

  test "credit_debit_should_be_valid" do
    @user  = User.create(first_name: "abdwefsddsqwec", last_name: "asdf" , password: "12334456" , email: "adssd2@gmail.com" , dob: "16/12/2000".to_time )
    @branch = Branch.create(name: "Kormangala" , address: "1st block" , pincode: 123456)
    @account = Account.create(user_id: @user.id , branch_id: @branch.id , amount: 10006 , account_type: "Saving Account" , account_number: 12345678)
    @transaction = Transaction.create(medium_of_transaction: "atm" , amount: 10 , credit_debit: "abc" ,account_id:@account.id )
    assert_not @transaction.valid?
  end



end

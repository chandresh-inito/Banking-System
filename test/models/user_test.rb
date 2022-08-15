require 'test_helper.rb'

class UserTest < ActiveSupport::TestCase

  test "user_should_be_valid" do
    @user  = User.create(first_name: "abdwefsddsqwec", last_name: "asdf" , password: "12334456" , email: "adssd2@gmail.com",  dob: "16/12/2000")
    assert @user.valid?
  end

end

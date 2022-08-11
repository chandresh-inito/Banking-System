class UserController<ApplicationController
    
    def show
        @user = User.find_by[:id]
    end
    
end
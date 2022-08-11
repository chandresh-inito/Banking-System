class AdminController<ApplicationController

    def index
    end

    def show
        # byebug
        user_id = params[:id]
        @user = User.find(user_id)
    end

    def user_transactions
    end

    def destroy
        # byebug
        user_id = params[:id]
        @user = User.find(user_id)
        @user.destroy 
        redirect_to admin_index_path
    end

    def search
        # byebug
        if params[:user].present?
            @users = User.search(params[:user])
            # @users = current_user.except_current_user(@users)
            if @users
                respond_to do |format|
                    format.js { render partial: 'admin/user_result' }
                end
            else
                respond_to do |format|
                    flash.now[:alert] = "Couldn't find user"
                    format.js { render partial: 'admin/user_result' }
                end
            end    
        else
            respond_to do |format|
            flash.now[:alert] = "Please enter a user name or email to search"
            format.js { render partial: 'admin/user_result' }
            end
        end
    end

end
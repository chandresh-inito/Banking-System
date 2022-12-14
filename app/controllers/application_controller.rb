class ApplicationController < ActionController::Base
        # include DeviseTokenAuth::Concerns::SetUserByToken
    before_action :authenticate_user!
    before_action :configure_permitted_parameters, if: :devise_controller?

    def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :dob, :email, :password , :password_confirmation])
    end

    protect_from_forgery with: :exception

end

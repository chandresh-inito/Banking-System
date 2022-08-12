class Api::SessionsController < DeviseTokenAuth::SessionsController
 

    skip_before_action :authenticate_user!
    skip_before_action :verify_authenticity_token
    protect_from_forgery with: :null_session
    # after_action :set_csrf_header, only: [:create]
    

    
    
    

end
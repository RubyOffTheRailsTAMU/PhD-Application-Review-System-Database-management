class ApplicationController < ActionController::Base
    layout 'application'
    helper_method :current_user, :logged_in?
    def current_user
        @current_user ||= User.find_by(user_email: session[:user_email]) if session[:user_token]
    end
    def logged_in?
        !!current_user
    end
    def require_user
        if !logged_in?
            flash[:alert] = "You must be logged in to perform that action."
            redirect_to root_path
        end
    end
end

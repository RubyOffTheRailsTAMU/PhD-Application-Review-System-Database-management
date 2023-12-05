class WelcomeController < ApplicationController
  def create
    user = User.find_by(user_name: params[:session][:user_name])
    if user && params[:session][:user_name] == "admin" && user.authenticate(params[:session][:password])
        session[:user_token] = "admin_token_placeholder"
        session[:user_email] = user.user_email
        current_user
        redirect_to '/uploads/new'
      else
        session[:alert] = "Wrong Admin Credentails"
        redirect_to root_path
      end
  end

  def destroy
    reset_session
    redirect_to root_path
  end
  
end

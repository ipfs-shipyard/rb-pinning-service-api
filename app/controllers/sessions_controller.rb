class SessionsController < ApplicationController
  def new
    redirect_to root_path if logged_in?
  end

  def create
    # TODO parse bearer token # authenticate_with_http_token { |token, _| User.find_by(api_token: token) }
    token = params[:access_token]
    @user = User.find_by_access_token(token)
    if @user
      cookies.permanent.signed[:user_id] = @user.id
      redirect_to root_path
    else
      redirect_to login_path
    end
  end

  def destroy
    cookies.delete :user_id
    redirect_to root_path
  end
end

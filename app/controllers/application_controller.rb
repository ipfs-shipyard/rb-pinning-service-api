class ApplicationController < ActionController::Base
  include Pagy::Backend

  helper_method :logged_in?
  def logged_in?
    !current_user.nil?
  end

  def current_user
    @current_user ||= (cookies.permanent.signed[:user_id] && User.find_by(id: cookies.permanent.signed[:user_id]))
  end

  def authenticate_user!
    return if logged_in?
    respond_to do |format|
      format.html { redirect_to login_path }
      format.json { render json: { "error" => {"reason" => "UNAUTHORIZED", "details" => "Access token is missing or invalid"} }, status: :unauthorized }
    end
  end
end

class Api::V1::ApplicationController < ApplicationController
  skip_before_action :verify_authenticity_token

  def current_user
    @current_user ||= authenticate_with_http_token { |token, _| User.find_by(access_token: token) }
  end
end

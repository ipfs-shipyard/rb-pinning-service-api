class Api::V1::ApplicationController < ApplicationController
  skip_before_action :verify_authenticity_token

  rescue_from ActiveRecord::RecordNotFound do |exception|
    handle_error(:not_found, 'The specified resource was not found')
  end

  rescue_from ActiveRecord::RecordInvalid do |exception|
    handle_error(:unprocessable_entity, 'Invalid or missing parameters')
  end

  def current_user
    @current_user ||= authenticate_with_http_token { |token, _| User.find_by(access_token: token) }
  end

  def handle_error(status, message)
    render status: status, json: { "error" => {
      "reason"  => status.upcase,
      "details" => message
      }
    }
  end
end

# frozen_string_literal: true
require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  test 'creates a user' do
    post '/api/v1/users', params: {email: 'andrew.nesbitt@protocol.ai'}
    assert_response :success
    assert_template 'users/create'
  end

  test 'destroys current_user' do
    @user = User.create(email: 'test@foobar.com')

    delete '/api/v1/users', headers: {Authorization:  "Bearer #{@user.access_token}"}
    assert_response :success
  end
end

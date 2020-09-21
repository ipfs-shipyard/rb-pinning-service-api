# frozen_string_literal: true
require 'test_helper'

class PinsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = User.create(email: 'test@foobar.com')
  end

  test 'creates a pin' do
    post '/api/v1/pins', params: {cid: 'QmUwUSmn9tCVv79WvydNfbE29YwZWy9ZNadWwtQtFKZM3E'}, headers: {Authorization:  "Bearer #{@user.access_token}"}
    assert_response :success
    assert_template 'pins/create'
  end

  test 'list pins for a user' do
    get '/api/v1/pins', headers: {Authorization:  "Bearer #{@user.access_token}"}
    assert_response :success
    assert_template 'pins/index'
  end

  test 'get a pin' do
    @pin = @user.pins.create(cid: 'QmUwUSmn9tCVv79WvydNfbE29YwZWy9ZNadWwtQtFKZM3E')
    get "/api/v1/pins/#{@pin.id}", headers: {Authorization:  "Bearer #{@user.access_token}"}
    assert_response :success
    assert_template 'pins/show'
  end

  test 'replace a pin' do
    @pin = @user.pins.create(cid: 'QmUwUSmn9tCVv79WvydNfbE29YwZWy9ZNadWwtQtFKZM3E')
    post "/api/v1/pins/#{@pin.id}", params: {cid: 'QmUwUSmn9tCVv79WvydNfbE29YwZWy9ZNadWwtQtFKZM3E'},  headers: {Authorization:  "Bearer #{@user.access_token}"}
    assert_response :success
    assert_template 'pins/update'
  end

  test 'destroys a pin' do
    @pin = @user.pins.create(cid: 'QmUwUSmn9tCVv79WvydNfbE29YwZWy9ZNadWwtQtFKZM3E')
    delete "/api/v1/pins/#{@pin.id}", headers: {Authorization:  "Bearer #{@user.access_token}"}
    assert_response :success
  end
end

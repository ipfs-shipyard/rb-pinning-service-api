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

  test 'pin creation requires a user' do
    post '/api/v1/pins', params: {cid: 'QmUwUSmn9tCVv79WvydNfbE29YwZWy9ZNadWwtQtFKZM3E'}
    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal json, {"error"=>{"reason"=>"UNAUTHORIZED", "details"=>"Access token is missing or invalid"}}
  end

  test 'getting a pin requires a user' do
    @pin = @user.pins.create(cid: 'QmUwUSmn9tCVv79WvydNfbE29YwZWy9ZNadWwtQtFKZM3E')
    get "/api/v1/pins/#{@pin.id}", params: {cid: 'QmUwUSmn9tCVv79WvydNfbE29YwZWy9ZNadWwtQtFKZM3E'}
    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal json, {"error"=>{"reason"=>"UNAUTHORIZED", "details"=>"Access token is missing or invalid"}}
  end

  test 'getting a pin requires pin exists' do
    get '/api/v1/pins/999', params: {cid: 'QmUwUSmn9tCVv79WvydNfbE29YwZWy9ZNadWwtQtFKZM3E'},  headers: {Authorization:  "Bearer #{@user.access_token}"}
    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal json, {"error" => {"reason" => "NOT_FOUND","details" =>"The specified resource was not found"}}
  end

  test 'pin creating requires cid' do
    post '/api/v1/pins', params: {}, headers: {Authorization:  "Bearer #{@user.access_token}"}
    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal json, {"error" => {"reason" => "UNPROCESSABLE_ENTITY", "details" =>"Invalid or missing parameters"}}
  end
end

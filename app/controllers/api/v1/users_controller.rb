class Api::V1::UsersController < Api::V1::ApplicationController
  before_action :authenticate_user!, only: :destroy

  def create
    @user = User.new(user_params)
    @user.save!
  end

  def destroy
    current_user.destroy
    head :accepted
  end

  private

  def user_params
    params.permit(:email)
  end
end

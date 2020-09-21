class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def show
    @user = current_user
  end

  def create
    @user = User.new(email: params.require(:user).permit(:email)[:email])
    if @user.save
      cookies.permanent.signed[:user_id] = @user.id
      redirect_to account_path
    else
      redirect_to new_user_path
    end
  end

  def destroy
    current_user.destroy
    redirect_to root_path
  end
end

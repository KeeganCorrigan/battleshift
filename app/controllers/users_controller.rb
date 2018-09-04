class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:id] = @user.id
      RegistrationNotifier.confirmation(@user).deliver_now
      redirect_to dashboard_path
    else
      flash.now[:alert] = @user.errors.full_messages.join("<br>").html_safe
      render :new
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end

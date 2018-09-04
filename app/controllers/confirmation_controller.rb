class ConfirmationController < ApplicationController
  def update
    @user = User.find_by(auth_token: params[:auth_token])
    session[:id] = @user.id

    @user.confirm_registration

    redirect_to confirmed_path
  end

  def show

  end
end

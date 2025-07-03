class SessionsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    redirect_to root_path if user_signed_in?
  end

  def create
    user = User.authenticate_by(email: params[:email], password: params[:password])
    
    if user
      user.update_sign_in_info!(request.remote_ip)
      sign_in(user)
      redirect_back_or_to(root_path)
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    sign_out
    redirect_to root_path, notice: "Signed out successfully"
  end
end
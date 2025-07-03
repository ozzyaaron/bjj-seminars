class RegistrationsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :check_rate_limit, only: [:create]

  def new
    redirect_to root_path if user_signed_in?
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.last_sign_in_ip = request.remote_ip
    
    if @user.save
      @user.update_sign_in_info!(request.remote_ip)
      sign_in(@user)
      redirect_to root_path, notice: "Welcome! Your account has been created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def check_rate_limit
    # Basic IP-based rate limiting - one account per IP per day
    if User.where("created_at > ? AND last_sign_in_ip = ?", 1.day.ago, request.remote_ip).exists?
      redirect_to new_user_registration_path, 
                  alert: "Account creation limit reached. Only one account per day allowed."
    end
  end
end
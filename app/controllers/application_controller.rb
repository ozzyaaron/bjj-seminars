class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_current_user

  protected

  def authenticate_user!
    unless user_signed_in?
      store_location_for_user
      redirect_to login_path, alert: "Please sign in to continue."
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def user_signed_in?
    current_user.present?
  end
  helper_method :user_signed_in?

  def admin_user?
    current_user&.admin?
  end
  helper_method :admin_user?

  def require_admin!
    unless admin_user?
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end

  def sign_in(user)
    session[:user_id] = user.id
    @current_user = user
  end

  def sign_out
    session.delete(:user_id)
    @current_user = nil
  end

  def store_location_for_user
    session[:user_return_to] = request.original_url if request.get? && !request.xhr?
  end

  def redirect_back_or_to(default_path)
    redirect_to(session.delete(:user_return_to) || default_path)
  end

  private

  def set_current_user
    # Make current_user available to Phlex components
    Current.user = current_user if defined?(Current)
  end
end

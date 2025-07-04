module AuthenticationHelpers
  def sign_in(user)
    if respond_to?(:session)
      session[:user_id] = user.id
    else
      post "/sessions", params: { email: user.email, password: "password" }
    end
  end

  def sign_out
    if respond_to?(:session)
      session.delete(:user_id)
    else
      delete "/sessions"
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end
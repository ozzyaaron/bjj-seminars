module AuthenticationHelpers
  def sign_in(user)
    if respond_to?(:session)
      session[:user_id] = user.id
    else
      # For system tests, actually go through the login process
      visit login_path
      fill_in 'Email address', with: user.email
      fill_in 'Password', with: user.password || 'password123'
      click_button 'Sign in'
    end
  end

  def sign_out
    if respond_to?(:session)
      session.delete(:user_id)
    else
      visit logout_path if page.has_link?('Sign out')
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if respond_to?(:session) && session[:user_id]
  end
end
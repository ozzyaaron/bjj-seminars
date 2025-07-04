require 'rails_helper'

RSpec.describe 'User Authentication', type: :system do
  describe 'User registration' do
    it 'allows a new user to register' do
      visit new_registration_path
      
      fill_in 'Name', with: 'John Doe'
      fill_in 'Email', with: 'john@example.com'
      fill_in 'Password', with: 'password'
      fill_in 'Password confirmation', with: 'password'
      select 'Blue', from: 'Belt rank'
      
      click_button 'Create Account'
      
      expect(page).to have_content('Welcome! Your account has been created successfully.')
      expect(page).to have_current_path(root_path)
    end
    
    it 'prevents registration with invalid data' do
      visit new_registration_path
      
      fill_in 'Name', with: ''
      fill_in 'Email', with: 'invalid-email'
      fill_in 'Password', with: 'short'
      fill_in 'Password confirmation', with: 'different'
      
      click_button 'Create Account'
      
      expect(page).to have_content("Name can't be blank")
      expect(page).to have_content('Email is not a valid email address')
      expect(page).to have_content('Password is too short')
    end
  end
  
  describe 'User sign in' do
    let(:user) { create(:user, email: 'test@example.com', password: 'password') }
    
    it 'allows existing user to sign in' do
      visit new_session_path
      
      fill_in 'Email', with: 'test@example.com'
      fill_in 'Password', with: 'password'
      
      click_button 'Sign In'
      
      expect(page).to have_current_path(root_path)
      expect(page).to have_content('Sign Out')
    end
    
    it 'prevents sign in with invalid credentials' do
      visit new_session_path
      
      fill_in 'Email', with: 'test@example.com'
      fill_in 'Password', with: 'wrong-password'
      
      click_button 'Sign In'
      
      expect(page).to have_content('Invalid email or password')
      expect(page).to have_current_path(sessions_path)
    end
  end
  
  describe 'User sign out' do
    let(:user) { create(:user) }
    
    it 'allows signed in user to sign out' do
      sign_in(user)
      visit root_path
      
      click_link 'Sign Out'
      
      expect(page).to have_content('You have been signed out successfully.')
      expect(page).to have_content('Sign In')
    end
  end
  
  describe 'Authentication protection' do
    it 'redirects to sign in when accessing protected pages' do
      visit new_seminar_path
      
      expect(page).to have_current_path(new_session_path)
      expect(page).to have_content('You must be signed in to continue.')
    end
    
    it 'redirects back to intended page after sign in' do
      user = create(:user, email: 'test@example.com', password: 'password')
      
      visit new_seminar_path
      expect(page).to have_current_path(new_session_path)
      
      fill_in 'Email', with: 'test@example.com'
      fill_in 'Password', with: 'password'
      click_button 'Sign In'
      
      expect(page).to have_current_path(new_seminar_path)
    end
  end
end
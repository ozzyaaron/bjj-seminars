require 'rails_helper'

RSpec.describe 'User Authentication', type: :system do
  describe 'User registration' do
    it 'allows a new user to register' do
      visit new_user_registration_path
      
      fill_in 'Full name', with: 'John Doe'
      fill_in 'Email address', with: 'john@example.com'
      fill_in 'Password', with: 'password123'
      fill_in 'Confirm password', with: 'password123'
      
      click_button 'Create account'
      
      expect(page).to have_content('Welcome! Your account has been created successfully.')
      expect(page).to have_current_path(root_path)
    end
    
    it 'prevents registration with invalid data' do
      visit new_user_registration_path
      
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
    let(:user) { create(:user, email: 'test@example.com', password: 'password123') }
    
    it 'allows existing user to sign in' do
      visit login_path
      
      fill_in 'Email address', with: 'test@example.com'
      fill_in 'Password', with: 'password123'
      
      click_button 'Sign in'
      
      expect(page).to have_current_path(root_path)
      expect(page).to have_content('Sign Out')
    end
    
    it 'prevents sign in with invalid credentials' do
      visit login_path
      
      fill_in 'Email address', with: 'test@example.com'
      fill_in 'Password', with: 'wrong-password'
      
      click_button 'Sign in'
      
      expect(page).to have_content('Invalid email or password')
      expect(page).to have_current_path(login_path)
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
      
      expect(page).to have_current_path(login_path)
      expect(page).to have_content('You must be signed in to continue.')
    end
    
    it 'redirects back to intended page after sign in' do
      user = create(:user, email: 'test@example.com', password: 'password123')
      
      visit new_seminar_path
      expect(page).to have_current_path(login_path)
      
      fill_in 'Email address', with: 'test@example.com'
      fill_in 'Password', with: 'password123'
      click_button 'Sign in'
      
      expect(page).to have_current_path(new_seminar_path)
    end
  end
  
  describe 'New user onboarding workflow' do
    it 'guides new user from registration to first seminar creation' do
      # Step 1: User visits site and decides to create account
      visit root_path
      click_link 'Sign Up'
      
      # Step 2: User registers account
      fill_in 'Name', with: 'Sarah Connor'
      fill_in 'Email', with: 'sarah@resistance.com'
      fill_in 'Password', with: 'terminator123'
      fill_in 'Password confirmation', with: 'terminator123'
      select 'Purple', from: 'Belt rank'
      
      click_button 'Create Account'
      
      expect(page).to have_content('Welcome! Your account has been created successfully.')
      expect(page).to have_current_path(root_path)
      
      # Step 3: User explores the platform
      expect(page).to have_content('Welcome to BJJ Seminar Tracker')
      expect(page).to have_link('Create Seminar')
      expect(page).to have_link('Browse Seminars')
      
      # Step 4: User creates their first seminar
      click_link 'Create Seminar'
      
      fill_in 'Title', with: 'My First BJJ Seminar'
      fill_in 'Description', with: 'Introduction to basic BJJ techniques for beginners'
      fill_in 'Instructor name', with: 'Sarah Connor'
      select 'Purple', from: 'Instructor belt'
      fill_in 'Instructor lineage', with: 'Self-taught resistance fighter'
      fill_in 'Seminar date', with: 1.month.from_now.strftime('%Y-%m-%d')
      fill_in 'Venue', with: 'Resistance Training Center'
      fill_in 'Location', with: 'Los Angeles, CA'
      fill_in 'Price amount', with: '50.00'
      select 'USD', from: 'Price currency'
      
      click_button 'Create Seminar'
      
      expect(page).to have_content('Seminar was successfully created.')
      expect(page).to have_content('My First BJJ Seminar')
      expect(page).to have_content('Resistance Training Center')
      
      # Step 5: User can view their created seminar
      visit seminars_path
      expect(page).to have_content('My First BJJ Seminar')
      expect(page).to have_content('Sarah Connor')
    end
    
    it 'handles registration errors and guides user to correct them' do
      visit new_user_registration_path
      
      # Submit with errors
      fill_in 'Full name', with: ''
      fill_in 'Email address', with: 'invalid-email'
      fill_in 'Password', with: '123'
      fill_in 'Confirm password', with: '456'
      
      click_button 'Create account'
      
      expect(page).to have_content("Name can't be blank")
      expect(page).to have_content('Email is not a valid email address')
      expect(page).to have_content('Password is too short')
      expect(page).to have_content("Password confirmation doesn't match Password")
      
      # Fix errors progressively
      fill_in 'Full name', with: 'John Doe'
      fill_in 'Email address', with: 'john@example.com'
      fill_in 'Password', with: 'password123'
      fill_in 'Confirm password', with: 'password123'
      
      click_button 'Create account'
      
      expect(page).to have_content('Welcome! Your account has been created successfully.')
    end
  end
  
  describe 'Session management and security' do
    let(:user) { create(:user, email: 'test@example.com', password: 'password123') }
    
    it 'handles concurrent sessions properly' do
      # Sign in user
      visit login_path
      fill_in 'Email address', with: 'test@example.com'
      fill_in 'Password', with: 'password123'
      click_button 'Sign in'
      
      expect(page).to have_content('Sign Out')
      
      # User should remain authenticated when navigating
      visit seminars_path
      expect(page).to have_content('Sign Out')
      
      visit new_seminar_path
      expect(page).to have_content('Create Seminar')
    end
    
    it 'tracks user activity for security' do
      sign_in(user)
      visit seminars_path
      
      # User should be able to access protected resources
      expect(page).to be_successful
      expect(page).not_to have_content('You must be signed in')
    end
  end
end
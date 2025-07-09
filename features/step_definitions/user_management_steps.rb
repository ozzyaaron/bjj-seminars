Given('I am on the registration page') do
  visit new_user_registration_path
end

Given('I am on the login page') do
  visit login_path
end

Given('there is a user with email {string} and password {string}') do |email, password|
  @user = create(:user, email: email, password: password)
end

Given('there is a user with email {string}') do |email|
  @user = create(:user, email: email)
end

Given('I am signed in as {string}') do |email|
  @current_user = create(:user, email: email)
  visit login_path
  fill_in 'Email address', with: email
  fill_in 'Password', with: 'password123'
  click_button 'Sign in'
end

Given('I am signed in as a regular user') do
  @current_user = create(:user, admin: false)
  visit login_path
  fill_in 'Email address', with: @current_user.email
  fill_in 'Password', with: 'password123'
  click_button 'Sign in'
end

Given('I am signed in as an admin user') do
  @current_user = create(:user, admin: true)
  visit login_path
  fill_in 'Email address', with: @current_user.email
  fill_in 'Password', with: 'password123'
  click_button 'Sign in'
end

Given('I am not signed in') do
  visit logout_path if page.has_link?('Sign out')
end

When('I fill in {string} with {string}') do |field, value|
  fill_in field, with: value
end

When('I click {string}') do |button_text|
  click_button button_text
end

When('I visit the new seminar page') do
  visit new_seminar_path
end

When('I visit the teams page') do
  visit teams_path
end

When('I visit the players page') do
  visit players_path
end

Then('I should be redirected to the home page') do
  expect(current_path).to eq(root_path)
end

Then('I should remain on the registration page') do
  expect(current_path).to eq(user_registration_path)
end

Then('I should remain on the login page') do
  expect(current_path).to eq(login_path)
end

Then('I should be redirected to the login page') do
  expect(current_path).to eq(login_path)
end

Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end

Then('I should not see {string}') do |text|
  expect(page).not_to have_content(text)
end

Then('I should see {string} button') do |button_text|
  expect(page).to have_button(button_text)
end

Then('I should not see {string} button') do |button_text|
  expect(page).not_to have_button(button_text)
end
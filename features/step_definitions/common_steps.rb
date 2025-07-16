# Common step definitions

When('I fill in {string} with {string}') do |field, value|
  fill_in field, with: value
end

When('I click {string}') do |button|
  click_on button
end

Given('I am signed in as {string}') do |email|
  user = User.find_by(email: email) || FactoryBot.create(:user, email: email, password: 'password123')
  visit login_path
  fill_in 'email', with: email
  fill_in 'password', with: 'password123'
  click_on 'Sign in'
end
# Step definitions for user authentication

Given('I am on the signup page') do
  visit new_user_registration_path
end

Given('I am on the login page') do
  visit login_path
end

Given('a user exists with email {string}') do |email|
  FactoryBot.create(:user, email: email)
end

Given('I have an account with email {string} and password {string}') do |email, password|
  FactoryBot.create(:user, email: email, password: password, password_confirmation: password)
end

When('I try to visit the new seminar page') do
  visit new_seminar_path
end

Then('I should be redirected to the home page') do
  expect(current_path).to eq(root_path)
end

Then('I should be redirected to the login page') do
  expect(current_path).to eq(login_path)
end

Then('I should be redirected to the seminar show page') do
  seminar = Seminar.last
  expect(current_path).to eq(seminar_path(seminar))
end

Then('I should remain on the signup page') do
  expect(current_path).to eq(user_registration_path)
end

Then('I should remain on the login page') do
  expect(current_path).to eq(login_path)
end

Then('I should be on the new seminar page') do
  expect(current_path).to eq(new_seminar_path)
end

When('I select {string} from {string}') do |option, field|
  select option, from: field
end

Given('the following teams exist:') do |table|
  table.hashes.each do |row|
    Team.create!(name: row['name'])
  end
end

Given('the following players exist:') do |table|
  table.hashes.each do |row|
    team = Team.find_by!(name: row['team'])
    Player.create!(
      name: row['name'],
      nationality: 'Brazil', # Default nationality
      bio: "#{row['name']} is a #{row['rank']} under #{team.name}",
      team: team
    )
  end
end
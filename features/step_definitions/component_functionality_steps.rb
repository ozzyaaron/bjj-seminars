Given('there are seminars with instructors') do
  user = FactoryBot.create(:user)
  team = FactoryBot.create(:team)
  player = FactoryBot.create(:player, team: team)
  seminar = FactoryBot.create(:seminar, :future, user: user)
  seminar.players << player
end

When('I visit the seminars page') do
  visit seminars_path
end

Then('I should see {string} as the page heading') do |heading|
  expect(page).to have_content(heading)
end

Then('I should see seminar cards displaying seminar information') do
  seminar = Seminar.first
  expect(page).to have_content(seminar.title)
  expect(page).to have_content("View Details")
end

Then('I should see search and filter options') do
  expect(page).to have_field('Search')
  expect(page).to have_field('Location')
  expect(page).to have_field('Instructor')
  expect(page).to have_button('Search')
end

Given('there are teams with players') do
  team = FactoryBot.create(:team)
  FactoryBot.create(:player, team: team)
end

When('I visit the teams page') do
  visit teams_path
end

Then('I should see team cards with team information') do
  team = Team.first
  expect(page).to have_content(team.name)
  expect(page).to have_content("View Team")
end

Then('I should see a search option for teams') do
  expect(page).to have_field('Search Teams')
  expect(page).to have_button('Search')
end

Given('there are players in teams') do
  team = FactoryBot.create(:team)
  FactoryBot.create(:player, team: team, belt_rank: 'black')
end

When('I visit the players page') do
  visit players_path
end

Then('I should see player information with belt ranks') do
  player = Player.first
  expect(page).to have_content(player.name)
  expect(page).to have_content(player.belt_rank.humanize)
end

Then('I should see filter options for teams and belt ranks') do
  expect(page).to have_select('Team')
  expect(page).to have_select('Belt Rank')
  expect(page).to have_button('Search')
end

When('I visit the login page') do
  visit login_path
end

Then('I should see email and password fields') do
  expect(page).to have_field('Email address')
  expect(page).to have_field('Password')
end

Then('I should see a {string} button') do |button_text|
  expect(page).to have_button(button_text)
end

When('I visit the registration page') do
  visit new_user_registration_path
end

When('I visit the new seminar page') do
  visit new_seminar_path
end

Then('I should see form sections for basic information, date & time, location, images, and instructors') do
  expect(page).to have_content("Basic Information")
  expect(page).to have_content("Date & Time")
  expect(page).to have_content("Location")
  expect(page).to have_content("Images")
  expect(page).to have_content("Instructors")
end

# Moved to user_management_steps.rb to avoid ambiguity
# Given('I am signed in as an admin user') do
#   @current_admin = FactoryBot.create(:user, :admin)
#   visit login_path
#   fill_in 'Email address', with: @current_admin.email
#   fill_in 'Password', with: 'password123'
#   click_button 'Sign in'
# end

When('I visit the new team page') do
  visit new_team_path
end

Then('I should see team creation form fields') do
  expect(page).to have_field('Team Name')
  expect(page).to have_field('Location')
  expect(page).to have_field('Website')
end

When('I visit the new player page') do
  visit new_player_path
end

Then('I should see player creation form fields including belt rank options') do
  expect(page).to have_field('Full Name')
  expect(page).to have_select('Team')
  expect(page).to have_select('Belt Rank')
  expect(page).to have_field('About the Player')
end
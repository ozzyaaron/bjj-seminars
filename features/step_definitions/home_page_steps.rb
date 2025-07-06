When('I visit the home page') do
  visit root_path
end

Then('I should see the application title {string}') do |title|
  expect(page).to have_content(title)
end

Then('I should see the tagline {string}') do |tagline|
  expect(page).to have_content(tagline)
end

Then('I should see navigation links for {string}, {string}, and {string}') do |link1, link2, link3|
  expect(page).to have_link(link1)
  expect(page).to have_link(link2)
  expect(page).to have_link(link3)
end

Then('I should see {string} and {string} links') do |link1, link2|
  expect(page).to have_link(link1)
  expect(page).to have_link(link2)
end

Then('I should see a call-to-action section encouraging registration') do
  expect(page).to have_content("Ready to start tracking?")
  expect(page).to have_content("Join the community today")
end

Given('there are upcoming seminars with instructors') do
  user = FactoryBot.create(:user)
  team = FactoryBot.create(:team)
  player = FactoryBot.create(:player, team: team)
  seminar = FactoryBot.create(:seminar, :future, user: user)
  seminar.players << player
end

Then('I should see a {string} section') do |section_name|
  expect(page).to have_content(section_name)
end

Then('I should see seminar cards with titles and instructor information') do
  seminar = Seminar.first
  expect(page).to have_content(seminar.title)
  expect(page).to have_content("Instructors:")
end

Then('I should see a {string} link') do |link_text|
  expect(page).to have_link(link_text)
end

Given('I am signed in as a regular user') do
  @current_user = FactoryBot.create(:user)
  visit login_path
  fill_in 'Email address', with: @current_user.email
  fill_in 'Password', with: 'password123'
  click_button 'Sign in'
end

Then('I should see an {string} button') do |button_text|
  expect(page).to have_link(button_text)
end

Then('I should not see the registration call-to-action section') do
  expect(page).not_to have_content("Ready to start tracking?")
end

Given('there are no upcoming seminars') do
  # Ensure no seminars exist
  Seminar.delete_all
end

Then('I should not see a {string} section') do |section_name|
  expect(page).not_to have_content(section_name)
end

Then('I should still see the main application content and navigation') do
  expect(page).to have_content("BJJ Seminar Tracker")
  expect(page).to have_link("Seminars")
  expect(page).to have_link("Teams")
  expect(page).to have_link("Players")
end
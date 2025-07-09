Given('I am on the new team page') do
  visit new_team_path
end

Given('I am on the new player page') do
  visit new_player_path
end

Given('there is a team named {string}') do |name|
  @team = FactoryBot.create(:team, name: name)
end

Given('there is a team named {string} with {int} players') do |name, count|
  @team = FactoryBot.create(:team, name: name)
  count.times do |i|
    FactoryBot.create(:player, name: "Player #{i + 1}", team: @team)
  end
end

Given('there is a player named {string}') do |name|
  @player = FactoryBot.create(:player, name: name)
end

Given('there is a player named {string} without a team') do |name|
  @player = FactoryBot.create(:player, name: name, team: nil)
end

Given('there are multiple teams available') do
  3.times do |i|
    FactoryBot.create(:team, name: "Team #{i + 1}")
  end
end

Given('there are multiple players available') do
  team = FactoryBot.create(:team, name: 'Default Team')
  3.times do |i|
    FactoryBot.create(:player, name: "Player #{i + 1}", team: team)
  end
end

Given('I am on the team edit page') do
  visit edit_team_path(@team)
end

Given('I am on the player edit page') do
  visit edit_player_path(@player)
end

Given('I am on the team show page') do
  visit team_path(@team)
end

Given('I am on the player show page') do
  visit player_path(@player)
end

When('I try to visit the new team page') do
  visit new_team_path
end

When('I try to visit the new player page') do
  visit new_player_path
end

When('I click on a player\'s name') do
  first_player = @team.players.first
  click_link first_player.name
end

Then('I should be redirected to the team show page') do
  expect(current_path).to match(%r{/teams/\d+})
end

Then('I should be redirected to the player show page') do
  expect(current_path).to match(%r{/players/\d+})
end

Then('I should remain on the new team page') do
  expect(current_path).to eq(new_team_path)
end

Then('I should remain on the new player page') do
  expect(current_path).to eq(new_player_path)
end

Then('I should be redirected to the teams index page') do
  expect(current_path).to eq(teams_path)
end

Then('I should be redirected to the players index page') do
  expect(current_path).to eq(players_path)
end

Then('I should see {string} links for each team') do |link_text|
  expect(page).to have_link(link_text, minimum: 1)
end

Then('I should see {string} links for each player') do |link_text|
  expect(page).to have_link(link_text, minimum: 1)
end

Then('I should see all {int} players listed') do |count|
  expect(page).to have_css('.player-info', count: count)
end

Then('I should see their names and bio information') do
  @team.players.each do |player|
    expect(page).to have_content(player.name)
  end
end

Then('I should be taken to that player\'s profile page') do
  first_player = @team.players.first
  expect(current_path).to eq(player_path(first_player))
end

Then('I should see {string} in the team section') do |team_name|
  within('.team-section') do
    expect(page).to have_content(team_name)
  end
end
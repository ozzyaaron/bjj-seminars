require 'rails_helper'

RSpec.describe 'Integration Workflows', type: :system do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:team) { create(:team, name: 'Test Academy') }
  let(:player) { create(:player, name: 'Famous Instructor', team: team) }
  
  describe 'Complete seminar lifecycle' do
    it 'follows a seminar from creation to discovery by other users' do
      # Step 1: User signs in and creates a seminar
      sign_in(user)
      
      visit root_path
      click_link 'Create Seminar'
      
      fill_in 'Title', with: 'Guard Passing Masterclass'
      fill_in 'Description', with: 'Comprehensive guard passing techniques for all levels'
      fill_in 'Instructor name', with: player.name
      select 'Black', from: 'Instructor belt'
      fill_in 'Instructor lineage', with: 'Test Lineage'
      fill_in 'Seminar date', with: 2.weeks.from_now.strftime('%Y-%m-%d')
      fill_in 'Venue', with: 'Test Academy Main Location'
      fill_in 'Location', with: 'San Francisco, CA'
      fill_in 'Price amount', with: '120.00'
      select 'USD', from: 'Price currency'
      
      # Associate with player
      select player.name, from: 'Featured Players'
      
      click_button 'Create Seminar'
      
      expect(page).to have_content('Seminar was successfully created.')
      expect(page).to have_content('Guard Passing Masterclass')
      
      seminar_id = page.current_path.match(/\/seminars\/(\d+)/)[1]
      
      # Step 2: Sign out and verify seminar appears in public listings
      click_link 'Sign Out'
      
      visit seminars_path
      expect(page).to have_content('Guard Passing Masterclass')
      expect(page).to have_content('Famous Instructor')
      expect(page).to have_content('San Francisco, CA')
      
      # Step 3: Another user can discover the seminar through search
      fill_in 'Search seminars...', with: 'Guard Passing'
      click_button 'Search'
      
      expect(page).to have_content('Guard Passing Masterclass')
      
      # Step 4: View detailed seminar information
      click_link 'Guard Passing Masterclass'
      
      expect(page).to have_content('Comprehensive guard passing techniques')
      expect(page).to have_content('$120.00')
      expect(page).to have_content('Test Academy Main Location')
      expect(page).to have_content(player.name)
      
      # Step 5: Navigate to instructor profile
      click_link player.name
      
      expect(page).to have_current_path(player_path(player))
      expect(page).to have_content('Famous Instructor')
      expect(page).to have_content('Test Academy')
      expect(page).to have_content('Guard Passing Masterclass')
      
      # Step 6: Navigate to team profile
      click_link 'Test Academy'
      
      expect(page).to have_current_path(team_path(team))
      expect(page).to have_content('Test Academy')
      expect(page).to have_content('Famous Instructor')
      expect(page).to have_content('Guard Passing Masterclass')
    end
  end
  
  describe 'Admin content management workflow' do
    before { sign_in(admin) }
    
    it 'allows admin to manage the complete content ecosystem' do
      # Step 1: Create a team
      visit teams_path
      click_link 'Add New Team'
      
      fill_in 'Name', with: 'Elite BJJ Academy'
      fill_in 'Location', with: 'Austin, TX'
      fill_in 'Website', with: 'https://elitebjj.com'
      fill_in 'Description', with: 'Premier competition team'
      
      click_button 'Create Team'
      
      expect(page).to have_content('Team created successfully')
      team_id = page.current_path.match(/\/teams\/(\d+)/)[1]
      
      # Step 2: Add players to the team
      visit players_path
      click_link 'Add New Player'
      
      fill_in 'Name', with: 'Elite Competitor'
      select 'Elite BJJ Academy', from: 'Team'
      select 'Black', from: 'Belt rank'
      fill_in 'Biography', with: 'World champion competitor'
      
      click_button 'Create Player'
      
      expect(page).to have_content('Player created successfully')
      player_id = page.current_path.match(/\/players\/(\d+)/)[1]
      
      # Step 3: Verify team-player relationship
      visit team_path(team_id)
      
      expect(page).to have_content('Elite Competitor')
      expect(page).to have_content('1 member')
      
      # Step 4: Create seminar featuring the player
      visit new_seminar_path
      
      fill_in 'Title', with: 'Competition Prep Seminar'
      fill_in 'Description', with: 'Get ready for your next competition'
      fill_in 'Instructor name', with: 'Elite Competitor'
      select 'Black', from: 'Instructor belt'
      fill_in 'Seminar date', with: 1.month.from_now.strftime('%Y-%m-%d')
      fill_in 'Venue', with: 'Elite BJJ Academy'
      fill_in 'Location', with: 'Austin, TX'
      fill_in 'Price amount', with: '150.00'
      
      select 'Elite Competitor', from: 'Featured Players'
      
      click_button 'Create Seminar'
      
      expect(page).to have_content('Seminar was successfully created.')
      
      # Step 5: Verify all connections work
      visit player_path(player_id)
      expect(page).to have_content('Competition Prep Seminar')
      
      visit team_path(team_id)
      expect(page).to have_content('Competition Prep Seminar')
      
      # Step 6: Update content and verify changes propagate
      visit edit_player_path(player_id)
      
      fill_in 'Biography', with: 'Multiple-time world champion and instructor'
      click_button 'Update Player'
      
      # Check that biography update appears everywhere
      visit team_path(team_id)
      expect(page).to have_content('Multiple-time world champion')
    end
  end
  
  describe 'User notification and discovery integration' do
    let(:other_user) { create(:user, email: 'other@example.com') }
    
    it 'integrates notification system with seminar creation and discovery' do
      # Step 1: User sets up notifications
      sign_in(user)
      
      visit notifications_path
      click_link 'Set Up Notifications'
      
      fill_in 'City', with: 'Los Angeles'
      select player.name, from: 'Players'
      fill_in 'Maximum price', with: '200'
      check 'Active'
      
      click_button 'Create Notification Request'
      
      expect(page).to have_content('Notification preferences saved successfully')
      
      # Step 2: Other user creates matching seminar
      sign_out(user)
      sign_in(other_user)
      
      visit new_seminar_path
      
      fill_in 'Title', with: 'Famous Instructor Workshop'
      fill_in 'Description', with: 'Special workshop with famous instructor'
      fill_in 'Instructor name', with: player.name
      select 'Black', from: 'Instructor belt'
      fill_in 'Seminar date', with: 2.weeks.from_now.strftime('%Y-%m-%d')
      fill_in 'Venue', with: 'LA BJJ Academy'
      fill_in 'Location', with: 'Los Angeles, CA'
      fill_in 'Price amount', with: '175.00'
      
      select player.name, from: 'Featured Players'
      
      click_button 'Create Seminar'
      
      expect(page).to have_content('Seminar was successfully created.')
      
      # Step 3: Original user receives notification
      sign_out(other_user)
      sign_in(user)
      
      visit notifications_path
      
      within('.recent-notifications') do
        expect(page).to have_content('Famous Instructor Workshop')
        expect(page).to have_content('New seminar matching your preferences')
      end
      
      # Step 4: User clicks through from notification to seminar
      click_link 'Famous Instructor Workshop'
      
      expect(page).to have_content('Special workshop with famous instructor')
      expect(page).to have_content('$175.00')
      expect(page).to have_content('LA BJJ Academy')
      
      # Step 5: User explores related content
      click_link player.name
      
      expect(page).to have_current_path(player_path(player))
      expect(page).to have_content('Famous Instructor Workshop')
      
      click_link team.name
      
      expect(page).to have_current_path(team_path(team))
      expect(page).to have_content('Famous Instructor Workshop')
    end
  end
  
  describe 'Search and filter integration' do
    let!(:team1) { create(:team, name: 'Gracie Academy', location: 'California') }
    let!(:team2) { create(:team, name: 'Alliance BJJ', location: 'Georgia') }
    let!(:player1) { create(:player, name: 'Royce Gracie', team: team1, belt_rank: 'red') }
    let!(:player2) { create(:player, name: 'Marcelo Garcia', team: team2, belt_rank: 'black') }
    let!(:seminar1) { create(:seminar, title: 'Gracie Self Defense', instructor_name: 'Royce Gracie', location: 'Los Angeles, CA', user: user) }
    let!(:seminar2) { create(:seminar, title: 'X-Guard System', instructor_name: 'Marcelo Garcia', location: 'Atlanta, GA', user: user) }
    
    before do
      player1.seminars << seminar1
      player2.seminars << seminar2
    end
    
    it 'allows comprehensive cross-entity search and navigation' do
      visit root_path
      
      # Search seminars by location
      visit seminars_path
      fill_in 'Search seminars...', with: 'Los Angeles'
      click_button 'Search'
      
      expect(page).to have_content('Gracie Self Defense')
      expect(page).not_to have_content('X-Guard System')
      
      # Navigate to instructor player profile
      click_link 'Royce Gracie'
      
      expect(page).to have_current_path(player_path(player1))
      expect(page).to have_content('Red Belt')
      expect(page).to have_content('Gracie Academy')
      
      # Search players by team
      visit players_path
      select 'Alliance BJJ', from: 'Team'
      click_button 'Filter'
      
      expect(page).to have_content('Marcelo Garcia')
      expect(page).not_to have_content('Royce Gracie')
      
      # Navigate from player to upcoming seminars
      click_link 'Marcelo Garcia'
      
      within('.upcoming-seminars') do
        expect(page).to have_content('X-Guard System')
      end
      
      # Search teams by location
      visit teams_path
      fill_in 'Search teams...', with: 'California'
      click_button 'Search'
      
      expect(page).to have_content('Gracie Academy')
      expect(page).not_to have_content('Alliance BJJ')
      
      # Navigate through team to seminars
      click_link 'Gracie Academy'
      
      within('.upcoming-seminars') do
        expect(page).to have_content('Gracie Self Defense')
      end
    end
  end
  
  describe 'Error handling and edge cases' do
    it 'handles missing associations gracefully' do
      # Create seminar without associated player
      sign_in(user)
      
      visit new_seminar_path
      
      fill_in 'Title', with: 'Independent Instructor Seminar'
      fill_in 'Description', with: 'Seminar by independent instructor'
      fill_in 'Instructor name', with: 'Unknown Instructor'
      select 'Black', from: 'Instructor belt'
      fill_in 'Seminar date', with: 1.month.from_now.strftime('%Y-%m-%d')
      fill_in 'Venue', with: 'Independent Academy'
      fill_in 'Location', with: 'Nowhere, USA'
      fill_in 'Price amount', with: '100.00'
      
      click_button 'Create Seminar'
      
      expect(page).to have_content('Seminar was successfully created.')
      expect(page).to have_content('Independent Instructor Seminar')
      
      # Navigate and ensure no errors occur
      visit seminars_path
      expect(page).to have_content('Independent Instructor Seminar')
      
      click_link 'Independent Instructor Seminar'
      expect(page).to be_successful
    end
    
    it 'handles deleted associations properly' do
      sign_in(admin)
      
      # Create seminar with player association
      seminar = create(:seminar, title: 'Test Seminar', user: user)
      seminar.players << player
      
      # Delete the player
      visit player_path(player)
      
      accept_confirm do
        click_link 'Delete'
      end
      
      # Seminar should still be accessible
      visit seminar_path(seminar)
      expect(page).to be_successful
      expect(page).to have_content('Test Seminar')
      
      # Team page should handle missing player gracefully
      visit team_path(team)
      expect(page).to be_successful
    end
  end
  
  describe 'Performance and user experience' do
    it 'loads pages efficiently with proper eager loading' do
      # Create data that could cause N+1 queries
      5.times do |i|
        team = create(:team, name: "Team #{i}")
        3.times do |j|
          player = create(:player, name: "Player #{i}-#{j}", team: team)
          2.times do |k|
            seminar = create(:seminar, title: "Seminar #{i}-#{j}-#{k}", user: user)
            player.seminars << seminar
          end
        end
      end
      
      # Visit pages that should use eager loading
      visit teams_path
      expect(page).to be_successful
      
      visit players_path
      expect(page).to be_successful
      
      visit seminars_path
      expect(page).to be_successful
      
      # Navigate to detail pages
      click_link 'Team 0'
      expect(page).to be_successful
      
      click_link 'Player 0-0'
      expect(page).to be_successful
    end
  end
end
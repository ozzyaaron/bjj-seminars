require 'rails_helper'

RSpec.describe 'Team Management', type: :system do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  
  describe 'Team browsing and discovery' do
    let!(:team1) { create(:team, name: 'Gracie Barra', location: 'Brazil', description: 'Traditional Brazilian Jiu-Jitsu') }
    let!(:team2) { create(:team, name: 'Alliance', location: 'USA', description: 'Competition focused team') }
    let!(:team3) { create(:team, name: 'Atos', location: 'USA', description: 'Modern BJJ techniques') }
    
    before do
      create(:player, name: 'Player 1', team: team1)
      create(:player, name: 'Player 2', team: team1)
      create(:player, name: 'Player 3', team: team2)
    end
    
    it 'displays all teams with basic information' do
      visit teams_path
      
      expect(page).to have_content('Gracie Barra')
      expect(page).to have_content('Alliance')
      expect(page).to have_content('Atos')
      expect(page).to have_content('Brazil')
      expect(page).to have_content('USA')
    end
    
    it 'shows team member counts' do
      visit teams_path
      
      within('.team-card', text: 'Gracie Barra') do
        expect(page).to have_content('2 members')
      end
      
      within('.team-card', text: 'Alliance') do
        expect(page).to have_content('1 member')
      end
      
      within('.team-card', text: 'Atos') do
        expect(page).to have_content('0 members')
      end
    end
    
    it 'provides search functionality' do
      visit teams_path
      
      fill_in 'Search teams...', with: 'Gracie'
      click_button 'Search'
      
      expect(page).to have_content('Gracie Barra')
      expect(page).not_to have_content('Alliance')
      expect(page).not_to have_content('Atos')
    end
    
    it 'searches by location' do
      visit teams_path
      
      fill_in 'Search teams...', with: 'Brazil'
      click_button 'Search'
      
      expect(page).to have_content('Gracie Barra')
      expect(page).not_to have_content('Alliance')
      expect(page).not_to have_content('Atos')
    end
    
    it 'is case insensitive in search' do
      visit teams_path
      
      fill_in 'Search teams...', with: 'alliance'
      click_button 'Search'
      
      expect(page).to have_content('Alliance')
      expect(page).not_to have_content('Gracie Barra')
    end
    
    it 'orders teams alphabetically' do
      visit teams_path
      
      team_names = page.all('.team-name').map(&:text)
      expect(team_names).to eq(['Alliance', 'Atos', 'Gracie Barra'])
    end
  end
  
  describe 'Team profile viewing' do
    let!(:team) { create(:team, name: 'Test Team', location: 'Test City', website: 'https://testteam.com', description: 'A test team for BJJ') }
    let!(:player1) { create(:player, name: 'Player A', team: team, belt_rank: 'black') }
    let!(:player2) { create(:player, name: 'Player B', team: team, belt_rank: 'brown') }
    let!(:upcoming_seminar) { create(:seminar, title: 'Team Seminar', starts_at: 1.week.from_now) }
    let!(:past_seminar) { create(:seminar, title: 'Past Team Event', starts_at: 1.week.ago, ends_at: 1.week.ago + 2.hours) }
    
    before do
      player1.seminars << upcoming_seminar
      player2.seminars << past_seminar
    end
    
    it 'displays comprehensive team information' do
      visit team_path(team)
      
      expect(page).to have_content('Test Team')
      expect(page).to have_content('Test City')
      expect(page).to have_content('A test team for BJJ')
      expect(page).to have_link('Visit Website', href: 'https://testteam.com')
    end
    
    it 'lists team members ordered by name' do
      visit team_path(team)
      
      within('.team-members') do
        expect(page).to have_content('Player A')
        expect(page).to have_content('Player B')
        expect(page).to have_content('Black Belt')
        expect(page).to have_content('Brown Belt')
      end
      
      member_names = page.all('.member-name').map(&:text)
      expect(member_names).to eq(['Player A', 'Player B'])
    end
    
    it 'shows upcoming seminars for team members' do
      visit team_path(team)
      
      within('.upcoming-seminars') do
        expect(page).to have_content('Team Seminar')
        expect(page).not_to have_content('Past Team Event')
      end
    end
    
    it 'limits seminars to recent ones' do
      # Create many seminars to test limit
      8.times do |i|
        seminar = create(:seminar, title: "Seminar #{i}", starts_at: (i + 1).days.from_now)
        player1.seminars << seminar
      end
      
      visit team_path(team)
      
      # Should show max 6 seminars
      expect(page).to have_selector('.seminar-card', count: 6)
    end
    
    it 'links to player profiles from team page' do
      visit team_path(team)
      
      click_link 'Player A'
      expect(page).to have_current_path(player_path(player1))
    end
    
    it 'links to seminar details from team page' do
      visit team_path(team)
      
      click_link 'Team Seminar'
      expect(page).to have_current_path(seminar_path(upcoming_seminar))
    end
  end
  
  describe 'Admin team management' do
    before { sign_in(admin) }
    
    describe 'Creating teams' do
      it 'allows admin to create new teams' do
        visit teams_path
        click_link 'Add New Team'
        
        fill_in 'Name', with: 'New BJJ Academy'
        fill_in 'Location', with: 'New York, NY'
        fill_in 'Website', with: 'https://newbjj.com'
        fill_in 'Description', with: 'A new academy focused on fundamentals'
        
        click_button 'Create Team'
        
        expect(page).to have_content('Team created successfully')
        expect(page).to have_content('New BJJ Academy')
        expect(page).to have_content('New York, NY')
        expect(page).to have_content('A new academy focused on fundamentals')
      end
      
      it 'validates required fields when creating teams' do
        visit new_team_path
        
        click_button 'Create Team'
        
        expect(page).to have_content("Name can't be blank")
      end
      
      it 'handles optional fields properly' do
        visit new_team_path
        
        fill_in 'Name', with: 'Minimal Team'
        fill_in 'Location', with: 'Somewhere'
        
        click_button 'Create Team'
        
        expect(page).to have_content('Team created successfully')
        expect(page).to have_content('Minimal Team')
        expect(page).to have_content('Somewhere')
      end
      
      it 'validates website URL format' do
        visit new_team_path
        
        fill_in 'Name', with: 'Test Team'
        fill_in 'Location', with: 'Test Location'
        fill_in 'Website', with: 'not-a-url'
        
        click_button 'Create Team'
        
        expect(page).to have_content('Website is not a valid URL')
      end
    end
    
    describe 'Editing teams' do
      let!(:team) { create(:team, name: 'Original Team', location: 'Original Location') }
      
      it 'allows admin to edit team information' do
        visit team_path(team)
        click_link 'Edit'
        
        fill_in 'Name', with: 'Updated Team Name'
        fill_in 'Location', with: 'Updated Location'
        fill_in 'Website', with: 'https://updated.com'
        fill_in 'Description', with: 'Updated description'
        
        click_button 'Update Team'
        
        expect(page).to have_content('Team updated successfully')
        expect(page).to have_content('Updated Team Name')
        expect(page).to have_content('Updated Location')
        expect(page).to have_content('Updated description')
      end
      
      it 'preserves existing data when editing' do
        visit edit_team_path(team)
        
        expect(page).to have_field('Name', with: team.name)
        expect(page).to have_field('Location', with: team.location)
      end
      
      it 'handles validation errors during update' do
        visit edit_team_path(team)
        
        fill_in 'Name', with: ''
        click_button 'Update Team'
        
        expect(page).to have_content("Name can't be blank")
        expect(page).to have_current_path(team_path(team))
      end
    end
    
    describe 'Deleting teams' do
      let!(:team) { create(:team, name: 'Team to Delete') }
      
      it 'allows admin to delete teams' do
        visit team_path(team)
        
        accept_confirm do
          click_link 'Delete'
        end
        
        expect(page).to have_content('Team deleted successfully')
        expect(page).not_to have_content('Team to Delete')
        expect(page).to have_current_path(teams_path)
      end
      
      it 'handles team deletion with associated players' do
        player = create(:player, team: team)
        
        visit team_path(team)
        
        accept_confirm do
          click_link 'Delete'
        end
        
        # Team should be deleted but players should remain
        expect(page).to have_content('Team deleted successfully')
        visit player_path(player)
        expect(page).to be_successful
      end
    end
  end
  
  describe 'Access control' do
    let!(:team) { create(:team) }
    
    context 'as regular user' do
      before { sign_in(user) }
      
      it 'allows viewing team profiles' do
        visit team_path(team)
        expect(page).to be_successful
      end
      
      it 'allows browsing teams' do
        visit teams_path
        expect(page).to be_successful
      end
      
      it 'denies access to team creation' do
        visit new_team_path
        expect(page).to have_current_path(root_path)
        expect(page).to have_content('Access denied. Admin privileges required.')
      end
      
      it 'denies access to team editing' do
        visit edit_team_path(team)
        expect(page).to have_current_path(root_path)
        expect(page).to have_content('Access denied. Admin privileges required.')
      end
      
      it 'hides admin action links' do
        visit team_path(team)
        expect(page).not_to have_link('Edit')
        expect(page).not_to have_link('Delete')
      end
    end
    
    context 'as guest user' do
      it 'allows viewing team profiles' do
        visit team_path(team)
        expect(page).to be_successful
      end
      
      it 'allows browsing teams' do
        visit teams_path
        expect(page).to be_successful
      end
      
      it 'redirects to login for admin actions' do
        visit new_team_path
        expect(page).to have_current_path(login_path)
      end
    end
  end
  
  describe 'Team-Player relationships' do
    let!(:team) { create(:team, name: 'Relationship Team') }
    let!(:other_team) { create(:team, name: 'Other Team') }
    
    before { sign_in(admin) }
    
    it 'shows empty state when team has no members' do
      visit team_path(team)
      
      within('.team-members') do
        expect(page).to have_content('No team members yet')
      end
    end
    
    it 'updates member count when players are added' do
      visit team_path(team)
      expect(page).to have_content('0 members')
      
      # Create a player for this team
      create(:player, team: team)
      
      visit team_path(team)
      expect(page).to have_content('1 member')
    end
  end
end
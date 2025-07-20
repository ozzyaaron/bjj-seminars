require 'rails_helper'

RSpec.describe 'Player Management', type: :system do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:team1) { create(:team, name: 'Gracie Barra', location: 'Brazil') }
  let(:team2) { create(:team, name: 'Alliance', location: 'USA') }
  
  describe 'Player browsing and discovery' do
    let!(:player1) { create(:player, name: 'Gordon Ryan', belt_rank: 'black', team: team1) }
    let!(:player2) { create(:player, name: 'Craig Jones', belt_rank: 'black', team: team2) }
    let!(:player3) { create(:player, name: 'Nicky Ryan', belt_rank: 'brown', team: team1) }
    
    it 'allows users to browse all players' do
      visit players_path
      
      expect(page).to have_content('Gordon Ryan')
      expect(page).to have_content('Craig Jones')
      expect(page).to have_content('Nicky Ryan')
      expect(page).to have_content('Gracie Barra')
      expect(page).to have_content('Alliance')
    end
    
    it 'provides search functionality' do
      visit players_path
      
      fill_in 'Search players...', with: 'Gordon'
      click_button 'Search'
      
      expect(page).to have_content('Gordon Ryan')
      expect(page).not_to have_content('Craig Jones')
      expect(page).not_to have_content('Nicky Ryan')
    end
    
    it 'allows filtering by team' do
      visit players_path
      
      select 'Gracie Barra', from: 'Team'
      click_button 'Filter'
      
      expect(page).to have_content('Gordon Ryan')
      expect(page).to have_content('Nicky Ryan')
      expect(page).not_to have_content('Craig Jones')
    end
    
    it 'allows filtering by belt rank' do
      visit players_path
      
      select 'Black', from: 'Belt Rank'
      click_button 'Filter'
      
      expect(page).to have_content('Gordon Ryan')
      expect(page).to have_content('Craig Jones')
      expect(page).not_to have_content('Nicky Ryan')
    end
    
    it 'combines multiple filters' do
      visit players_path
      
      select 'Gracie Barra', from: 'Team'
      select 'Black', from: 'Belt Rank'
      click_button 'Filter'
      
      expect(page).to have_content('Gordon Ryan')
      expect(page).not_to have_content('Craig Jones')
      expect(page).not_to have_content('Nicky Ryan')
    end
  end
  
  describe 'Player profile viewing' do
    let!(:player) { create(:player, name: 'Marcelo Garcia', belt_rank: 'black', team: team1, biography: 'Multiple time world champion') }
    let!(:upcoming_seminar) { create(:seminar, title: 'Guard Techniques', starts_at: 1.week.from_now) }
    let!(:past_seminar) { create(:seminar, title: 'Submission Defense', starts_at: 1.week.ago, ends_at: 1.week.ago + 2.hours) }
    
    before do
      player.seminars << [upcoming_seminar, past_seminar]
    end
    
    it 'displays comprehensive player information' do
      visit player_path(player)
      
      expect(page).to have_content('Marcelo Garcia')
      expect(page).to have_content('Black Belt')
      expect(page).to have_content('Gracie Barra')
      expect(page).to have_content('Multiple time world champion')
    end
    
    it 'shows upcoming seminars for the player' do
      visit player_path(player)
      
      within('.upcoming-seminars') do
        expect(page).to have_content('Guard Techniques')
        expect(page).not_to have_content('Submission Defense')
      end
    end
    
    it 'shows past seminars for the player' do
      visit player_path(player)
      
      within('.past-seminars') do
        expect(page).to have_content('Submission Defense')
        expect(page).not_to have_content('Guard Techniques')
      end
    end
    
    it 'links to seminar details from player profile' do
      visit player_path(player)
      
      click_link 'Guard Techniques'
      expect(page).to have_current_path(seminar_path(upcoming_seminar))
    end
  end
  
  describe 'Admin player management' do
    before { sign_in(admin) }
    
    describe 'Creating players' do
      it 'allows admin to create new players' do
        visit players_path
        click_link 'Add New Player'
        
        fill_in 'Name', with: 'Rafael Mendes'
        select team1.name, from: 'Team'
        select 'Black', from: 'Belt rank'
        fill_in 'Biography', with: 'Legendary featherweight competitor'
        
        click_button 'Create Player'
        
        expect(page).to have_content('Player created successfully')
        expect(page).to have_content('Rafael Mendes')
        expect(page).to have_content('Legendary featherweight competitor')
      end
      
      it 'validates required fields when creating players' do
        visit new_player_path
        
        click_button 'Create Player'
        
        expect(page).to have_content("Name can't be blank")
        expect(page).to have_content("Belt rank can't be blank")
      end
      
      it 'handles team selection properly' do
        visit new_player_path
        
        fill_in 'Name', with: 'Test Player'
        select 'Black', from: 'Belt rank'
        
        click_button 'Create Player'
        
        expect(page).to have_content('Player created successfully')
        expect(page).to have_content('Test Player')
      end
    end
    
    describe 'Editing players' do
      let!(:player) { create(:player, name: 'Original Name', team: team1) }
      
      it 'allows admin to edit player information' do
        visit player_path(player)
        click_link 'Edit'
        
        fill_in 'Name', with: 'Updated Name'
        select team2.name, from: 'Team'
        fill_in 'Biography', with: 'Updated biography'
        
        click_button 'Update Player'
        
        expect(page).to have_content('Player updated successfully')
        expect(page).to have_content('Updated Name')
        expect(page).to have_content('Alliance')
        expect(page).to have_content('Updated biography')
      end
      
      it 'preserves existing data when editing' do
        visit edit_player_path(player)
        
        expect(page).to have_field('Name', with: player.name)
        expect(page).to have_select('Team', selected: player.team.name)
        expect(page).to have_select('Belt rank', selected: player.belt_rank.titleize)
      end
    end
    
    describe 'Deleting players' do
      let!(:player) { create(:player, name: 'Player to Delete') }
      
      it 'allows admin to delete players' do
        visit player_path(player)
        
        accept_confirm do
          click_link 'Delete'
        end
        
        expect(page).to have_content('Player deleted successfully')
        expect(page).not_to have_content('Player to Delete')
        expect(page).to have_current_path(players_path)
      end
    end
  end
  
  describe 'Access control' do
    let!(:player) { create(:player) }
    
    context 'as regular user' do
      before { sign_in(user) }
      
      it 'allows viewing player profiles' do
        visit player_path(player)
        expect(page).to be_successful
      end
      
      it 'denies access to player creation' do
        visit new_player_path
        expect(page).to have_current_path(root_path)
        expect(page).to have_content('Access denied. Admin privileges required.')
      end
      
      it 'denies access to player editing' do
        visit edit_player_path(player)
        expect(page).to have_current_path(root_path)
        expect(page).to have_content('Access denied. Admin privileges required.')
      end
    end
    
    context 'as guest user' do
      it 'allows viewing player profiles' do
        visit player_path(player)
        expect(page).to be_successful
      end
      
      it 'redirects to login for admin actions' do
        visit new_player_path
        expect(page).to have_current_path(login_path)
      end
    end
  end
end
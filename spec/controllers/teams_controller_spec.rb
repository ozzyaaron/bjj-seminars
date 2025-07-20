require 'rails_helper'

RSpec.describe TeamsController, type: :controller do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:team) { create(:team) }
  
  describe 'GET #index' do
    let!(:team1) { create(:team, name: 'Gracie Barra', location: 'Brazil') }
    let!(:team2) { create(:team, name: 'Alliance', location: 'USA') }
    let!(:team3) { create(:team, name: 'Atos', location: 'USA') }
    
    before do
      # Add players to teams to test includes
      create(:player, team: team1)
      create(:player, team: team2)
    end
    
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end
    
    it 'does not require authentication' do
      get :index
      expect(response).to be_successful
    end
    
    it 'assigns all teams ordered by name' do
      get :index
      expect(assigns(:teams)).to eq([team2, team3, team1])
    end
    
    it 'includes players association to avoid N+1' do
      get :index
      expect(assigns(:teams).first.association(:players).loaded?).to be true
    end
    
    context 'with search params' do
      it 'filters by team name' do
        get :index, params: { search: 'Gracie' }
        expect(assigns(:teams)).to contain_exactly(team1)
      end
      
      it 'filters by location' do
        get :index, params: { search: 'Brazil' }
        expect(assigns(:teams)).to contain_exactly(team1)
      end
      
      it 'is case insensitive' do
        get :index, params: { search: 'alliance' }
        expect(assigns(:teams)).to contain_exactly(team2)
      end
      
      it 'returns no results for non-matching search' do
        get :index, params: { search: 'nonexistent' }
        expect(assigns(:teams)).to be_empty
      end
    end
  end
  
  describe 'GET #show' do
    let!(:player1) { create(:player, name: 'Player 1', team: team) }
    let!(:player2) { create(:player, name: 'Player 2', team: team) }
    let!(:other_player) { create(:player, name: 'Other Player') }
    
    let!(:upcoming_seminar) { create(:seminar, starts_at: 1.week.from_now) }
    let!(:past_seminar) { create(:seminar, starts_at: 1.week.ago, ends_at: 1.week.ago + 2.hours) }
    
    before do
      # Associate team players with seminars
      player1.seminars << upcoming_seminar
      player2.seminars << past_seminar
      other_player.seminars << upcoming_seminar
    end
    
    it 'returns a successful response' do
      get :show, params: { id: team.id }
      expect(response).to be_successful
    end
    
    it 'does not require authentication' do
      get :show, params: { id: team.id }
      expect(response).to be_successful
    end
    
    it 'assigns the requested team' do
      get :show, params: { id: team.id }
      expect(assigns(:team)).to eq(team)
    end
    
    it 'assigns team players ordered by name' do
      get :show, params: { id: team.id }
      expect(assigns(:players)).to eq([player1, player2])
    end
    
    it 'assigns recent seminars for team players' do
      get :show, params: { id: team.id }
      expect(assigns(:recent_seminars)).to contain_exactly(upcoming_seminar)
    end
    
    it 'only includes upcoming seminars' do
      get :show, params: { id: team.id }
      expect(assigns(:recent_seminars)).not_to include(past_seminar)
    end
    
    it 'limits seminars to 6' do
      8.times do
        seminar = create(:seminar, starts_at: 1.day.from_now)
        player1.seminars << seminar
      end
      
      get :show, params: { id: team.id }
      expect(assigns(:recent_seminars).size).to eq(6)
    end
    
    it 'orders seminars by start date' do
      early_seminar = create(:seminar, starts_at: 1.day.from_now)
      late_seminar = create(:seminar, starts_at: 2.days.from_now)
      player1.seminars << [early_seminar, late_seminar]
      
      get :show, params: { id: team.id }
      seminars = assigns(:recent_seminars)
      expect(seminars.first.starts_at).to be < seminars.last.starts_at
    end
  end
  
  describe 'GET #new' do
    context 'as admin' do
      before { sign_in(admin) }
      
      it 'returns a successful response' do
        get :new
        expect(response).to be_successful
      end
      
      it 'assigns a new team' do
        get :new
        expect(assigns(:team)).to be_a_new(Team)
      end
    end
    
    context 'as regular user' do
      before { sign_in(user) }
      
      it 'redirects to root' do
        get :new
        expect(response).to redirect_to(root_path)
      end
      
      it 'sets alert message' do
        get :new
        expect(flash[:alert]).to eq('Access denied. Admin privileges required.')
      end
    end
    
    context 'as guest' do
      it 'redirects to login' do
        get :new
        expect(response).to redirect_to(login_path)
      end
    end
  end
  
  describe 'POST #create' do
    let(:valid_params) do
      {
        team: {
          name: 'New Team',
          location: 'Test Location',
          website: 'https://example.com',
          description: 'Test description'
        }
      }
    end
    
    context 'as admin' do
      before { sign_in(admin) }
      
      context 'with valid params' do
        it 'creates a new team' do
          expect {
            post :create, params: valid_params
          }.to change(Team, :count).by(1)
        end
        
        it 'redirects to the created team' do
          post :create, params: valid_params
          expect(response).to redirect_to(Team.last)
        end
        
        it 'sets success notice' do
          post :create, params: valid_params
          expect(flash[:notice]).to eq('Team created successfully')
        end
        
        it 'assigns correct attributes' do
          post :create, params: valid_params
          team = Team.last
          expect(team.name).to eq('New Team')
          expect(team.location).to eq('Test Location')
          expect(team.website).to eq('https://example.com')
          expect(team.description).to eq('Test description')
        end
      end
      
      context 'with invalid params' do
        let(:invalid_params) { { team: { name: '' } } }
        
        it 'does not create a new team' do
          expect {
            post :create, params: invalid_params
          }.not_to change(Team, :count)
        end
        
        it 'renders new template' do
          post :create, params: invalid_params
          expect(response).to render_template(:new)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
    
    context 'as regular user' do
      before { sign_in(user) }
      
      it 'does not create team' do
        expect {
          post :create, params: valid_params
        }.not_to change(Team, :count)
      end
      
      it 'redirects to root' do
        post :create, params: valid_params
        expect(response).to redirect_to(root_path)
      end
    end
  end
  
  describe 'GET #edit' do
    context 'as admin' do
      before { sign_in(admin) }
      
      it 'returns a successful response' do
        get :edit, params: { id: team.id }
        expect(response).to be_successful
      end
      
      it 'assigns the requested team' do
        get :edit, params: { id: team.id }
        expect(assigns(:team)).to eq(team)
      end
    end
    
    context 'as regular user' do
      before { sign_in(user) }
      
      it 'redirects to root' do
        get :edit, params: { id: team.id }
        expect(response).to redirect_to(root_path)
      end
    end
  end
  
  describe 'PATCH #update' do
    let(:update_params) do
      {
        id: team.id,
        team: { name: 'Updated Name' }
      }
    end
    
    context 'as admin' do
      before { sign_in(admin) }
      
      context 'with valid params' do
        it 'updates the team' do
          patch :update, params: update_params
          team.reload
          expect(team.name).to eq('Updated Name')
        end
        
        it 'redirects to the team' do
          patch :update, params: update_params
          expect(response).to redirect_to(team)
        end
        
        it 'sets success notice' do
          patch :update, params: update_params
          expect(flash[:notice]).to eq('Team updated successfully')
        end
      end
      
      context 'with invalid params' do
        let(:invalid_update_params) do
          {
            id: team.id,
            team: { name: '' }
          }
        end
        
        it 'does not update the team' do
          original_name = team.name
          patch :update, params: invalid_update_params
          team.reload
          expect(team.name).to eq(original_name)
        end
        
        it 'renders edit template' do
          patch :update, params: invalid_update_params
          expect(response).to render_template(:edit)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
    
    context 'as regular user' do
      before { sign_in(user) }
      
      it 'does not update the team' do
        original_name = team.name
        patch :update, params: update_params
        team.reload
        expect(team.name).to eq(original_name)
      end
      
      it 'redirects to root' do
        patch :update, params: update_params
        expect(response).to redirect_to(root_path)
      end
    end
  end
  
  describe 'DELETE #destroy' do
    context 'as admin' do
      before { sign_in(admin) }
      
      it 'destroys the team' do
        team # create the team
        expect {
          delete :destroy, params: { id: team.id }
        }.to change(Team, :count).by(-1)
      end
      
      it 'redirects to teams index' do
        delete :destroy, params: { id: team.id }
        expect(response).to redirect_to(teams_path)
      end
      
      it 'sets success notice' do
        delete :destroy, params: { id: team.id }
        expect(flash[:notice]).to eq('Team deleted successfully')
      end
    end
    
    context 'as regular user' do
      before { sign_in(user) }
      
      it 'does not destroy the team' do
        team # create the team
        expect {
          delete :destroy, params: { id: team.id }
        }.not_to change(Team, :count)
      end
      
      it 'redirects to root' do
        delete :destroy, params: { id: team.id }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
require 'rails_helper'

RSpec.describe PlayersController, type: :controller do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:team) { create(:team) }
  let(:player) { create(:player, team: team) }
  
  describe 'GET #index' do
    let!(:player1) { create(:player, name: 'Gordon Ryan', belt_rank: 'black') }
    let!(:player2) { create(:player, name: 'Craig Jones', belt_rank: 'black', team: team) }
    let!(:player3) { create(:player, name: 'Nicky Ryan', belt_rank: 'brown') }
    
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end
    
    it 'does not require authentication' do
      get :index
      expect(response).to be_successful
    end
    
    it 'assigns all players ordered by name' do
      get :index
      expect(assigns(:players)).to eq([player2, player1, player3])
    end
    
    it 'includes team association to avoid N+1' do
      get :index
      expect(assigns(:players).first.association(:team).loaded?).to be true
    end
    
    it 'assigns teams for filtering' do
      get :index
      expect(assigns(:teams)).to include(team)
    end
    
    it 'assigns unique belt ranks' do
      get :index
      expect(assigns(:belt_ranks)).to contain_exactly('black', 'brown')
    end
    
    context 'with search params' do
      it 'filters by name' do
        get :index, params: { search: 'Gordon' }
        expect(assigns(:players)).to contain_exactly(player1)
      end
      
      it 'filters by biography' do
        player1.update(biography: 'Multiple time ADCC champion')
        get :index, params: { search: 'ADCC' }
        expect(assigns(:players)).to contain_exactly(player1)
      end
      
      it 'is case insensitive' do
        get :index, params: { search: 'gordon' }
        expect(assigns(:players)).to contain_exactly(player1)
      end
    end
    
    context 'with team filter' do
      it 'filters by team_id' do
        get :index, params: { team_id: team.id }
        expect(assigns(:players)).to contain_exactly(player2)
      end
    end
    
    context 'with belt rank filter' do
      it 'filters by belt_rank' do
        get :index, params: { belt_rank: 'brown' }
        expect(assigns(:players)).to contain_exactly(player3)
      end
    end
    
    context 'with combined filters' do
      it 'applies all filters' do
        player4 = create(:player, name: 'Team Player', belt_rank: 'black', team: team)
        get :index, params: { team_id: team.id, belt_rank: 'black' }
        expect(assigns(:players)).to contain_exactly(player2, player4)
      end
    end
  end
  
  describe 'GET #show' do
    let!(:upcoming_seminar) { create(:seminar, starts_at: 1.week.from_now) }
    let!(:past_seminar) { create(:seminar, starts_at: 1.week.ago, ends_at: 1.week.ago + 2.hours) }
    
    before do
      player.seminars << [upcoming_seminar, past_seminar]
    end
    
    it 'returns a successful response' do
      get :show, params: { id: player.id }
      expect(response).to be_successful
    end
    
    it 'does not require authentication' do
      get :show, params: { id: player.id }
      expect(response).to be_successful
    end
    
    it 'assigns the requested player' do
      get :show, params: { id: player.id }
      expect(assigns(:player)).to eq(player)
    end
    
    it 'assigns upcoming seminars for the player' do
      get :show, params: { id: player.id }
      expect(assigns(:upcoming_seminars)).to contain_exactly(upcoming_seminar)
    end
    
    it 'assigns past seminars for the player' do
      get :show, params: { id: player.id }
      expect(assigns(:past_seminars)).to contain_exactly(past_seminar)
    end
    
    it 'limits seminars to 6 each' do
      8.times { player.seminars << create(:seminar, starts_at: 1.day.from_now) }
      8.times { player.seminars << create(:seminar, starts_at: 1.day.ago, ends_at: 1.day.ago + 2.hours) }
      
      get :show, params: { id: player.id }
      expect(assigns(:upcoming_seminars).size).to eq(6)
      expect(assigns(:past_seminars).size).to eq(6)
    end
  end
  
  describe 'GET #new' do
    context 'as admin' do
      before { sign_in(admin) }
      
      it 'returns a successful response' do
        get :new
        expect(response).to be_successful
      end
      
      it 'assigns a new player' do
        get :new
        expect(assigns(:player)).to be_a_new(Player)
      end
      
      it 'assigns teams for selection' do
        get :new
        expect(assigns(:teams)).to include(team)
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
        player: {
          name: 'New Player',
          team_id: team.id,
          belt_rank: 'purple',
          biography: 'Test biography'
        }
      }
    end
    
    context 'as admin' do
      before { sign_in(admin) }
      
      context 'with valid params' do
        it 'creates a new player' do
          expect {
            post :create, params: valid_params
          }.to change(Player, :count).by(1)
        end
        
        it 'redirects to the created player' do
          post :create, params: valid_params
          expect(response).to redirect_to(Player.last)
        end
        
        it 'sets success notice' do
          post :create, params: valid_params
          expect(flash[:notice]).to eq('Player created successfully')
        end
      end
      
      context 'with invalid params' do
        let(:invalid_params) { { player: { name: '' } } }
        
        it 'does not create a new player' do
          expect {
            post :create, params: invalid_params
          }.not_to change(Player, :count)
        end
        
        it 'renders new template' do
          post :create, params: invalid_params
          expect(response).to render_template(:new)
          expect(response).to have_http_status(:unprocessable_entity)
        end
        
        it 'assigns teams for form' do
          post :create, params: invalid_params
          expect(assigns(:teams)).to include(team)
        end
      end
    end
    
    context 'as regular user' do
      before { sign_in(user) }
      
      it 'does not create player' do
        expect {
          post :create, params: valid_params
        }.not_to change(Player, :count)
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
        get :edit, params: { id: player.id }
        expect(response).to be_successful
      end
      
      it 'assigns the requested player' do
        get :edit, params: { id: player.id }
        expect(assigns(:player)).to eq(player)
      end
      
      it 'assigns teams for selection' do
        get :edit, params: { id: player.id }
        expect(assigns(:teams)).to include(team)
      end
    end
    
    context 'as regular user' do
      before { sign_in(user) }
      
      it 'redirects to root' do
        get :edit, params: { id: player.id }
        expect(response).to redirect_to(root_path)
      end
    end
  end
  
  describe 'PATCH #update' do
    let(:update_params) do
      {
        id: player.id,
        player: { name: 'Updated Name' }
      }
    end
    
    context 'as admin' do
      before { sign_in(admin) }
      
      context 'with valid params' do
        it 'updates the player' do
          patch :update, params: update_params
          player.reload
          expect(player.name).to eq('Updated Name')
        end
        
        it 'redirects to the player' do
          patch :update, params: update_params
          expect(response).to redirect_to(player)
        end
        
        it 'sets success notice' do
          patch :update, params: update_params
          expect(flash[:notice]).to eq('Player updated successfully')
        end
      end
      
      context 'with invalid params' do
        let(:invalid_update_params) do
          {
            id: player.id,
            player: { name: '' }
          }
        end
        
        it 'does not update the player' do
          original_name = player.name
          patch :update, params: invalid_update_params
          player.reload
          expect(player.name).to eq(original_name)
        end
        
        it 'renders edit template' do
          patch :update, params: invalid_update_params
          expect(response).to render_template(:edit)
          expect(response).to have_http_status(:unprocessable_entity)
        end
        
        it 'assigns teams for form' do
          patch :update, params: invalid_update_params
          expect(assigns(:teams)).to include(team)
        end
      end
    end
    
    context 'as regular user' do
      before { sign_in(user) }
      
      it 'does not update the player' do
        original_name = player.name
        patch :update, params: update_params
        player.reload
        expect(player.name).to eq(original_name)
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
      
      it 'destroys the player' do
        player # create the player
        expect {
          delete :destroy, params: { id: player.id }
        }.to change(Player, :count).by(-1)
      end
      
      it 'redirects to players index' do
        delete :destroy, params: { id: player.id }
        expect(response).to redirect_to(players_path)
      end
      
      it 'sets success notice' do
        delete :destroy, params: { id: player.id }
        expect(flash[:notice]).to eq('Player deleted successfully')
      end
    end
    
    context 'as regular user' do
      before { sign_in(user) }
      
      it 'does not destroy the player' do
        player # create the player
        expect {
          delete :destroy, params: { id: player.id }
        }.not_to change(Player, :count)
      end
      
      it 'redirects to root' do
        delete :destroy, params: { id: player.id }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
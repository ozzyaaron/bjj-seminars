require 'rails_helper'

RSpec.describe SeminarsController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:seminar) { create(:seminar, user: user) }
  
  describe 'GET #index' do
    before do
      create_list(:seminar, 3, user: user)
      create_list(:seminar, 2, user: other_user)
    end
    
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end
    
    it 'assigns all seminars' do
      get :index
      expect(assigns(:seminars)).to match_array(Seminar.all)
    end
    
    context 'with search query' do
      let!(:guard_seminar) { create(:seminar, title: 'Guard Techniques', user: user) }
      let!(:takedown_seminar) { create(:seminar, title: 'Takedown Basics', user: user) }
      
      it 'filters seminars by search query' do
        get :index, params: { search: 'Guard' }
        expect(assigns(:seminars)).to include(guard_seminar)
        expect(assigns(:seminars)).not_to include(takedown_seminar)
      end
    end
    
    context 'with filter params' do
      let!(:upcoming_seminar) { create(:seminar, :future, user: user) }
      let!(:past_seminar) { create(:seminar, :past, user: user) }
      
      it 'filters by upcoming seminars' do
        get :index, params: { filter: 'upcoming' }
        expect(assigns(:seminars)).to include(upcoming_seminar)
        expect(assigns(:seminars)).not_to include(past_seminar)
      end
      
      it 'filters by past seminars' do
        get :index, params: { filter: 'past' }
        expect(assigns(:seminars)).to include(past_seminar)
        expect(assigns(:seminars)).not_to include(upcoming_seminar)
      end
    end
  end
  
  describe 'GET #show' do
    it 'returns a successful response' do
      get :show, params: { id: seminar.id }
      expect(response).to be_successful
    end
    
    it 'assigns the requested seminar' do
      get :show, params: { id: seminar.id }
      expect(assigns(:seminar)).to eq(seminar)
    end
  end
  
  describe 'GET #new' do
    context 'when user is signed in' do
      before { sign_in(user) }
      
      it 'returns a successful response' do
        get :new
        expect(response).to be_successful
      end
      
      it 'assigns a new seminar' do
        get :new
        expect(assigns(:seminar)).to be_a_new(Seminar)
      end
    end
    
    context 'when user is not signed in' do
      it 'redirects to sign in page' do
        get :new
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
  
  describe 'POST #create' do
    let(:valid_params) do
      {
        seminar: {
          title: 'Test Seminar',
          description: 'A comprehensive test seminar',
          instructor_name: 'John Doe',
          instructor_belt: 'black',
          instructor_lineage: 'Gracie Lineage',
          seminar_date: 1.week.from_now,
          venue: 'Test Gym',
          location: 'Test City',
          price_amount: 50.00,
          price_currency: 'USD'
        }
      }
    end
    
    context 'when user is signed in' do
      before { sign_in(user) }
      
      context 'with valid parameters' do
        it 'creates a new seminar' do
          expect {
            post :create, params: valid_params
          }.to change(Seminar, :count).by(1)
        end
        
        it 'associates the seminar with the current user' do
          post :create, params: valid_params
          expect(Seminar.last.user).to eq(user)
        end
        
        it 'redirects to the created seminar' do
          post :create, params: valid_params
          expect(response).to redirect_to(Seminar.last)
        end
        
        it 'sets success flash message' do
          post :create, params: valid_params
          expect(flash[:notice]).to eq('Seminar was successfully created.')
        end
      end
      
      context 'with invalid parameters' do
        let(:invalid_params) do
          { seminar: { title: '', description: '' } }
        end
        
        it 'does not create a new seminar' do
          expect {
            post :create, params: invalid_params
          }.not_to change(Seminar, :count)
        end
        
        it 'renders the new template' do
          post :create, params: invalid_params
          expect(response).to render_template(:new)
          expect(response.status).to eq(422)
        end
      end
    end
    
    context 'when user is not signed in' do
      it 'redirects to sign in page' do
        post :create, params: valid_params
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
  
  describe 'GET #edit' do
    context 'when user owns the seminar' do
      before { sign_in(user) }
      
      it 'returns a successful response' do
        get :edit, params: { id: seminar.id }
        expect(response).to be_successful
      end
      
      it 'assigns the requested seminar' do
        get :edit, params: { id: seminar.id }
        expect(assigns(:seminar)).to eq(seminar)
      end
    end
    
    context 'when user does not own the seminar' do
      before { sign_in(other_user) }
      
      it 'redirects to seminars index' do
        get :edit, params: { id: seminar.id }
        expect(response).to redirect_to(seminars_path)
      end
      
      it 'sets flash alert message' do
        get :edit, params: { id: seminar.id }
        expect(flash[:alert]).to eq('You can only edit your own seminars.')
      end
    end
    
    context 'when user is not signed in' do
      it 'redirects to sign in page' do
        get :edit, params: { id: seminar.id }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
  
  describe 'PATCH #update' do
    let(:update_params) do
      {
        id: seminar.id,
        seminar: { title: 'Updated Title' }
      }
    end
    
    context 'when user owns the seminar' do
      before { sign_in(user) }
      
      context 'with valid parameters' do
        it 'updates the seminar' do
          patch :update, params: update_params
          seminar.reload
          expect(seminar.title).to eq('Updated Title')
        end
        
        it 'redirects to the seminar' do
          patch :update, params: update_params
          expect(response).to redirect_to(seminar)
        end
        
        it 'sets success flash message' do
          patch :update, params: update_params
          expect(flash[:notice]).to eq('Seminar was successfully updated.')
        end
      end
      
      context 'with invalid parameters' do
        let(:invalid_update_params) do
          {
            id: seminar.id,
            seminar: { title: '' }
          }
        end
        
        it 'does not update the seminar' do
          original_title = seminar.title
          patch :update, params: invalid_update_params
          seminar.reload
          expect(seminar.title).to eq(original_title)
        end
        
        it 'renders the edit template' do
          patch :update, params: invalid_update_params
          expect(response).to render_template(:edit)
          expect(response.status).to eq(422)
        end
      end
    end
    
    context 'when user does not own the seminar' do
      before { sign_in(other_user) }
      
      it 'redirects to seminars index' do
        patch :update, params: update_params
        expect(response).to redirect_to(seminars_path)
      end
      
      it 'does not update the seminar' do
        original_title = seminar.title
        patch :update, params: update_params
        seminar.reload
        expect(seminar.title).to eq(original_title)
      end
    end
  end
  
  describe 'DELETE #destroy' do
    context 'when user owns the seminar' do
      before { sign_in(user) }
      
      it 'destroys the seminar' do
        seminar # create the seminar
        expect {
          delete :destroy, params: { id: seminar.id }
        }.to change(Seminar, :count).by(-1)
      end
      
      it 'redirects to seminars index' do
        delete :destroy, params: { id: seminar.id }
        expect(response).to redirect_to(seminars_path)
      end
      
      it 'sets success flash message' do
        delete :destroy, params: { id: seminar.id }
        expect(flash[:notice]).to eq('Seminar was successfully deleted.')
      end
    end
    
    context 'when user does not own the seminar' do
      before { sign_in(other_user) }
      
      it 'does not destroy the seminar' do
        seminar # create the seminar
        expect {
          delete :destroy, params: { id: seminar.id }
        }.not_to change(Seminar, :count)
      end
      
      it 'redirects to seminars index' do
        delete :destroy, params: { id: seminar.id }
        expect(response).to redirect_to(seminars_path)
      end
      
      it 'sets alert flash message' do
        delete :destroy, params: { id: seminar.id }
        expect(flash[:alert]).to eq('You can only delete your own seminars.')
      end
    end
  end
end
require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  describe 'GET #new' do
    it 'returns a successful response' do
      get :new
      expect(response).to be_successful
    end
    
    it 'redirects to root if user already signed in' do
      user = create(:user)
      sign_in(user)
      get :new
      expect(response).to redirect_to(root_path)
    end
  end
  
  describe 'POST #create' do
    let(:valid_params) do
      {
        user: {
          name: 'John Doe',
          email: 'john@example.com',
          password: 'password',
          password_confirmation: 'password',
          belt_rank: 'blue'
        }
      }
    end
    
    context 'with valid parameters' do
      it 'creates a new user' do
        expect {
          post :create, params: valid_params
        }.to change(User, :count).by(1)
      end
      
      it 'signs in the new user' do
        post :create, params: valid_params
        expect(session[:user_id]).to eq(User.last.id)
      end
      
      it 'redirects to root path' do
        post :create, params: valid_params
        expect(response).to redirect_to(root_path)
      end
      
      it 'sets success flash message' do
        post :create, params: valid_params
        expect(flash[:notice]).to eq('Welcome! Your account has been created successfully.')
      end
    end
    
    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          user: {
            name: '',
            email: 'invalid-email',
            password: 'short',
            password_confirmation: 'different',
            belt_rank: 'invalid'
          }
        }
      end
      
      it 'does not create a new user' do
        expect {
          post :create, params: invalid_params
        }.not_to change(User, :count)
      end
      
      it 'does not sign in any user' do
        post :create, params: invalid_params
        expect(session[:user_id]).to be_nil
      end
      
      it 'renders the new template' do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
        expect(response.status).to eq(422)
      end
    end
    
    context 'with duplicate email' do
      before { create(:user, email: 'john@example.com') }
      
      it 'does not create a new user' do
        expect {
          post :create, params: valid_params
        }.not_to change(User, :count)
      end
      
      it 'renders the new template with errors' do
        post :create, params: valid_params
        expect(response).to render_template(:new)
        expect(response.status).to eq(422)
      end
    end
    
    context 'rate limiting' do
      it 'allows creating account from new IP' do
        post :create, params: valid_params
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
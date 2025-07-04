require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
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
    let(:user) { create(:user, email: 'test@example.com', password: 'password') }
    
    context 'with valid credentials' do
      it 'signs in the user' do
        post :create, params: { email: 'test@example.com', password: 'password' }
        expect(session[:user_id]).to eq(user.id)
      end
      
      it 'updates sign in information' do
        expect_any_instance_of(User).to receive(:update_sign_in_info!).with(request.remote_ip)
        post :create, params: { email: 'test@example.com', password: 'password' }
      end
      
      it 'redirects to root path' do
        post :create, params: { email: 'test@example.com', password: 'password' }
        expect(response).to redirect_to(root_path)
      end
      
      it 'redirects back to intended page if stored' do
        session[:return_to] = '/seminars'
        post :create, params: { email: 'test@example.com', password: 'password' }
        expect(response).to redirect_to('/seminars')
      end
    end
    
    context 'with invalid credentials' do
      it 'does not sign in the user' do
        post :create, params: { email: 'test@example.com', password: 'wrong' }
        expect(session[:user_id]).to be_nil
      end
      
      it 'sets flash alert message' do
        post :create, params: { email: 'test@example.com', password: 'wrong' }
        expect(flash[:alert]).to eq('Invalid email or password')
      end
      
      it 'renders the new template' do
        post :create, params: { email: 'test@example.com', password: 'wrong' }
        expect(response).to render_template(:new)
        expect(response.status).to eq(422)
      end
    end
    
    context 'with non-existent email' do
      it 'does not sign in the user' do
        post :create, params: { email: 'nonexistent@example.com', password: 'password' }
        expect(session[:user_id]).to be_nil
      end
      
      it 'sets flash alert message' do
        post :create, params: { email: 'nonexistent@example.com', password: 'password' }
        expect(flash[:alert]).to eq('Invalid email or password')
      end
    end
  end
  
  describe 'DELETE #destroy' do
    let(:user) { create(:user) }
    
    before { sign_in(user) }
    
    it 'signs out the user' do
      delete :destroy
      expect(session[:user_id]).to be_nil
    end
    
    it 'redirects to root path' do
      delete :destroy
      expect(response).to redirect_to(root_path)
    end
    
    it 'sets flash notice' do
      delete :destroy
      expect(flash[:notice]).to eq('You have been signed out successfully.')
    end
  end
end
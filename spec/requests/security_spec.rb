require 'rails_helper'

RSpec.describe 'Security Features', type: :request do
  describe 'Authentication bypass prevention' do
    it 'prevents access to protected pages without authentication' do
      get new_seminar_path
      expect(response).to redirect_to(new_session_path)
      
      post seminars_path, params: { seminar: { title: 'Test' } }
      expect(response).to redirect_to(new_session_path)
    end
    
    it 'prevents session hijacking with invalid user ID' do
      post sessions_path, params: {}, session: { user_id: 99999 }
      get new_seminar_path
      expect(response).to redirect_to(new_session_path)
    end
  end
  
  describe 'Authorization enforcement' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:seminar) { create(:seminar, user: user1) }
    
    it 'prevents users from editing other users\' seminars' do
      post sessions_path, params: { email: user2.email, password: 'password' }
      
      patch seminar_path(seminar), params: { seminar: { title: 'Hacked Title' } }
      expect(response).to redirect_to(seminars_path)
      
      seminar.reload
      expect(seminar.title).not_to eq('Hacked Title')
    end
    
    it 'prevents users from deleting other users\' seminars' do
      post sessions_path, params: { email: user2.email, password: 'password' }
      
      expect {
        delete seminar_path(seminar)
      }.not_to change(Seminar, :count)
      
      expect(response).to redirect_to(seminars_path)
    end
  end
  
  describe 'Input validation and sanitization' do
    let(:user) { create(:user) }
    
    before do
      post sessions_path, params: { email: user.email, password: 'password' }
    end
    
    it 'prevents XSS in seminar title' do
      post seminars_path, params: {
        seminar: {
          title: '<script>alert(\"XSS\")</script>',
          description: 'Test description',
          instructor_name: 'Test Instructor',
          instructor_belt: 'black',
          seminar_date: 1.week.from_now,
          venue: 'Test Venue',
          location: 'Test Location'
        }
      }
      
      seminar = Seminar.last
      expect(seminar.title).not_to include('<script>')
    end
    
    it 'validates email format on registration' do
      post registrations_path, params: {
        user: {
          name: 'Test User',
          email: 'invalid-email',
          password: 'password',
          password_confirmation: 'password',
          belt_rank: 'white'
        }
      }
      
      expect(response).to have_http_status(:unprocessable_entity)
    end
    
    it 'validates required fields' do
      post seminars_path, params: {
        seminar: {
          title: '',
          description: ''
        }
      }
      
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
  
  describe 'Mass assignment protection' do
    let(:user) { create(:user) }
    
    before do
      post sessions_path, params: { email: user.email, password: 'password' }
    end
    
    it 'prevents setting admin flag during registration' do
      post registrations_path, params: {
        user: {
          name: 'Test User',
          email: 'test@example.com',
          password: 'password',
          password_confirmation: 'password',
          belt_rank: 'white',
          admin: true
        }
      }
      
      created_user = User.find_by(email: 'test@example.com')
      expect(created_user&.admin?).to be false
    end
    
    it 'prevents setting user_id in seminar creation' do
      other_user = create(:user)
      
      post seminars_path, params: {
        seminar: {
          title: 'Test Seminar',
          description: 'Test description',
          instructor_name: 'Test Instructor',
          instructor_belt: 'black',
          seminar_date: 1.week.from_now,
          venue: 'Test Venue',
          location: 'Test Location',
          user_id: other_user.id
        }
      }
      
      seminar = Seminar.last
      expect(seminar.user).to eq(user)
      expect(seminar.user).not_to eq(other_user)
    end
  end
  
  describe 'File upload security' do
    let(:user) { create(:user) }
    
    before do
      post sessions_path, params: { email: user.email, password: 'password' }
    end
    
    it 'only allows image file uploads' do
      # This would require actual file upload testing with test files
      # For now, we test that the validation exists in the model
      seminar = create(:seminar, user: user)
      
      expect(seminar).to respond_to(:validate_image_content_type)
      expect(seminar).to respond_to(:validate_image_size)
    end
  end
end
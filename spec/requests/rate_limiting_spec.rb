require 'rails_helper'

RSpec.describe 'Rate Limiting', type: :request do
  before do
    # Enable rate limiting for tests
    Rack::Attack.enabled = true
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end
  
  after do
    # Clean up rate limiting cache
    Rack::Attack.cache.store.clear
    Rack::Attack.enabled = false
  end
  
  describe 'Registration rate limiting' do
    it 'allows first registration from an IP' do
      post registrations_path, params: {
        user: {
          name: 'Test User',
          email: 'test1@example.com',
          password: 'password',
          password_confirmation: 'password',
          belt_rank: 'white'
        }
      }
      
      expect(response).to have_http_status(:redirect)
    end
    
    it 'blocks second registration from same IP within 24 hours' do
      # First registration
      post registrations_path, params: {
        user: {
          name: 'Test User 1',
          email: 'test1@example.com',
          password: 'password',
          password_confirmation: 'password',
          belt_rank: 'white'
        }
      }
      
      # Second registration from same IP
      post registrations_path, params: {
        user: {
          name: 'Test User 2',
          email: 'test2@example.com',
          password: 'password',
          password_confirmation: 'password',
          belt_rank: 'white'
        }
      }
      
      expect(response).to have_http_status(:too_many_requests)
    end
  end
  
  describe 'Login rate limiting' do
    let(:user) { create(:user, email: 'test@example.com', password: 'password') }
    
    it 'allows multiple successful logins' do
      3.times do
        post sessions_path, params: { email: 'test@example.com', password: 'password' }
        delete session_path
      end
      
      post sessions_path, params: { email: 'test@example.com', password: 'password' }
      expect(response).to have_http_status(:redirect)
    end
    
    it 'blocks IP after too many failed login attempts' do
      6.times do
        post sessions_path, params: { email: 'test@example.com', password: 'wrong' }
      end
      
      expect(response).to have_http_status(:too_many_requests)
    end
    
    it 'blocks email after too many failed attempts' do
      4.times do
        post sessions_path, params: { email: 'test@example.com', password: 'wrong' }
      end
      
      expect(response).to have_http_status(:too_many_requests)
    end
  end
  
  describe 'Seminar creation rate limiting' do
    let(:user) { create(:user) }
    
    before do
      post sessions_path, params: { email: user.email, password: 'password' }
    end
    
    it 'allows creating seminars within limit' do
      25.times do |i|
        post seminars_path, params: {
          seminar: {
            title: \"Test Seminar #{i}\",
            description: 'Test description for seminar',
            instructor_name: 'Test Instructor',
            instructor_belt: 'black',
            seminar_date: 1.week.from_now,
            venue: 'Test Venue',
            location: 'Test Location'
          }
        }
        
        expect(response).not_to have_http_status(:too_many_requests)
      end
    end
    
    it 'blocks creating too many seminars in one day' do
      # Create seminars up to the limit
      26.times do |i|
        post seminars_path, params: {
          seminar: {
            title: \"Test Seminar #{i}\",
            description: 'Test description for seminar',
            instructor_name: 'Test Instructor',
            instructor_belt: 'black',
            seminar_date: 1.week.from_now,
            venue: 'Test Venue',
            location: 'Test Location'
          }
        }
      end
      
      expect(response).to have_http_status(:too_many_requests)
    end
  end
  
  describe 'General request rate limiting' do
    it 'allows normal request volume' do
      250.times do
        get root_path
        expect(response).not_to have_http_status(:too_many_requests)
      end
    end
    
    it 'blocks excessive requests from single IP' do
      350.times do
        get root_path
      end
      
      expect(response).to have_http_status(:too_many_requests)
    end
  end
  
  describe 'Rate limit headers' do
    it 'includes rate limit information in headers' do
      get root_path
      
      expect(response.headers['X-RateLimit-Limit']).to be_present
      expect(response.headers['X-RateLimit-Remaining']).to be_present
    end
  end
end
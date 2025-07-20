require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe 'GET #index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end
    
    it 'does not require authentication' do
      get :index
      expect(response).to be_successful
      expect(response).not_to redirect_to(login_path)
    end
    
    describe '@recent_seminars' do
      let!(:today_seminar) { create(:seminar, starts_at: 2.hours.from_now) }
      let!(:tomorrow_seminar) { create(:seminar, starts_at: 1.day.from_now) }
      let!(:next_week_seminar) { create(:seminar, starts_at: 1.week.from_now) }
      let!(:far_future_seminars) do
        4.times.map { |i| create(:seminar, starts_at: (2 + i).weeks.from_now) }
      end
      
      before { get :index }
      
      it 'includes future seminars' do
        expect(assigns(:recent_seminars)).to include(today_seminar, tomorrow_seminar, next_week_seminar)
      end
      
      it 'orders seminars by start date' do
        seminars = assigns(:recent_seminars)
        expect(seminars.first.starts_at).to be < seminars.last.starts_at
      end
      
      it 'limits to 6 seminars' do
        expect(assigns(:recent_seminars).size).to eq(6)
      end
      
      it 'includes necessary associations to avoid N+1 queries' do
        # This test verifies eager loading is set up correctly
        expect(assigns(:recent_seminars).first.association(:user).loaded?).to be true
        expect(assigns(:recent_seminars).first.association(:players).loaded?).to be true
        expect(assigns(:recent_seminars).first.association(:images_attachments).loaded?).to be true
      end
    end
    
    describe '@featured_seminars' do
      before { get :index }
      
      it 'is assigned as an empty array' do
        expect(assigns(:featured_seminars)).to eq([])
      end
    end
    
    describe '@popular_instructors' do
      let!(:instructor1) { create(:player, name: 'Gordon Ryan') }
      let!(:instructor2) { create(:player, name: 'Craig Jones') }
      let!(:instructor3) { create(:player, name: 'John Danaher') }
      let!(:instructor4) { create(:player, name: 'Marcelo Garcia') }
      
      before do
        # Create upcoming seminars with different instructors
        3.times { create(:seminar, starts_at: 1.week.from_now).players << instructor1 }
        2.times { create(:seminar, starts_at: 2.weeks.from_now).players << instructor2 }
        2.times { create(:seminar, starts_at: 3.weeks.from_now).players << instructor3 }
        1.times { create(:seminar, starts_at: 4.weeks.from_now).players << instructor4 }
        
        get :index
      end
      
      it 'includes instructors with upcoming seminars' do
        expect(assigns(:popular_instructors)).to include(instructor1, instructor2, instructor3)
      end
      
      it 'orders instructors by seminar count' do
        instructors = assigns(:popular_instructors)
        expect(instructors.first).to eq(instructor1) # 3 upcoming seminars
        expect(instructors.second).to be_in([instructor2, instructor3]) # Both have 2 seminars
      end
      
      it 'limits to 6 instructors' do
        # Create more instructors
        7.times do |i|
          instructor = create(:player)
          create(:seminar, starts_at: 1.day.from_now).players << instructor
        end
        
        get :index
        expect(assigns(:popular_instructors).size).to eq(6)
      end
      
      it 'counts upcoming seminars correctly' do
        # instructor1 has 3 upcoming seminars
        instructor_seminar_counts = {}
        assigns(:popular_instructors).each do |instructor|
          count = instructor.seminars.where("starts_at > ?", Time.current).count
          instructor_seminar_counts[instructor.id] = count
        end
        
        expect(instructor_seminar_counts[instructor1.id]).to eq(3)
        expect(instructor_seminar_counts[instructor2.id]).to eq(2)
        expect(instructor_seminar_counts[instructor3.id]).to eq(2)
      end
    end
    
    describe 'when user is signed in' do
      let(:user) { create(:user) }
      
      before do
        sign_in(user)
        get :index
      end
      
      it 'still returns a successful response' do
        expect(response).to be_successful
      end
      
      it 'has access to current_user' do
        expect(controller.current_user).to eq(user)
      end
    end
  end
end
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }
    
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should have_secure_password }
    
    describe 'email format validation' do
      it 'rejects invalid email formats' do
        invalid_emails = ['invalid', 'test@', '@domain.com', 'test@domain', 'test @example.com']
        invalid_emails.each do |email|
          user = build(:user, email: email)
          expect(user).not_to be_valid
          expect(user.errors[:email]).to include("is invalid")
        end
      end
      
      it 'accepts valid email formats' do
        valid_emails = ['test@example.com', 'user+tag@domain.co.uk', 'test.user@sub.domain.org']
        valid_emails.each do |email|
          user = build(:user, email: email)
          expect(user).to be_valid
        end
      end
    end
  end

  describe 'associations' do
    it { should have_many(:seminars).dependent(:destroy) }
    it { should have_many(:notification_requests).dependent(:destroy) }
    it { should have_many(:notification_deliveries).dependent(:destroy) }
  end

  describe 'scopes' do
    let!(:admin) { create(:user, :admin) }
    let!(:regular_user) { create(:user) }
    
    describe '.admins' do
      it 'returns only admin users' do
        expect(User.admins).to contain_exactly(admin)
      end
    end
  end

  describe 'secure password' do
    it 'authenticates with correct password' do
      user = build(:user, password: 'password123')
      expect(user.authenticate('password123')).to eq(user)
    end

    it 'fails authentication with incorrect password' do
      user = build(:user, password: 'password123')
      expect(user.authenticate('wrongpassword')).to be false
    end
  end

  describe '#name' do
    it 'returns email when no name is set' do
      user = build(:user, email: 'test@example.com')
      expect(user.name).to eq('test@example.com')
    end
  end

  describe '#admin?' do
    it 'returns true for admin users' do
      admin = build(:user, admin: true)
      expect(admin.admin?).to be true
    end
    
    it 'returns false for regular users' do
      user = build(:user, admin: false)
      expect(user.admin?).to be false
    end
  end

  describe 'daily seminar limit functionality' do
    let(:user) { create(:user) }

    describe '#can_create_seminar?' do
      context 'when user has not created any seminars today' do
        it 'returns true' do
          expect(user.can_create_seminar?).to be true
        end
      end
      
      context 'when user has created seminars but within limit' do
        it 'returns true' do
          user.update(daily_seminar_count: 10, last_seminar_created_at: Time.current)
          expect(user.can_create_seminar?).to be true
        end
      end
      
      context 'when user has reached daily limit' do
        it 'returns false' do
          user.update(daily_seminar_count: 25, last_seminar_created_at: Time.current)
          expect(user.can_create_seminar?).to be false
        end
      end
      
      context 'when admin user has reached daily limit' do
        it 'returns true (admins have no limit)' do
          admin = create(:user, :admin, daily_seminar_count: 25, last_seminar_created_at: Time.current)
          expect(admin.can_create_seminar?).to be true
        end
      end
      
      context 'when counter needs to be reset (new day)' do
        it 'resets counter and returns true' do
          user.update(daily_seminar_count: 25, last_seminar_created_at: 2.days.ago)
          expect(user.can_create_seminar?).to be true
          user.reload
          expect(user.daily_seminar_count).to eq(0)
        end
      end

      context 'when last_seminar_created_at is different day but same calendar date in different timezone' do
        it 'correctly handles timezone boundaries' do
          # Set user's last creation to yesterday at 11:59 PM
          user.update(
            daily_seminar_count: 25, 
            last_seminar_created_at: Time.current.beginning_of_day - 1.minute
          )
          expect(user.can_create_seminar?).to be true
        end
      end
    end

    describe '#increment_seminar_count!' do
      it 'increments the daily seminar count' do
        expect { user.increment_seminar_count! }.to change { user.daily_seminar_count }.by(1)
      end
      
      it 'updates last_seminar_created_at' do
        freeze_time = Time.current
        user.increment_seminar_count!
        expect(user.last_seminar_created_at).to be_within(1.second).of(freeze_time)
      end
      
      it 'resets counter when incrementing on a new day' do
        user.update(daily_seminar_count: 10, last_seminar_created_at: 2.days.ago)
        user.increment_seminar_count!
        expect(user.daily_seminar_count).to eq(1)
      end
    end

    describe '#seminars_created_today' do
      it 'returns the daily seminar count when last created today' do
        user.update(daily_seminar_count: 5, last_seminar_created_at: Time.current)
        expect(user.seminars_created_today).to eq(5)
      end
      
      it 'returns 0 when last seminar was created on a different day' do
        user.update(daily_seminar_count: 5, last_seminar_created_at: 2.days.ago)
        expect(user.seminars_created_today).to eq(0)
      end
    end

    describe '#remaining_seminars_today' do
      it 'calculates remaining seminars correctly' do
        user.update(daily_seminar_count: 10, last_seminar_created_at: Time.current)
        expect(user.remaining_seminars_today).to eq(15)
      end
      
      it 'returns full limit when no seminars created today' do
        expect(user.remaining_seminars_today).to eq(25)
      end
      
      it 'returns nil for admin users' do
        admin = create(:user, :admin)
        expect(admin.remaining_seminars_today).to be_nil
      end
    end
  end

  describe '#track_sign_in!' do
    let(:user) { create(:user) }
    let(:ip_address) { '192.168.1.1' }
    
    it 'updates sign in tracking fields' do
      freeze_time = Time.current
      user.track_sign_in!(ip_address)
      
      expect(user.sign_in_count).to eq(1)
      expect(user.current_sign_in_at).to be_within(1.second).of(freeze_time)
      expect(user.last_sign_in_at).to be_within(1.second).of(freeze_time)
      expect(user.current_sign_in_ip).to eq(ip_address)
      expect(user.last_sign_in_ip).to eq(ip_address)
    end
    
    it 'preserves previous sign in data on subsequent sign ins' do
      first_ip = '192.168.1.1'
      second_ip = '192.168.1.2'
      
      # First sign in
      user.track_sign_in!(first_ip)
      first_sign_in_time = user.current_sign_in_at
      
      # Wait a moment and sign in again
      sleep(0.01)
      user.track_sign_in!(second_ip)
      
      expect(user.sign_in_count).to eq(2)
      expect(user.current_sign_in_at).to be > first_sign_in_time
      expect(user.last_sign_in_at).to eq(first_sign_in_time)
      expect(user.current_sign_in_ip).to eq(second_ip)
      expect(user.last_sign_in_ip).to eq(first_ip)
    end
  end
end
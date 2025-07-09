require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }
    
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:password_digest) }
    
    it 'validates email format' do
      invalid_emails = ['invalid', 'test@', '@domain.com', 'test@domain']
      invalid_emails.each do |email|
        user = build(:user, email: email)
        expect(user).not_to be_valid
        expect(user.errors[:email]).to be_present
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

  describe 'associations' do
    it { should have_many(:seminars).dependent(:destroy) }
    it { should have_many(:notification_requests).dependent(:destroy) }
    it { should have_many(:notification_deliveries).dependent(:destroy) }
  end

  describe 'secure password' do
    it 'has secure password functionality' do
      user = build(:user, password: 'password123')
      expect(user.authenticate('password123')).to eq(user)
      expect(user.authenticate('wrong')).to be false
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

  describe '#can_create_seminar?' do
    let(:user) { create(:user) }
    
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
    
    context 'when counter needs to be reset (new day)' do
      it 'resets counter and returns true' do
        user.update(daily_seminar_count: 25, last_seminar_created_at: 2.days.ago)
        expect(user.can_create_seminar?).to be true
        user.reload
        expect(user.daily_seminar_count).to eq(0)
      end
    end
  end

  describe '#increment_seminar_count!' do
    let(:user) { create(:user) }
    
    it 'increments the daily seminar count' do
      expect { user.increment_seminar_count! }.to change { user.daily_seminar_count }.by(1)
    end
    
    it 'updates the last seminar created timestamp' do
      freeze_time do
        user.increment_seminar_count!
        expect(user.last_seminar_created_at).to be_within(1.second).of(Time.current)
      end
    end
  end

  describe '#reset_daily_counters' do
    let(:user) { create(:user) }
    
    before do
      user.update(daily_seminar_count: 10, last_seminar_created_at: 1.day.ago)
    end
    
    it 'resets daily seminar count to 0' do
      user.send(:reset_daily_counters)
      expect(user.daily_seminar_count).to eq(0)
    end
    
    it 'updates last seminar created timestamp' do
      freeze_time do
        user.send(:reset_daily_counters)
        expect(user.last_seminar_created_at).to be_within(1.second).of(Time.current)
      end
    end
  end

  describe '#needs_counter_reset?' do
    let(:user) { create(:user) }
    
    it 'returns true when last_seminar_created_at is nil' do
      user.update(last_seminar_created_at: nil)
      expect(user.send(:needs_counter_reset?)).to be true
    end
    
    it 'returns true when last creation was on a different day' do
      user.update(last_seminar_created_at: 2.days.ago)
      expect(user.send(:needs_counter_reset?)).to be true
    end
    
    it 'returns false when last creation was today' do
      user.update(last_seminar_created_at: 1.hour.ago)
      expect(user.send(:needs_counter_reset?)).to be false
    end
  end

  describe 'email uniqueness' do
    it 'enforces unique emails case-insensitively' do
      create(:user, email: 'test@example.com')
      duplicate = build(:user, email: 'TEST@example.com')
      
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include('has already been taken')
    end
  end

  describe 'admin defaults' do
    it 'defaults admin to false' do
      user = User.new
      expect(user.admin).to be false
    end
  end

  describe 'daily seminar count defaults' do
    it 'defaults daily_seminar_count to 0' do
      user = User.new
      expect(user.daily_seminar_count).to eq(0)
    end
  end
end
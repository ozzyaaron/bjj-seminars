require 'rails_helper'

RSpec.describe NotificationDelivery, type: :model do
  let(:user) { create(:user) }
  let(:seminar) { create(:seminar) }
  
  describe 'validations' do
    subject { build(:notification_delivery, user: user, seminar: seminar) }
    
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:seminar_id) }
    it { should validate_presence_of(:delivered_at) }
    
    describe 'uniqueness validation' do
      it 'prevents duplicate deliveries for same user and seminar' do
        create(:notification_delivery, user: user, seminar: seminar)
        duplicate = build(:notification_delivery, user: user, seminar: seminar)
        
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:user_id]).to include('Notification already delivered for this seminar')
      end
      
      it 'allows deliveries for different users' do
        create(:notification_delivery, user: user, seminar: seminar)
        other_user = create(:user)
        different_user_delivery = build(:notification_delivery, user: other_user, seminar: seminar)
        
        expect(different_user_delivery).to be_valid
      end
      
      it 'allows deliveries for different seminars' do
        create(:notification_delivery, user: user, seminar: seminar)
        other_seminar = create(:seminar)
        different_seminar_delivery = build(:notification_delivery, user: user, seminar: other_seminar)
        
        expect(different_seminar_delivery).to be_valid
      end
    end
  end
  
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:seminar) }
  end
  
  describe 'scopes' do
    let(:user2) { create(:user) }
    let(:seminar2) { create(:seminar) }
    let!(:recent_delivery) { create(:notification_delivery, user: user, seminar: seminar, delivered_at: 1.hour.ago) }
    let!(:old_delivery) { create(:notification_delivery, user: user2, seminar: seminar2, delivered_at: 2.days.ago) }
    let!(:today_delivery) { create(:notification_delivery, user: user, seminar: seminar2, delivered_at: 10.minutes.ago) }
    
    describe '.recent' do
      it 'orders by delivered_at descending' do
        expect(NotificationDelivery.recent).to eq([today_delivery, recent_delivery, old_delivery])
      end
    end
    
    describe '.for_user' do
      it 'returns deliveries for specific user' do
        expect(NotificationDelivery.for_user(user)).to contain_exactly(recent_delivery, today_delivery)
      end
    end
    
    describe '.for_seminar' do
      it 'returns deliveries for specific seminar' do
        expect(NotificationDelivery.for_seminar(seminar)).to contain_exactly(recent_delivery)
      end
    end
    
    describe '.delivered_today' do
      it 'returns only deliveries from today' do
        expect(NotificationDelivery.delivered_today).to contain_exactly(today_delivery)
      end
    end
    
    describe '.delivered_since' do
      it 'returns deliveries since specified date' do
        expect(NotificationDelivery.delivered_since(1.day.ago)).to contain_exactly(recent_delivery, today_delivery)
      end
    end
  end
  
  describe '.record_delivery!' do
    it 'creates a new delivery record' do
      expect {
        NotificationDelivery.record_delivery!(user, seminar)
      }.to change(NotificationDelivery, :count).by(1)
      
      delivery = NotificationDelivery.last
      expect(delivery.user).to eq(user)
      expect(delivery.seminar).to eq(seminar)
      expect(delivery.delivered_at).to be_within(1.second).of(Time.current)
    end
    
    it 'raises error if duplicate delivery attempted' do
      NotificationDelivery.record_delivery!(user, seminar)
      
      expect {
        NotificationDelivery.record_delivery!(user, seminar)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
  
  describe '.bulk_record_deliveries!' do
    let(:user2) { create(:user) }
    let(:seminar2) { create(:seminar) }
    
    it 'creates multiple delivery records' do
      deliveries = [[user, seminar], [user2, seminar2]]
      
      expect {
        NotificationDelivery.bulk_record_deliveries!(deliveries)
      }.to change(NotificationDelivery, :count).by(2)
    end
    
    it 'ignores duplicates in bulk insert' do
      NotificationDelivery.record_delivery!(user, seminar)
      deliveries = [[user, seminar], [user, seminar2]]
      
      expect {
        NotificationDelivery.bulk_record_deliveries!(deliveries)
      }.to change(NotificationDelivery, :count).by(1)
    end
    
    it 'sets timestamps correctly' do
      deliveries = [[user, seminar]]
      freeze_time = Time.current
      
      NotificationDelivery.bulk_record_deliveries!(deliveries)
      delivery = NotificationDelivery.last
      
      expect(delivery.delivered_at).to be_within(1.second).of(freeze_time)
      expect(delivery.created_at).to be_within(1.second).of(freeze_time)
      expect(delivery.updated_at).to be_within(1.second).of(freeze_time)
    end
  end
  
  describe '.already_delivered?' do
    it 'returns true when delivery exists' do
      create(:notification_delivery, user: user, seminar: seminar)
      expect(NotificationDelivery.already_delivered?(user, seminar)).to be true
    end
    
    it 'returns false when delivery does not exist' do
      expect(NotificationDelivery.already_delivered?(user, seminar)).to be false
    end
  end
  
  describe '.cleanup_old_deliveries!' do
    let!(:recent_delivery) { create(:notification_delivery, delivered_at: 30.days.ago) }
    let!(:old_delivery) { create(:notification_delivery, delivered_at: 100.days.ago) }
    let!(:very_old_delivery) { create(:notification_delivery, delivered_at: 200.days.ago) }
    
    it 'deletes deliveries older than specified period' do
      expect {
        NotificationDelivery.cleanup_old_deliveries!(older_than: 90.days)
      }.to change(NotificationDelivery, :count).by(-2)
      
      expect(NotificationDelivery.exists?(recent_delivery.id)).to be true
      expect(NotificationDelivery.exists?(old_delivery.id)).to be false
      expect(NotificationDelivery.exists?(very_old_delivery.id)).to be false
    end
    
    it 'returns count of deleted records' do
      count = NotificationDelivery.cleanup_old_deliveries!(older_than: 90.days)
      expect(count).to eq(2)
    end
  end
  
  describe '#time_since_delivery' do
    context 'when delivered less than an hour ago' do
      it 'returns time in minutes' do
        delivery = build(:notification_delivery, delivered_at: 30.minutes.ago)
        expect(delivery.time_since_delivery).to eq('30 minutes ago')
      end
      
      it 'handles 0 minutes' do
        delivery = build(:notification_delivery, delivered_at: 30.seconds.ago)
        expect(delivery.time_since_delivery).to eq('0 minutes ago')
      end
    end
    
    context 'when delivered between 1 hour and 1 day ago' do
      it 'returns time in hours' do
        delivery = build(:notification_delivery, delivered_at: 3.hours.ago)
        expect(delivery.time_since_delivery).to eq('3 hours ago')
      end
      
      it 'rounds down to nearest hour' do
        delivery = build(:notification_delivery, delivered_at: 2.hours.and(45.minutes).ago)
        expect(delivery.time_since_delivery).to eq('2 hours ago')
      end
    end
    
    context 'when delivered more than a day ago' do
      it 'returns time in days' do
        delivery = build(:notification_delivery, delivered_at: 5.days.ago)
        expect(delivery.time_since_delivery).to eq('5 days ago')
      end
      
      it 'rounds down to nearest day' do
        delivery = build(:notification_delivery, delivered_at: 1.day.and(23.hours).ago)
        expect(delivery.time_since_delivery).to eq('1 days ago')
      end
    end
    
    context 'when delivered_at is nil' do
      it 'returns nil' do
        delivery = build(:notification_delivery, delivered_at: nil)
        expect(delivery.time_since_delivery).to be_nil
      end
    end
  end
end
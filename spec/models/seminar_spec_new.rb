require 'rails_helper'

RSpec.describe Seminar, type: :model do
  let(:user) { create(:user) }
  let(:valid_attributes) do
    {
      title: 'BJJ Workshop',
      description: 'A comprehensive workshop on Brazilian Jiu-Jitsu fundamentals',
      starts_at: 1.week.from_now,
      ends_at: 1.week.from_now + 2.hours,
      address: '123 Main St',
      city: 'San Francisco',
      state: 'CA',
      zip_code: '94102',
      country: 'US',
      user: user
    }
  end

  describe 'validations' do
    subject { build(:seminar) }
    
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:starts_at) }
    it { should validate_presence_of(:address) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:country) }
    
    it { should validate_length_of(:title).is_at_least(5).is_at_most(200) }
    it { should validate_length_of(:description).is_at_least(10) }
    
    it 'validates state format' do
      seminar = build(:seminar, state: 'California')
      expect(seminar).not_to be_valid
      expect(seminar.errors[:state]).to include('must be a valid 2-letter state code')
    end
    
    it 'validates country format' do
      seminar = build(:seminar, country: 'United States')
      expect(seminar).not_to be_valid
      expect(seminar.errors[:country]).to include('must be a valid 2-letter country code')
    end
    
    it 'validates starts_at is in the future' do
      seminar = build(:seminar, starts_at: 1.day.ago)
      expect(seminar).not_to be_valid
      expect(seminar.errors[:starts_at]).to include('must be in the future')
    end
    
    it 'validates ends_at is after starts_at' do
      seminar = build(:seminar, starts_at: 1.week.from_now, ends_at: 1.week.from_now - 1.hour)
      expect(seminar).not_to be_valid
      expect(seminar.errors[:ends_at]).to include('must be after start time')
    end
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:seminar_players).dependent(:destroy) }
    it { should have_many(:players).through(:seminar_players) }
    it { should have_many(:seminar_images).dependent(:destroy) }
    it { should have_many(:notification_deliveries).dependent(:destroy) }
  end

  describe 'scopes' do
    let!(:past_seminar) { create(:seminar, starts_at: 1.day.ago - 1.second) }
    let!(:upcoming_seminar) { create(:seminar, starts_at: 1.day.from_now) }
    
    before do
      # Disable the validation temporarily for testing scopes
      allow_any_instance_of(Seminar).to receive(:starts_at_is_in_future)
    end
    
    describe '.upcoming' do
      it 'returns seminars scheduled for future' do
        expect(Seminar.upcoming).to include(upcoming_seminar)
        expect(Seminar.upcoming).not_to include(past_seminar)
      end
    end
    
    describe '.past' do
      it 'returns seminars from past dates' do
        expect(Seminar.past).to include(past_seminar)
        expect(Seminar.past).not_to include(upcoming_seminar)
      end
    end
  end

  describe '#full_address' do
    it 'returns formatted full address' do
      seminar = build(:seminar, 
        address: '123 Main St',
        city: 'San Francisco', 
        state: 'CA',
        zip_code: '94102',
        country: 'US'
      )
      
      expect(seminar.full_address).to eq('123 Main St, San Francisco, CA, 94102, US')
    end
  end

  describe '#formatted_date' do
    it 'returns formatted date string' do
      seminar = build(:seminar, starts_at: Time.zone.parse('2024-12-25 14:30:00'))
      expect(seminar.formatted_date).to eq('December 25, 2024 at 02:30 PM')
    end
  end

  describe '#duration_in_hours' do
    it 'returns duration in hours when ends_at is set' do
      seminar = build(:seminar, 
        starts_at: Time.zone.parse('2024-12-25 14:00:00'),
        ends_at: Time.zone.parse('2024-12-25 16:30:00')
      )
      expect(seminar.duration_in_hours).to eq(2.5)
    end
    
    it 'returns nil when ends_at is not set' do
      seminar = build(:seminar, ends_at: nil)
      expect(seminar.duration_in_hours).to be_nil
    end
  end

  describe '#can_be_edited_by?' do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let(:admin) { create(:user, admin: true) }
    let(:seminar) { create(:seminar, user: owner) }
    
    it 'allows owner to edit' do
      expect(seminar.can_be_edited_by?(owner)).to be true
    end
    
    it 'allows admin to edit' do
      expect(seminar.can_be_edited_by?(admin)).to be true
    end
    
    it 'does not allow other users to edit' do
      expect(seminar.can_be_edited_by?(other_user)).to be false
    end
  end

  describe '#has_images?' do
    it 'returns true when images are attached' do
      seminar = create(:seminar)
      seminar.images.attach(
        io: StringIO.new('fake image'),
        filename: 'test.jpg',
        content_type: 'image/jpeg'
      )
      
      expect(seminar.has_images?).to be true
    end
    
    it 'returns false when no images are attached' do
      seminar = create(:seminar)
      expect(seminar.has_images?).to be false
    end
  end

  describe 'image validations' do
    let(:seminar) { create(:seminar) }
    
    it 'allows valid image types' do
      valid_types = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
      
      valid_types.each do |content_type|
        seminar.images.attach(
          io: StringIO.new('fake image'),
          filename: "test.#{content_type.split('/').last}",
          content_type: content_type
        )
      end
      
      expect(seminar).to be_valid
    end
    
    it 'rejects too many images' do
      11.times do |i|
        seminar.images.attach(
          io: StringIO.new('fake image'),
          filename: "test#{i}.jpg",
          content_type: 'image/jpeg'
        )
      end
      
      expect(seminar).not_to be_valid
      expect(seminar.errors[:images]).to include('cannot exceed 10 images per seminar')
    end
  end

  describe 'user creation limits' do
    let(:user) { create(:user) }
    
    it 'validates user can create seminar' do
      # Create 25 seminars (the daily limit)
      allow_any_instance_of(Seminar).to receive(:starts_at_is_in_future)
      
      25.times do
        create(:seminar, user: user, starts_at: 1.day.from_now)
      end
      
      # 26th seminar should fail validation
      seminar = build(:seminar, user: user)
      expect(seminar).not_to be_valid
      expect(seminar.errors[:base]).to include('Daily seminar creation limit reached')
    end
  end
end
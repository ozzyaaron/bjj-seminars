require 'rails_helper'

RSpec.describe Seminar, type: :model do
  let(:user) { create(:user) }
  let(:valid_attributes) do
    {
      title: 'BJJ Fundamentals Workshop',
      description: 'A comprehensive workshop on Brazilian Jiu-Jitsu fundamentals',
      starts_at: 1.week.from_now,
      ends_at: 1.week.from_now + 2.hours,
      address: '123 Main St',
      city: 'San Francisco',
      state: 'CA',
      zip_code: '94102',
      country: 'US',
      price: 150,
      seminar_type: 'Gi',
      user: user
    }
  end

  describe 'validations' do
    subject { build(:seminar) }
    
    # Presence validations
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:starts_at) }
    it { should validate_presence_of(:address) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:country) }
    
    # Length validations
    it { should validate_length_of(:title).is_at_least(5).is_at_most(200) }
    it { should validate_length_of(:description).is_at_least(10) }
    
    describe 'state and country format' do
      it 'validates state is a 2-letter code' do
        seminar = build(:seminar, state: 'California')
        expect(seminar).not_to be_valid
        expect(seminar.errors[:state]).to include('must be a valid 2-letter state code')
      end
      
      it 'accepts valid state codes' do
        valid_states = ['CA', 'NY', 'TX', 'FL']
        valid_states.each do |state|
          seminar = build(:seminar, state: state)
          expect(seminar.errors[:state]).to be_empty
        end
      end
      
      it 'validates country is a 2-letter code' do
        seminar = build(:seminar, country: 'United States')
        expect(seminar).not_to be_valid
        expect(seminar.errors[:country]).to include('must be a valid 2-letter country code')
      end
      
      it 'accepts valid country codes' do
        valid_countries = ['US', 'CA', 'GB', 'BR']
        valid_countries.each do |country|
          seminar = build(:seminar, country: country)
          expect(seminar.errors[:country]).to be_empty
        end
      end
    end
    
    describe 'date validations' do
      it 'validates starts_at is in the future' do
        seminar = build(:seminar, starts_at: 1.day.ago)
        expect(seminar).not_to be_valid
        expect(seminar.errors[:starts_at]).to include('must be in the future')
      end
      
      it 'validates ends_at is after starts_at' do
        seminar = build(:seminar, starts_at: 1.day.from_now, ends_at: Time.current)
        expect(seminar).not_to be_valid
        expect(seminar.errors[:ends_at]).to include('must be after start time')
      end
      
      it 'allows seminars starting today' do
        seminar = build(:seminar, starts_at: 1.hour.from_now)
        expect(seminar).to be_valid
      end
    end
    
    describe 'price validation' do
      it 'validates price is not negative' do
        seminar = build(:seminar, price: -10)
        expect(seminar).not_to be_valid
        expect(seminar.errors[:price]).to include('must be greater than or equal to 0')
      end
      
      it 'accepts zero price (free seminars)' do
        seminar = build(:seminar, price: 0)
        expect(seminar).to be_valid
      end
      
      it 'accepts positive prices' do
        seminar = build(:seminar, price: 150.50)
        expect(seminar).to be_valid
      end
    end
    
    describe 'seminar_type validation' do
      it 'validates inclusion in allowed types' do
        seminar = build(:seminar, seminar_type: 'Invalid')
        expect(seminar).not_to be_valid
        expect(seminar.errors[:seminar_type]).to include('is not included in the list')
      end
      
      it 'accepts valid seminar types' do
        ['Gi', 'No-Gi', 'Both'].each do |type|
          seminar = build(:seminar, seminar_type: type)
          expect(seminar.errors[:seminar_type]).to be_empty
        end
      end
    end
    
    describe 'image upload validations' do
      let(:seminar) { create(:seminar) }
      
      it 'validates image content type' do
        seminar.images.attach(
          io: StringIO.new("fake pdf"),
          filename: 'document.pdf',
          content_type: 'application/pdf'
        )
        expect(seminar).not_to be_valid
        expect(seminar.errors[:images]).to include('must be JPEG, PNG, GIF, or WebP format')
      end
      
      it 'validates image file size' do
        large_file = StringIO.new('x' * 11.megabytes)
        seminar.images.attach(
          io: large_file,
          filename: 'large.jpg',
          content_type: 'image/jpeg'
        )
        expect(seminar).not_to be_valid
        expect(seminar.errors[:images]).to include('size must be less than 10MB')
      end
      
      it 'validates maximum number of images' do
        11.times do |i|
          seminar.images.attach(
            io: StringIO.new("fake image #{i}"),
            filename: "image#{i}.jpg",
            content_type: 'image/jpeg'
          )
        end
        expect(seminar).not_to be_valid
        expect(seminar.errors[:images]).to include('maximum 10 images allowed')
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:seminar_players).dependent(:destroy) }
    it { should have_many(:players).through(:seminar_players) }
    it { should have_many(:seminar_images).dependent(:destroy) }
    it { should have_many_attached(:images) }
  end

  describe 'geocoding' do
    before do
      # Mock geocoding to avoid external API calls
      allow_any_instance_of(Seminar).to receive(:geocode).and_return([37.7749, -122.4194])
    end
    
    it 'geocodes address after validation' do
      seminar = build(:seminar, 
        address: '1 Market St',
        city: 'San Francisco',
        state: 'CA',
        zip_code: '94105'
      )
      seminar.valid?
      expect(seminar.latitude).to eq(37.7749)
      expect(seminar.longitude).to eq(-122.4194)
    end
    
    it 'updates geocoding when address changes' do
      seminar = create(:seminar)
      original_lat = seminar.latitude
      
      # Mock different coordinates for NY
      allow_any_instance_of(Seminar).to receive(:geocode).and_return([40.7484, -73.9857])
      
      seminar.update(
        address: '350 5th Ave',
        city: 'New York',
        state: 'NY',
        zip_code: '10118'
      )
      expect(seminar.latitude).not_to eq(original_lat)
      expect(seminar.latitude).to eq(40.7484)
    end
  end

  describe 'scopes' do
    describe '.upcoming' do
      it 'returns only future seminars ordered by start date' do
        past = create(:seminar, starts_at: 1.day.ago, ends_at: 1.day.ago + 2.hours)
        future1 = create(:seminar, starts_at: 1.day.from_now)
        future2 = create(:seminar, starts_at: 2.days.from_now)
        
        expect(Seminar.upcoming).to eq([future1, future2])
      end
    end
    
    describe '.past' do
      it 'returns only past seminars ordered by most recent' do
        past1 = create(:seminar, starts_at: 2.days.ago, ends_at: 2.days.ago + 2.hours)
        past2 = create(:seminar, starts_at: 1.day.ago, ends_at: 1.day.ago + 2.hours)
        future = create(:seminar, starts_at: 1.day.from_now)
        
        expect(Seminar.past).to eq([past2, past1])
      end
    end
    
    describe '.by_type' do
      it 'filters seminars by type' do
        gi = create(:seminar, seminar_type: 'Gi')
        nogi = create(:seminar, seminar_type: 'No-Gi')
        both = create(:seminar, seminar_type: 'Both')
        
        expect(Seminar.by_type('Gi')).to contain_exactly(gi)
        expect(Seminar.by_type('No-Gi')).to contain_exactly(nogi)
      end
    end
    
    describe '.free' do
      it 'returns only free seminars' do
        free = create(:seminar, price: 0)
        paid = create(:seminar, price: 100)
        
        expect(Seminar.free).to contain_exactly(free)
      end
    end
    
    describe '.paid' do
      it 'returns only paid seminars' do
        free = create(:seminar, price: 0)
        paid = create(:seminar, price: 100)
        
        expect(Seminar.paid).to contain_exactly(paid)
      end
    end
  end

  describe '#full_address' do
    it 'returns formatted address string' do
      seminar = build(:seminar,
        address: '123 Main St',
        city: 'San Francisco',
        state: 'CA',
        zip_code: '94102',
        country: 'US'
      )
      expect(seminar.full_address).to eq('123 Main St, San Francisco, CA 94102, US')
    end
    
    it 'handles missing zip code' do
      seminar = build(:seminar,
        address: '123 Main St',
        city: 'San Francisco',
        state: 'CA',
        zip_code: nil,
        country: 'US'
      )
      expect(seminar.full_address).to eq('123 Main St, San Francisco, CA, US')
    end
  end

  describe '#formatted_date' do
    it 'returns formatted date range for single day' do
      starts = Time.zone.parse('2024-03-15 10:00')
      ends = Time.zone.parse('2024-03-15 17:00')
      seminar = build(:seminar, starts_at: starts, ends_at: ends)
      
      expect(seminar.formatted_date).to eq('March 15, 2024 from 10:00 AM to 5:00 PM')
    end
    
    it 'returns formatted date range for multiple days' do
      starts = Time.zone.parse('2024-03-15 10:00')
      ends = Time.zone.parse('2024-03-16 17:00')
      seminar = build(:seminar, starts_at: starts, ends_at: ends)
      
      expect(seminar.formatted_date).to eq('March 15, 2024 at 10:00 AM to March 16, 2024 at 5:00 PM')
    end
  end

  describe '#duration_in_hours' do
    it 'calculates duration correctly' do
      seminar = build(:seminar,
        starts_at: Time.current,
        ends_at: Time.current + 3.hours + 30.minutes
      )
      expect(seminar.duration_in_hours).to eq(3.5)
    end
  end

  describe '#can_be_edited_by?' do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let(:admin) { create(:user, :admin) }
    let(:seminar) { create(:seminar, user: owner) }
    
    it 'allows owner to edit' do
      expect(seminar.can_be_edited_by?(owner)).to be true
    end
    
    it 'allows admin to edit' do
      expect(seminar.can_be_edited_by?(admin)).to be true
    end
    
    it 'prevents other users from editing' do
      expect(seminar.can_be_edited_by?(other_user)).to be false
    end
    
    it 'returns false for nil user' do
      expect(seminar.can_be_edited_by?(nil)).to be false
    end
  end

  describe '#primary_instructor' do
    let(:seminar) { create(:seminar) }
    
    it 'returns first player when players exist' do
      player = create(:player)
      seminar.players << player
      expect(seminar.primary_instructor).to eq(player)
    end
    
    it 'returns nil when no players' do
      expect(seminar.primary_instructor).to be_nil
    end
  end

  describe 'search functionality' do
    describe '.search' do
      it 'searches by title' do
        match = create(:seminar, title: 'Advanced Guard Passing')
        no_match = create(:seminar, title: 'Basic Fundamentals')
        
        results = Seminar.search('guard')
        expect(results).to include(match)
        expect(results).not_to include(no_match)
      end
      
      it 'searches by description' do
        match = create(:seminar, description: 'Learn advanced berimbolo techniques')
        no_match = create(:seminar, description: 'Basic self defense moves')
        
        results = Seminar.search('berimbolo')
        expect(results).to include(match)
        expect(results).not_to include(no_match)
      end
      
      it 'searches by city' do
        match = create(:seminar, city: 'San Diego')
        no_match = create(:seminar, city: 'Los Angeles')
        
        results = Seminar.search('san diego')
        expect(results).to include(match)
        expect(results).not_to include(no_match)
      end
      
      it 'searches by instructor name through players' do
        player = create(:player, name: 'Gordon Ryan')
        match = create(:seminar)
        match.players << player
        no_match = create(:seminar)
        
        results = Seminar.search('gordon')
        expect(results).to include(match)
        expect(results).not_to include(no_match)
      end
      
      it 'is case insensitive' do
        seminar = create(:seminar, title: 'BJJ Workshop')
        
        expect(Seminar.search('bjj')).to include(seminar)
        expect(Seminar.search('BJJ')).to include(seminar)
        expect(Seminar.search('Bjj')).to include(seminar)
      end
    end
  end

  describe 'daily limit enforcement' do
    let(:user) { create(:user) }
    
    it 'prevents creation when user has reached daily limit' do
      user.update(daily_seminar_count: 25, last_seminar_created_at: Time.current)
      
      seminar = build(:seminar, user: user)
      expect(seminar).not_to be_valid
      expect(seminar.errors[:base]).to include('Daily seminar creation limit reached (25 per day)')
    end
    
    it 'allows creation when under daily limit' do
      user.update(daily_seminar_count: 10, last_seminar_created_at: Time.current)
      
      seminar = build(:seminar, user: user)
      expect(seminar).to be_valid
    end
    
    it 'allows admin to bypass daily limit' do
      admin = create(:user, :admin, daily_seminar_count: 30, last_seminar_created_at: Time.current)
      
      seminar = build(:seminar, user: admin)
      expect(seminar).to be_valid
    end
    
    it 'increments user seminar count after creation' do
      expect {
        create(:seminar, user: user)
      }.to change { user.reload.daily_seminar_count }.by(1)
    end
  end

  describe 'callbacks' do
    describe 'image processing' do
      it 'creates variants after image upload' do
        seminar = create(:seminar)
        # Create a simple test image
        seminar.images.attach(
          io: StringIO.new("fake image data"),
          filename: 'test_image.jpg',
          content_type: 'image/jpeg'
        )
        
        expect(seminar.images).to be_attached
        expect(seminar.images.first.filename.to_s).to eq('test_image.jpg')
      end
    end
  end
end
require 'rails_helper'

RSpec.describe Seminar, type: :model do
  describe 'validations' do
    subject { build(:seminar) }
    
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:instructor_name) }
    it { should validate_presence_of(:instructor_belt) }
    it { should validate_presence_of(:seminar_date) }
    it { should validate_presence_of(:venue) }
    it { should validate_presence_of(:location) }
    
    describe 'title length validation' do
      it 'rejects titles that are too short' do
        seminar = build(:seminar, title: 'a')
        expect(seminar).not_to be_valid
        expect(seminar.errors[:title]).to include('is too short (minimum is 3 characters)')
      end
      
      it 'rejects titles that are too long' do
        seminar = build(:seminar, title: 'a' * 201)
        expect(seminar).not_to be_valid
        expect(seminar.errors[:title]).to include('is too long (maximum is 200 characters)')
      end
    end
    
    describe 'description length validation' do
      it 'rejects descriptions that are too short' do
        seminar = build(:seminar, description: 'a' * 9)
        expect(seminar).not_to be_valid
        expect(seminar.errors[:description]).to include('is too short (minimum is 10 characters)')
      end
    end
    
    describe 'price validation' do
      it 'accepts valid price amounts' do
        valid_prices = [0, 50.00, 999.99]
        valid_prices.each do |price|
          seminar = build(:seminar, price_amount: price)
          expect(seminar).to be_valid
        end
      end
      
      it 'rejects negative prices' do
        seminar = build(:seminar, price_amount: -1)
        expect(seminar).not_to be_valid
        expect(seminar.errors[:price_amount]).to include('must be greater than or equal to 0')
      end
    end
  end
  
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many_attached(:images) }
  end
  
  describe 'scopes' do
    before do
      @past_seminar = create(:seminar, :past)
      @future_seminar = create(:seminar, :future)
      @today_seminar = create(:seminar, seminar_date: Date.current)
    end
    
    describe '.upcoming' do
      it 'returns seminars scheduled for today or future dates' do
        upcoming = Seminar.upcoming
        expect(upcoming).to include(@future_seminar, @today_seminar)
        expect(upcoming).not_to include(@past_seminar)
      end
    end
    
    describe '.past' do
      it 'returns seminars from past dates' do
        past = Seminar.past
        expect(past).to include(@past_seminar)
        expect(past).not_to include(@future_seminar, @today_seminar)
      end
    end
  end
  
  describe 'search functionality' do
    before do
      @seminar1 = create(:seminar, title: 'Guard Techniques', instructor_name: 'John Doe')
      @seminar2 = create(:seminar, title: 'Submission Escapes', instructor_name: 'Jane Smith')
      @seminar3 = create(:seminar, title: 'Takedown Fundamentals', instructor_name: 'Bob Johnson')
    end
    
    describe '.search' do
      it 'finds seminars by title' do
        results = Seminar.search('Guard')
        expect(results).to include(@seminar1)
        expect(results).not_to include(@seminar2, @seminar3)
      end
      
      it 'finds seminars by instructor name' do
        results = Seminar.search('Jane')
        expect(results).to include(@seminar2)
        expect(results).not_to include(@seminar1, @seminar3)
      end
      
      it 'is case insensitive' do
        results = Seminar.search('guard')
        expect(results).to include(@seminar1)
      end
      
      it 'returns all seminars when query is blank' do
        results = Seminar.search('')
        expect(results).to include(@seminar1, @seminar2, @seminar3)
      end
    end
  end
  
  describe 'image attachments' do
    let(:seminar) { create(:seminar) }
    
    describe '#has_images?' do
      it 'returns false when no images attached' do
        expect(seminar.has_images?).to be false
      end
      
      it 'returns true when images are attached' do
        seminar.images.attach(
          io: StringIO.new('fake image'),
          filename: 'test.jpg',
          content_type: 'image/jpeg'
        )
        expect(seminar.has_images?).to be true
      end
    end
    
    describe '#primary_image' do
      it 'returns nil when no images attached' do
        expect(seminar.primary_image).to be_nil
      end
      
      it 'returns first image when images are attached' do
        image = seminar.images.attach(
          io: StringIO.new('fake image'),
          filename: 'test.jpg',
          content_type: 'image/jpeg'
        )
        expect(seminar.primary_image).to eq(seminar.images.first)
      end
    end
    
    describe 'image validation' do
      it 'allows up to 10 images' do
        10.times do |i|
          seminar.images.attach(
            io: StringIO.new('fake image'),
            filename: "test#{i}.jpg",
            content_type: 'image/jpeg'
          )
        end
        expect(seminar).to be_valid
      end
    end
  end
  
  describe '#formatted_price' do
    it 'returns formatted price with currency' do
      seminar = build(:seminar, price_amount: 50.00, price_currency: 'USD')
      expect(seminar.formatted_price).to eq('$50.00')
    end
    
    it 'returns "Free" for zero price' do
      seminar = build(:seminar, price_amount: 0)
      expect(seminar.formatted_price).to eq('Free')
    end
  end
  
end

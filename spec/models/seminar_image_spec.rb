require 'rails_helper'

RSpec.describe SeminarImage, type: :model do
  let(:seminar) { create(:seminar) }
  
  describe 'validations' do
    subject { build(:seminar_image, seminar: seminar, position: 1) }
    
    it { should validate_presence_of(:position) }
    it { should validate_numericality_of(:position).is_greater_than(0).is_less_than_or_equal_to(10) }
    it { should validate_inclusion_of(:primary).in_array([true, false]) }
    
    describe 'position uniqueness' do
      it 'prevents duplicate positions within same seminar' do
        create(:seminar_image, seminar: seminar, position: 1)
        duplicate = build(:seminar_image, seminar: seminar, position: 1)
        
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:position]).to include('Position must be unique per seminar')
      end
      
      it 'allows same position for different seminars' do
        create(:seminar_image, seminar: seminar, position: 1)
        other_seminar = create(:seminar)
        different_seminar = build(:seminar_image, seminar: other_seminar, position: 1)
        
        expect(different_seminar).to be_valid
      end
    end
    
    describe 'primary image validation' do
      it 'allows only one primary image per seminar' do
        create(:seminar_image, seminar: seminar, primary: true, position: 1)
        second_primary = build(:seminar_image, seminar: seminar, primary: true, position: 2)
        
        expect(second_primary).not_to be_valid
        expect(second_primary.errors[:primary]).to include('Only one primary image allowed per seminar')
      end
      
      it 'allows multiple non-primary images' do
        create(:seminar_image, seminar: seminar, primary: false, position: 1)
        second_non_primary = build(:seminar_image, seminar: seminar, primary: false, position: 2)
        
        expect(second_non_primary).to be_valid
      end
    end
    
    describe 'maximum images validation' do
      it 'prevents more than 10 images per seminar' do
        # Create 10 images
        10.times do |i|
          create(:seminar_image, seminar: seminar, position: i + 1)
        end
        
        eleventh_image = build(:seminar_image, seminar: seminar, position: 11)
        expect(eleventh_image).not_to be_valid
        expect(eleventh_image.errors[:base]).to include('Maximum 10 images allowed per seminar')
      end
    end
    
    describe 'image attachment validation' do
      it 'requires image to be attached' do
        image = build(:seminar_image, seminar: seminar, position: 1)
        image.image.purge if image.image.attached?
        
        expect(image).not_to be_valid
        expect(image.errors[:image]).to include('must be attached')
      end
    end
  end
  
  describe 'associations' do
    it { should belong_to(:seminar) }
    it { should have_one_attached(:image) }
  end
  
  describe 'scopes' do
    let!(:primary_image) { create(:seminar_image, seminar: seminar, primary: true, position: 1) }
    let!(:non_primary_1) { create(:seminar_image, seminar: seminar, primary: false, position: 2) }
    let!(:non_primary_2) { create(:seminar_image, seminar: seminar, primary: false, position: 3) }
    
    describe '.ordered' do
      it 'returns images ordered by position' do
        expect(seminar.seminar_images.ordered).to eq([primary_image, non_primary_1, non_primary_2])
      end
    end
    
    describe '.primary' do
      it 'returns only primary images' do
        expect(seminar.seminar_images.primary).to contain_exactly(primary_image)
      end
    end
    
    describe '.non_primary' do
      it 'returns only non-primary images' do
        expect(seminar.seminar_images.non_primary).to contain_exactly(non_primary_1, non_primary_2)
      end
    end
  end
  
  describe '#image_variants' do
    context 'when image is attached' do
      let(:seminar_image) { create(:seminar_image, seminar: seminar) }
      
      it 'returns hash of variants' do
        variants = seminar_image.image_variants
        expect(variants).to have_key(:thumbnail)
        expect(variants).to have_key(:medium)
        expect(variants).to have_key(:large)
      end
    end
    
    context 'when image is not attached' do
      it 'returns empty hash' do
        seminar_image = build(:seminar_image, seminar: seminar)
        seminar_image.image.purge if seminar_image.image.attached?
        
        expect(seminar_image.image_variants).to eq({})
      end
    end
  end
  
  describe '#make_primary!' do
    let!(:existing_primary) { create(:seminar_image, seminar: seminar, primary: true, position: 1) }
    let!(:new_primary) { create(:seminar_image, seminar: seminar, primary: false, position: 2) }
    
    it 'makes the image primary' do
      new_primary.make_primary!
      expect(new_primary.reload.primary).to be true
    end
    
    it 'removes primary status from other images' do
      new_primary.make_primary!
      expect(existing_primary.reload.primary).to be false
    end
    
    it 'uses a transaction' do
      expect(new_primary).to receive(:transaction).and_yield
      new_primary.make_primary!
    end
  end
  
  describe '#move_to_position!' do
    let!(:image1) { create(:seminar_image, seminar: seminar, position: 1) }
    let!(:image2) { create(:seminar_image, seminar: seminar, position: 2) }
    let!(:image3) { create(:seminar_image, seminar: seminar, position: 3) }
    let!(:image4) { create(:seminar_image, seminar: seminar, position: 4) }
    
    context 'moving down' do
      it 'shifts other images up' do
        image1.move_to_position!(3)
        
        expect(image1.reload.position).to eq(3)
        expect(image2.reload.position).to eq(1)
        expect(image3.reload.position).to eq(2)
        expect(image4.reload.position).to eq(4)
      end
    end
    
    context 'moving up' do
      it 'shifts other images down' do
        image4.move_to_position!(2)
        
        expect(image1.reload.position).to eq(1)
        expect(image2.reload.position).to eq(3)
        expect(image3.reload.position).to eq(4)
        expect(image4.reload.position).to eq(2)
      end
    end
    
    context 'no movement' do
      it 'does nothing if position is the same' do
        expect(image2).not_to receive(:update!)
        image2.move_to_position!(2)
      end
    end
  end
  
  describe 'callbacks' do
    describe 'ensure_primary_uniqueness' do
      it 'removes primary flag from other images when saving as primary' do
        existing_primary = create(:seminar_image, seminar: seminar, primary: true, position: 1)
        new_image = create(:seminar_image, seminar: seminar, primary: false, position: 2)
        
        new_image.update!(primary: true)
        
        expect(existing_primary.reload.primary).to be false
        expect(new_image.reload.primary).to be true
      end
    end
    
    describe 'reorder_positions after destroy' do
      it 'fills gaps in position numbering' do
        image1 = create(:seminar_image, seminar: seminar, position: 1)
        image2 = create(:seminar_image, seminar: seminar, position: 2)
        image3 = create(:seminar_image, seminar: seminar, position: 3)
        image4 = create(:seminar_image, seminar: seminar, position: 4)
        
        # Destroy image2 (position 2)
        image2.destroy
        
        # Remaining images should be reordered
        expect(image1.reload.position).to eq(1)
        expect(image3.reload.position).to eq(2)
        expect(image4.reload.position).to eq(3)
      end
    end
  end
  
  describe 'factory' do
    it 'creates valid seminar_image with attached image' do
      seminar_image = create(:seminar_image)
      expect(seminar_image).to be_valid
      expect(seminar_image.image).to be_attached
    end
  end
end
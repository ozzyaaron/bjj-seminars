require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }
    
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should have_secure_password }
  end
  
  describe 'associations' do
    it { should have_many(:seminars).dependent(:destroy) }
  end
  
  describe 'scopes' do
    before do
      @admin = create(:user, :admin)
      @regular_user = create(:user)
    end
    
    describe '.admins' do
      it 'returns only admin users' do
        expect(User.admins).to contain_exactly(@admin)
      end
    end
  end
  
  describe '#admin?' do
    it 'returns true for admin users' do
      admin = create(:user, :admin)
      expect(admin.admin?).to be true
    end
    
    it 'returns false for non-admin users' do
      user = create(:user)
      expect(user.admin?).to be false
    end
  end
end
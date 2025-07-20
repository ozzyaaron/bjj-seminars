require 'rails_helper'

RSpec.describe Player, type: :model do
  describe 'validations' do
    subject { build(:player) }
    
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:nationality) }
    it { should validate_length_of(:nationality).is_at_most(100) }
  end

  describe 'associations' do
    it { should belong_to(:team).optional }
    it { should have_many(:seminar_players).dependent(:destroy) }
    it { should have_many(:seminars).through(:seminar_players) }
  end

  describe 'factory' do
    it 'creates valid player' do
      player = create(:player)
      expect(player).to be_valid
      expect(player.name).to be_present
      expect(player.nationality).to be_present
    end
  end

  describe 'team relationship' do
    let(:team) { create(:team) }
    let(:player) { create(:player, team: team) }
    
    it 'can belong to a team' do
      expect(player.team).to eq(team)
    end
    
    it 'can exist without a team' do
      teamless_player = create(:player, team: nil)
      expect(teamless_player).to be_valid
      expect(teamless_player.team).to be_nil
    end
  end

  describe 'seminar associations' do
    let(:player) { create(:player) }
    let(:seminar) { create(:seminar) }
    
    it 'can be associated with seminars' do
      player.seminars << seminar
      expect(player.seminars).to include(seminar)
      expect(seminar.players).to include(player)
    end
  end

  describe 'indexing' do
    it 'is indexed by name' do
      expect(Player.connection.index_exists?(:players, :name)).to be true
    end
    
    it 'is indexed by nationality' do
      expect(Player.connection.index_exists?(:players, :nationality)).to be true
    end
  end
end
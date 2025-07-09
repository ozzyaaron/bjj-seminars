require 'rails_helper'

RSpec.describe Team, type: :model do
  describe 'validations' do
    subject { build(:team) }
    
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_length_of(:country).is_at_most(2) }
  end

  describe 'associations' do
    it { should have_many(:players).dependent(:nullify) }
  end

  describe 'factory' do
    it 'creates valid team' do
      team = create(:team)
      expect(team).to be_valid
      expect(team.name).to be_present
    end
  end

  describe 'defaults' do
    it 'defaults country to US' do
      team = Team.new
      expect(team.country).to eq('US')
    end
  end

  describe 'name uniqueness' do
    it 'enforces unique team names' do
      create(:team, name: 'Gracie Barra')
      duplicate = build(:team, name: 'Gracie Barra')
      
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include('has already been taken')
    end
  end

  describe 'player relationships' do
    let(:team) { create(:team) }
    let!(:player1) { create(:player, team: team) }
    let!(:player2) { create(:player, team: team) }
    
    it 'has many players' do
      expect(team.players).to include(player1, player2)
    end
    
    it 'nullifies player team_id when team is destroyed' do
      team_id = team.id
      team.destroy
      
      player1.reload
      player2.reload
      
      expect(player1.team_id).to be_nil
      expect(player2.team_id).to be_nil
    end
  end

  describe 'indexing' do
    it 'is indexed by name' do
      expect(Team.connection.index_exists?(:teams, :name)).to be true
    end
    
    it 'is indexed by country' do
      expect(Team.connection.index_exists?(:teams, :country)).to be true
    end
  end

  describe 'country validation' do
    it 'accepts valid 2-letter country codes' do
      valid_countries = ['US', 'BR', 'JP', 'UK']
      valid_countries.each do |country|
        team = build(:team, country: country)
        expect(team).to be_valid
      end
    end
  end
end
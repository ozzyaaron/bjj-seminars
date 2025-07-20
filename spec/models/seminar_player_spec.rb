require 'rails_helper'

RSpec.describe SeminarPlayer, type: :model do
  let(:seminar) { create(:seminar) }
  let(:player) { create(:player) }
  
  describe 'validations' do
    subject { build(:seminar_player, seminar: seminar, player: player) }
    
    it { should validate_presence_of(:player_id) }
    it { should validate_presence_of(:seminar_id) }
    
    describe 'uniqueness validation' do
      it 'prevents duplicate associations' do
        create(:seminar_player, seminar: seminar, player: player)
        duplicate = build(:seminar_player, seminar: seminar, player: player)
        
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:seminar_id]).to include('Player is already associated with this seminar')
      end
      
      it 'allows same player for different seminars' do
        create(:seminar_player, seminar: seminar, player: player)
        other_seminar = create(:seminar)
        different_seminar = build(:seminar_player, seminar: other_seminar, player: player)
        
        expect(different_seminar).to be_valid
      end
      
      it 'allows same seminar for different players' do
        create(:seminar_player, seminar: seminar, player: player)
        other_player = create(:player)
        different_player = build(:seminar_player, seminar: seminar, player: other_player)
        
        expect(different_player).to be_valid
      end
    end
  end
  
  describe 'associations' do
    it { should belong_to(:seminar) }
    it { should belong_to(:player) }
  end
  
  describe 'factory' do
    it 'creates valid seminar_player' do
      seminar_player = create(:seminar_player)
      expect(seminar_player).to be_valid
      expect(seminar_player.seminar).to be_present
      expect(seminar_player.player).to be_present
    end
  end
  
  describe 'database constraints' do
    it 'requires seminar to exist' do
      expect {
        create(:seminar_player, seminar_id: 999999)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
    
    it 'requires player to exist' do
      expect {
        create(:seminar_player, player_id: 999999)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
  
  describe 'join table functionality' do
    it 'creates a many-to-many relationship between seminars and players' do
      player1 = create(:player)
      player2 = create(:player)
      seminar1 = create(:seminar)
      seminar2 = create(:seminar)
      
      # Associate players with seminars
      create(:seminar_player, seminar: seminar1, player: player1)
      create(:seminar_player, seminar: seminar1, player: player2)
      create(:seminar_player, seminar: seminar2, player: player1)
      
      # Verify associations work both ways
      expect(seminar1.players).to contain_exactly(player1, player2)
      expect(seminar2.players).to contain_exactly(player1)
      expect(player1.seminars).to contain_exactly(seminar1, seminar2)
      expect(player2.seminars).to contain_exactly(seminar1)
    end
  end
  
  describe 'dependent destroy behavior' do
    it 'is destroyed when seminar is destroyed' do
      seminar_player = create(:seminar_player, seminar: seminar, player: player)
      
      expect {
        seminar.destroy
      }.to change(SeminarPlayer, :count).by(-1)
      
      expect(SeminarPlayer.exists?(seminar_player.id)).to be false
    end
    
    it 'is destroyed when player is destroyed' do
      seminar_player = create(:seminar_player, seminar: seminar, player: player)
      
      expect {
        player.destroy
      }.to change(SeminarPlayer, :count).by(-1)
      
      expect(SeminarPlayer.exists?(seminar_player.id)).to be false
    end
  end
  
  describe 'indexing' do
    it 'has a composite index on seminar_id and player_id for uniqueness' do
      expect(SeminarPlayer.connection.index_exists?(:seminar_players, [:seminar_id, :player_id])).to be true
    end
  end
end
require 'rails_helper'

RSpec.describe NotificationRequest, type: :model do
  let(:user) { create(:user) }
  
  describe 'validations' do
    subject { build(:notification_request, user: user) }
    
    it { should validate_presence_of(:user_id) }
    
    describe 'state format validation' do
      it 'accepts valid 2-letter state codes' do
        valid_states = ['CA', 'NY', 'TX', 'FL']
        valid_states.each do |state|
          notification = build(:notification_request, user: user, state: state)
          expect(notification).to be_valid
        end
      end
      
      it 'rejects invalid state formats' do
        invalid_states = ['California', 'CAL', 'C', '123', 'ca']
        invalid_states.each do |state|
          notification = build(:notification_request, user: user, state: state)
          expect(notification).not_to be_valid
          expect(notification.errors[:state]).to include('must be a valid 2-letter state code')
        end
      end
      
      it 'allows blank state' do
        notification = build(:notification_request, user: user, state: nil, city: 'San Francisco')
        expect(notification).to be_valid
      end
    end
    
    describe 'at least one filter validation' do
      it 'requires at least one filter to be present' do
        notification = build(:notification_request, 
          user: user,
          player_ids: [],
          city: nil,
          state: nil
        )
        expect(notification).not_to be_valid
        expect(notification.errors[:base]).to include('At least one filter must be specified (players or location)')
      end
      
      it 'is valid with player filter only' do
        player = create(:player)
        notification = build(:notification_request,
          user: user,
          player_ids: [player.id],
          city: nil,
          state: nil
        )
        expect(notification).to be_valid
      end
      
      it 'is valid with city filter only' do
        notification = build(:notification_request,
          user: user,
          player_ids: [],
          city: 'San Francisco',
          state: nil
        )
        expect(notification).to be_valid
      end
      
      it 'is valid with state filter only' do
        notification = build(:notification_request,
          user: user,
          player_ids: [],
          city: nil,
          state: 'CA'
        )
        expect(notification).to be_valid
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'scopes' do
    let!(:active_request) { create(:notification_request, user: user, active: true, city: 'San Francisco') }
    let!(:inactive_request) { create(:notification_request, user: user, active: false, state: 'CA') }
    let!(:player_request) { create(:notification_request, user: user, player_ids: [1, 2], active: true) }
    
    describe '.active' do
      it 'returns only active requests' do
        expect(NotificationRequest.active).to contain_exactly(active_request, player_request)
      end
    end
    
    describe '.by_city' do
      it 'returns requests for specific city' do
        expect(NotificationRequest.by_city('San Francisco')).to contain_exactly(active_request)
      end
    end
    
    describe '.by_state' do
      it 'returns requests for specific state' do
        expect(NotificationRequest.by_state('CA')).to contain_exactly(inactive_request)
      end
    end
    
    describe '.with_player_filters' do
      it 'returns requests with player filters' do
        expect(NotificationRequest.with_player_filters).to contain_exactly(player_request)
      end
    end
    
    describe '.with_location_filters' do
      it 'returns requests with location filters' do
        expect(NotificationRequest.with_location_filters).to contain_exactly(active_request, inactive_request)
      end
    end
  end

  describe '#player_ids' do
    it 'returns empty array when nil' do
      notification = build(:notification_request, user: user)
      notification[:player_ids] = nil
      expect(notification.player_ids).to eq([])
    end
    
    it 'parses JSON array correctly' do
      notification = build(:notification_request, user: user)
      notification[:player_ids] = '[1,2,3]'
      expect(notification.player_ids).to eq([1, 2, 3])
    end
    
    it 'handles invalid JSON gracefully' do
      notification = build(:notification_request, user: user)
      notification[:player_ids] = 'invalid json'
      expect(notification.player_ids).to eq([])
    end
  end

  describe '#player_ids=' do
    it 'converts array to JSON' do
      notification = build(:notification_request, user: user, city: 'SF')
      notification.player_ids = [1, 2, 3]
      expect(notification[:player_ids]).to eq('[1,2,3]')
    end
    
    it 'removes duplicates and nils' do
      notification = build(:notification_request, user: user, city: 'SF')
      notification.player_ids = [1, 2, nil, 2, 3]
      expect(notification[:player_ids]).to eq('[1,2,3]')
    end
    
    it 'accepts string input' do
      notification = build(:notification_request, user: user, city: 'SF')
      notification.player_ids = '[4,5,6]'
      expect(notification[:player_ids]).to eq('[4,5,6]')
    end
    
    it 'handles nil input' do
      notification = build(:notification_request, user: user, city: 'SF')
      notification.player_ids = nil
      expect(notification[:player_ids]).to eq('[]')
    end
  end

  describe '#following_players?' do
    it 'returns true when player_ids present' do
      notification = build(:notification_request, user: user, player_ids: [1, 2])
      expect(notification.following_players?).to be true
    end
    
    it 'returns false when player_ids empty' do
      notification = build(:notification_request, user: user, player_ids: [], city: 'SF')
      expect(notification.following_players?).to be false
    end
  end

  describe '#location_filters?' do
    it 'returns true when city present' do
      notification = build(:notification_request, user: user, city: 'San Francisco')
      expect(notification.location_filters?).to be true
    end
    
    it 'returns true when state present' do
      notification = build(:notification_request, user: user, state: 'CA')
      expect(notification.location_filters?).to be true
    end
    
    it 'returns false when neither city nor state present' do
      notification = build(:notification_request, user: user, player_ids: [1])
      expect(notification.location_filters?).to be false
    end
  end

  describe '#matches_seminar?' do
    let(:player1) { create(:player) }
    let(:player2) { create(:player) }
    let(:seminar) { create(:seminar, city: 'San Francisco', state: 'CA') }
    
    before do
      seminar.players << player1
    end
    
    context 'when notification is inactive' do
      it 'returns false' do
        notification = create(:notification_request, 
          user: user, 
          active: false, 
          city: 'San Francisco'
        )
        expect(notification.matches_seminar?(seminar)).to be false
      end
    end
    
    context 'with player filters' do
      it 'matches when seminar has the followed player' do
        notification = create(:notification_request,
          user: user,
          active: true,
          player_ids: [player1.id]
        )
        expect(notification.matches_seminar?(seminar)).to be true
      end
      
      it 'does not match when seminar lacks the followed player' do
        notification = create(:notification_request,
          user: user,
          active: true,
          player_ids: [player2.id]
        )
        expect(notification.matches_seminar?(seminar)).to be false
      end
    end
    
    context 'with location filters' do
      it 'matches by city (case insensitive)' do
        notification = create(:notification_request,
          user: user,
          active: true,
          city: 'san francisco'
        )
        expect(notification.matches_seminar?(seminar)).to be true
      end
      
      it 'matches by state (case insensitive)' do
        notification = create(:notification_request,
          user: user,
          active: true,
          state: 'ca'
        )
        expect(notification.matches_seminar?(seminar)).to be true
      end
      
      it 'does not match different city' do
        notification = create(:notification_request,
          user: user,
          active: true,
          city: 'Los Angeles'
        )
        expect(notification.matches_seminar?(seminar)).to be false
      end
      
      it 'does not match different state' do
        notification = create(:notification_request,
          user: user,
          active: true,
          state: 'NY'
        )
        expect(notification.matches_seminar?(seminar)).to be false
      end
    end
    
    context 'with combined filters' do
      it 'requires all filters to match' do
        notification = create(:notification_request,
          user: user,
          active: true,
          player_ids: [player1.id],
          city: 'San Francisco'
        )
        expect(notification.matches_seminar?(seminar)).to be true
      end
      
      it 'returns false if any filter does not match' do
        notification = create(:notification_request,
          user: user,
          active: true,
          player_ids: [player2.id],  # Wrong player
          city: 'San Francisco'
        )
        expect(notification.matches_seminar?(seminar)).to be false
      end
    end
  end

  describe '#description' do
    let(:player1) { create(:player, name: 'Gordon Ryan') }
    let(:player2) { create(:player, name: 'Craig Jones') }
    
    it 'describes player filters' do
      notification = create(:notification_request,
        user: user,
        player_ids: [player1.id, player2.id]
      )
      expect(notification.description).to eq('Players: Gordon Ryan, Craig Jones')
    end
    
    it 'describes city filter' do
      notification = create(:notification_request,
        user: user,
        city: 'San Francisco'
      )
      expect(notification.description).to eq('City: San Francisco')
    end
    
    it 'describes state filter' do
      notification = create(:notification_request,
        user: user,
        state: 'CA'
      )
      expect(notification.description).to eq('State: CA')
    end
    
    it 'combines multiple filters' do
      notification = create(:notification_request,
        user: user,
        player_ids: [player1.id],
        city: 'San Francisco'
      )
      expect(notification.description).to eq('Players: Gordon Ryan | City: San Francisco')
    end
    
    it 'prefers city over state in description' do
      notification = create(:notification_request,
        user: user,
        city: 'San Francisco',
        state: 'CA'
      )
      expect(notification.description).to eq('City: San Francisco')
    end
  end
end
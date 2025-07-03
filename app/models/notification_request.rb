class NotificationRequest < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :state, format: { with: /\A[A-Z]{2}\z/, message: "must be a valid 2-letter state code" }, allow_blank: true
  validate :at_least_one_filter_present

  scope :active, -> { where(active: true) }
  scope :by_city, ->(city) { where(city: city) }
  scope :by_state, ->(state) { where(state: state) }
  scope :with_player_filters, -> { where.not(player_ids: [nil, "[]", ""]) }
  scope :with_location_filters, -> { where.not(city: nil).or(where.not(state: nil)) }

  # Handle player_ids as JSON array
  def player_ids
    return [] if super.blank?
    JSON.parse(super)
  rescue JSON::ParserError
    []
  end

  def player_ids=(ids)
    case ids
    when Array
      super(ids.compact.uniq.to_json)
    when String
      super(ids)
    else
      super([])
    end
  end

  def following_players?
    player_ids.any?
  end

  def location_filters?
    city.present? || state.present?
  end

  def matches_seminar?(seminar)
    return false unless active?
    
    # Check player filters
    if following_players?
      player_match = seminar.players.exists?(id: player_ids)
      return false unless player_match
    end
    
    # Check location filters
    if location_filters?
      location_match = false
      location_match = true if city.present? && seminar.city.downcase == city.downcase
      location_match = true if state.present? && seminar.state.upcase == state.upcase
      return false unless location_match
    end
    
    true
  end

  def description
    filters = []
    
    if following_players?
      player_names = Player.where(id: player_ids).pluck(:name)
      filters << "Players: #{player_names.join(', ')}"
    end
    
    if city.present?
      filters << "City: #{city}"
    elsif state.present?
      filters << "State: #{state}"
    end
    
    filters.any? ? filters.join(" | ") : "All seminars"
  end

  private

  def at_least_one_filter_present
    return if following_players? || location_filters?
    
    errors.add(:base, "At least one filter must be specified (players or location)")
  end
end

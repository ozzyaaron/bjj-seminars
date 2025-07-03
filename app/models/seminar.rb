class Seminar < ApplicationRecord
  belongs_to :user
  has_many :seminar_players, dependent: :destroy
  has_many :players, through: :seminar_players
  has_many :seminar_images, dependent: :destroy
  has_many :notification_deliveries, dependent: :destroy

  geocoded_by :full_address
  after_validation :geocode, if: :address_changed?

  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :description, presence: true, length: { minimum: 10 }
  validates :starts_at, presence: true
  validates :address, :city, :state, :country, presence: true
  validates :state, format: { with: /\A[A-Z]{2}\z/, message: "must be a valid 2-letter state code" }
  validates :country, format: { with: /\A[A-Z]{2}\z/, message: "must be a valid 2-letter country code" }
  validate :starts_at_is_in_future
  validate :ends_at_after_starts_at
  validate :user_can_create_seminar

  scope :upcoming, -> { where('starts_at > ?', Time.current) }
  scope :past, -> { where('starts_at < ?', Time.current) }
  scope :in_city, ->(city) { where(city: city) }
  scope :in_state, ->(state) { where(state: state) }
  scope :in_country, ->(country) { where(country: country) }
  scope :with_player, ->(player_id) { joins(:players).where(players: { id: player_id }) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_date, -> { order(starts_at: :asc) }

  def full_address
    [address, city, state, zip_code, country].compact.join(', ')
  end

  def formatted_date
    starts_at.strftime('%B %d, %Y at %I:%M %p')
  end

  def duration_in_hours
    return nil unless ends_at
    ((ends_at - starts_at) / 1.hour).round(1)
  end

  def can_be_edited_by?(user)
    self.user == user || user.admin?
  end

  def player_names
    players.pluck(:name).join(', ')
  end

  def primary_image
    seminar_images.find_by(primary: true)&.image
  end

  private

  def starts_at_is_in_future
    return unless starts_at
    errors.add(:starts_at, "must be in the future") if starts_at <= Time.current
  end

  def ends_at_after_starts_at
    return unless ends_at && starts_at
    errors.add(:ends_at, "must be after start time") if ends_at <= starts_at
  end

  def user_can_create_seminar
    return unless user && new_record?
    errors.add(:base, "Daily seminar creation limit reached") unless user.can_create_seminar?
  end

  def address_changed?
    address_changed? || city_changed? || state_changed? || zip_code_changed? || country_changed?
  end
end

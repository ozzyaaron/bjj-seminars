class User < ApplicationRecord
  has_secure_password

  has_many :seminars, dependent: :destroy
  has_many :notification_requests, dependent: :destroy
  has_many :notification_deliveries, dependent: :destroy

  validates :email, presence: true, 
                   uniqueness: { case_sensitive: false }, 
                   format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8 }, on: :create
  validate :daily_seminar_limit

  scope :admins, -> { where(admin: true) }

  def self.authenticate_by(email:, password:)
    user = find_by(email: email.downcase)
    user&.authenticate(password)
  end

  def update_sign_in_info!(ip_address)
    update_columns(
      last_sign_in_at: Time.current,
      last_sign_in_ip: ip_address
    )
  end

  def can_create_seminar?
    reset_daily_counters if new_day?
    daily_seminar_count < 25
  end

  def admin?
    admin
  end

  def name
    email
  end

  def increment_seminar_count!
    increment!(:daily_seminar_count)
    update_column(:last_seminar_created_at, Time.current)
  end
  
  alias_method :increment_daily_seminar_count!, :increment_seminar_count!

  private

  def daily_seminar_limit
    return unless daily_seminar_count >= 25
    errors.add(:base, "Daily seminar creation limit reached")
  end

  def new_day?
    needs_counter_reset?
  end
  
  def needs_counter_reset?
    last_seminar_created_at.nil? || last_seminar_created_at.to_date < Date.current
  end

  def reset_daily_counters
    if persisted?
      update_columns(
        daily_seminar_count: 0,
        last_seminar_created_at: Time.current
      )
    else
      self.daily_seminar_count = 0
      self.last_seminar_created_at = Time.current
    end
  end
end

class NotificationDelivery < ApplicationRecord
  belongs_to :user
  belongs_to :seminar

  validates :user_id, presence: true, uniqueness: { scope: :seminar_id, message: "Notification already delivered for this seminar" }
  validates :seminar_id, presence: true
  validates :delivered_at, presence: true

  scope :recent, -> { order(delivered_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }
  scope :for_seminar, ->(seminar) { where(seminar: seminar) }
  scope :delivered_today, -> { where(delivered_at: Date.current.beginning_of_day..Date.current.end_of_day) }
  scope :delivered_since, ->(date) { where("delivered_at >= ?", date) }

  def self.record_delivery!(user, seminar)
    create!(
      user: user,
      seminar: seminar,
      delivered_at: Time.current
    )
  end

  def self.bulk_record_deliveries!(deliveries)
    delivery_records = deliveries.map do |user, seminar|
      {
        user_id: user.id,
        seminar_id: seminar.id,
        delivered_at: Time.current,
        created_at: Time.current,
        updated_at: Time.current
      }
    end
    
    insert_all(delivery_records, unique_by: [:user_id, :seminar_id])
  end

  def self.already_delivered?(user, seminar)
    exists?(user: user, seminar: seminar)
  end

  def self.cleanup_old_deliveries!(older_than: 90.days)
    where("delivered_at < ?", older_than.ago).delete_all
  end

  def time_since_delivery
    return unless delivered_at
    
    time_diff = Time.current - delivered_at
    
    case time_diff
    when 0..1.hour
      "#{(time_diff / 1.minute).to_i} minutes ago"
    when 1.hour..1.day
      "#{(time_diff / 1.hour).to_i} hours ago"
    else
      "#{(time_diff / 1.day).to_i} days ago"
    end
  end
end

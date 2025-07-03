class SeminarImage < ApplicationRecord
  belongs_to :seminar
  has_one_attached :image

  validates :position, presence: true, 
                      uniqueness: { scope: :seminar_id, message: "Position must be unique per seminar" },
                      numericality: { greater_than: 0, less_than_or_equal_to: 10 }
  validates :primary, inclusion: { in: [true, false] }
  validate :only_one_primary_per_seminar
  validate :max_images_per_seminar
  validate :image_attachment_present

  scope :ordered, -> { order(:position) }
  scope :primary, -> { where(primary: true) }
  scope :non_primary, -> { where(primary: false) }

  before_save :ensure_primary_uniqueness
  after_destroy :reorder_positions

  def image_variants
    return {} unless image.attached?
    
    {
      thumbnail: image.variant(resize_to_limit: [300, 200]),
      medium: image.variant(resize_to_limit: [600, 400]),
      large: image.variant(resize_to_limit: [1200, 800])
    }
  end

  def make_primary!
    transaction do
      seminar.seminar_images.where(primary: true).update_all(primary: false)
      update!(primary: true)
    end
  end

  def move_to_position!(new_position)
    return if position == new_position
    
    transaction do
      if new_position > position
        # Moving down - shift others up
        seminar.seminar_images
               .where(position: (position + 1)..new_position)
               .update_all("position = position - 1")
      else
        # Moving up - shift others down
        seminar.seminar_images
               .where(position: new_position..(position - 1))
               .update_all("position = position + 1")
      end
      
      update!(position: new_position)
    end
  end

  private

  def only_one_primary_per_seminar
    return unless primary?
    
    existing_primary = seminar&.seminar_images&.where(primary: true)&.where&.not(id: id)
    return unless existing_primary&.exists?
    
    errors.add(:primary, "Only one primary image allowed per seminar")
  end

  def max_images_per_seminar
    return unless seminar
    
    current_count = seminar.seminar_images.count
    current_count += 1 if new_record?
    
    return unless current_count > 10
    
    errors.add(:base, "Maximum 10 images allowed per seminar")
  end

  def image_attachment_present
    return if image.attached?
    
    errors.add(:image, "must be attached")
  end

  def ensure_primary_uniqueness
    return unless primary_changed? && primary?
    
    # Clear other primary flags for this seminar
    self.class.where(seminar: seminar, primary: true).where.not(id: id).update_all(primary: false)
  end

  def reorder_positions
    return unless seminar
    
    # Reorder remaining images to fill gaps
    seminar.seminar_images.ordered.each_with_index do |img, index|
      img.update_column(:position, index + 1) if img.position != index + 1
    end
  end
end

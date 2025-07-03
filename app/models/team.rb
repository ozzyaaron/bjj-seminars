class Team < ApplicationRecord
  has_many :players, dependent: :nullify
  has_one_attached :image

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :country, presence: true, format: { with: /\A[A-Z]{2}\z/, message: "must be a valid 2-letter country code" }

  scope :by_country, ->(country) { where(country: country) }

  def display_name
    country == 'US' ? name : "#{name} (#{country})"
  end
end

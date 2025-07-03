class Player < ApplicationRecord
  belongs_to :team, optional: true
  has_many :seminar_players, dependent: :destroy
  has_many :seminars, through: :seminar_players
  has_one_attached :image

  validates :name, presence: true
  validates :nationality, presence: true, length: { maximum: 100 }

  scope :by_nationality, ->(nationality) { where(nationality: nationality) }
  scope :with_team, -> { joins(:team) }
  scope :without_team, -> { where(team: nil) }

  def display_name
    team_name = team&.name
    team_name ? "#{name} (#{team_name})" : name
  end

  def full_display_name
    parts = [name]
    parts << nationality if nationality.present?
    parts << team.name if team.present?
    parts.join(' - ')
  end
end

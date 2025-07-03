class SeminarPlayer < ApplicationRecord
  belongs_to :seminar
  belongs_to :player

  validates :seminar_id, uniqueness: { scope: :player_id, message: "Player is already associated with this seminar" }
  validates :player_id, presence: true
  validates :seminar_id, presence: true
end

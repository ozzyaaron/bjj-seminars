class CreateSeminarPlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :seminar_players do |t|
      t.references :seminar, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :seminar_players, [:seminar_id, :player_id], unique: true
    add_index :seminar_players, [:player_id, :seminar_id]
  end
end

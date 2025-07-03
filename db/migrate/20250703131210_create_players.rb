class CreatePlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :players do |t|
      t.string :name, null: false
      t.string :nationality, null: false, limit: 100
      t.references :team, null: true, foreign_key: true
      t.text :bio

      t.timestamps
    end
    
    add_index :players, :name
    add_index :players, :nationality
  end
end

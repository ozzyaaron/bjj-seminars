class CreateTeams < ActiveRecord::Migration[8.0]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.text :description
      t.string :country, limit: 2, default: 'US'

      t.timestamps
    end
    
    add_index :teams, :name, unique: true
    add_index :teams, :country
  end
end

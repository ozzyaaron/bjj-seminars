class CreateSeminars < ActiveRecord::Migration[8.0]
  def change
    create_table :seminars do |t|
      t.string :title, null: false, limit: 200
      t.text :description, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at
      t.references :user, null: false, foreign_key: true
      t.string :address, null: false
      t.string :city, null: false, limit: 100
      t.string :state, null: false, limit: 2
      t.string :zip_code, limit: 10
      t.string :country, limit: 2, default: 'US', null: false
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6

      t.timestamps
    end
    
    add_index :seminars, [:city, :state]
    add_index :seminars, [:starts_at]
    add_index :seminars, [:latitude, :longitude]
    add_index :seminars, [:country, :state, :city]
    
    add_check_constraint :seminars, "starts_at > CURRENT_TIMESTAMP", name: "seminars_future_date"
    add_check_constraint :seminars, "ends_at IS NULL OR ends_at > starts_at", name: "seminars_valid_duration"
  end
end

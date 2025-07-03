class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.boolean :admin, null: false, default: false
      t.integer :daily_seminar_count, null: false, default: 0
      t.datetime :last_seminar_created_at

      t.timestamps
    end
    
    add_index :users, :email, unique: true
    add_check_constraint :users, "daily_seminar_count >= 0 AND daily_seminar_count <= 25", name: "daily_seminar_count_range"
  end
end

class CreateNotificationRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.text :player_ids # JSON array of player IDs to follow
      t.string :city, limit: 100
      t.string :state, limit: 2
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    
    add_index :notification_requests, [:user_id, :active]
    add_index :notification_requests, [:city, :state]
  end
end

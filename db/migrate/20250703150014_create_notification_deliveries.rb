class CreateNotificationDeliveries < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_deliveries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :seminar, null: false, foreign_key: true
      t.datetime :delivered_at, null: false

      t.timestamps
    end
    
    add_index :notification_deliveries, [:user_id, :seminar_id], unique: true
    add_index :notification_deliveries, [:delivered_at]
  end
end

class CreateSeminarImages < ActiveRecord::Migration[8.0]
  def change
    create_table :seminar_images do |t|
      t.references :seminar, null: false, foreign_key: true
      t.integer :position, null: false
      t.boolean :primary, null: false, default: false

      t.timestamps
    end
    
    add_index :seminar_images, [:seminar_id, :position], unique: true
    add_index :seminar_images, [:seminar_id], unique: true, where: "\"primary\" = true", name: "unique_primary_per_seminar"
    
    # Check constraint for max 10 images per seminar - using a trigger approach
    execute <<-SQL
      CREATE TRIGGER check_max_images_per_seminar
      BEFORE INSERT ON seminar_images
      FOR EACH ROW
      WHEN (
        (SELECT COUNT(*) FROM seminar_images WHERE seminar_id = NEW.seminar_id) >= 10
      )
      BEGIN
        SELECT RAISE(ABORT, 'Maximum 10 images allowed per seminar');
      END;
    SQL
  end
  
  def down
    execute "DROP TRIGGER IF EXISTS check_max_images_per_seminar"
    drop_table :seminar_images
  end
end

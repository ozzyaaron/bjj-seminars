class AddSeminarTypeToSeminars < ActiveRecord::Migration[8.0]
  def change
    add_column :seminars, :seminar_type, :string
    add_index :seminars, :seminar_type
  end
end

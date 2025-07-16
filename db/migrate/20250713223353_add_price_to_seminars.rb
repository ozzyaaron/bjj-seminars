class AddPriceToSeminars < ActiveRecord::Migration[8.0]
  def change
    add_column :seminars, :price, :decimal, precision: 8, scale: 2
    add_index :seminars, :price
  end
end

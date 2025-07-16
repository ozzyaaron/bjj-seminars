class AddBeltRankToPlayers < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :belt_rank, :string
  end
end

class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.references :game
      t.string :name
      t.timestamps
    end
    add_index :players, :game_id
  end
end

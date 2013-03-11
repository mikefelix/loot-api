class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.references :game
      t.references :user
      t.timestamps
    end
    add_index :players, :game_id
  end
end

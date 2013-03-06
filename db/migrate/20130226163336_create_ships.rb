class CreateShips < ActiveRecord::Migration
  def change
    create_table :ships do |t|
      t.integer :color
      t.integer :strength
      t.integer :state
      t.references :player
      t.references :game
      t.references :target, polymorphic: true
      t.timestamps
    end
    add_index :ships, :target_id
    add_index :ships, :player_id
    add_index :ships, :game_id
  end
end

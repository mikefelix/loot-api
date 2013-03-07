class CreateTurns < ActiveRecord::Migration
  def change
    create_table :turns do |t|
      t.references :player
      t.references :ship
      t.references :target, polymorphic: true
      t.integer :num
      t.timestamps
    end
    add_index :turns, :player_id
    add_index :turns, :ship_id
  end
end

class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.timestamps
    end
    add_column :players, :user_id, :string, :null => false
  end
end

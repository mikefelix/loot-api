# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130305220710) do

  create_table "burgers", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "games", :force => true do |t|
    t.string   "name"
    t.integer  "turn"
    t.integer  "current_player_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "players", :force => true do |t|
    t.integer  "game_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "players", ["game_id"], :name => "index_players_on_game_id"

  create_table "ships", :force => true do |t|
    t.integer  "color"
    t.integer  "strength"
    t.integer  "state"
    t.integer  "player_id"
    t.integer  "game_id"
    t.integer  "target_id"
    t.integer  "won_in"
    t.string   "target_type"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "ships", ["game_id"], :name => "index_ships_on_game_id"
  add_index "ships", ["player_id"], :name => "index_ships_on_player_id"
  add_index "ships", ["target_id"], :name => "index_ships_on_target_id"

  create_table "turns", :force => true do |t|
    t.integer  "player_id"
    t.integer  "ship_id"
    t.integer  "target_id"
    t.string   "target_type"
    t.integer  "num"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "turns", ["player_id"], :name => "index_turns_on_player_id"
  add_index "turns", ["ship_id"], :name => "index_turns_on_ship_id"

end

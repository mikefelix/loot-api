class Player < ActiveRecord::Base
  belongs_to :game
  attr_accessible :name, :game
  has_many :merchants, as: :target, class_name: 'Ship'
  has_many :ships

  def hand
    ships.select { |s| s.state == IN_HAND }
  end

  def merchant_targets
    ships.select { |s| s.is_pirate? and s.state == PLAYED }.map {|s| s.target}.uniq
  end

  def draw
    ship = game.draw_ship
    ships << ship
    ship.state = IN_HAND
  end

end

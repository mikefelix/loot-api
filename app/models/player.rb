class Player < ActiveRecord::Base
  belongs_to :game
  attr_accessible :name, :game
  has_many :merchants, as: :target, class_name: 'Ship'
  has_many :ships
  has_many :turns

  def hand
    ships.select { |s| s.state == IN_HAND }
  end

  def merchant_targets(refresh = false)
    ships(refresh).select { |s| s.is_pirate? and s.state == PLAYED }.map {|s| s.target}.uniq
  end

  def take_turn(ship, target = nil)
    transaction do
      raise "Not your turn." if game.current_player != self

      if !ship # no ship used so draw a new ship
        drawn = game.deck.shift
        drawn.state = IN_HAND
        self.ships << drawn
        turn = Turn.create(num: game.turns_length + 1, player: self, target: drawn)
      else
        raise "You don't have that ship." if !hand.include? ship
        ship.sail target
        turn = Turn.create(num: game.turns_length + 1, player: self, ship: ship, target: target)
      end

      turns << turn
      game.next_player
      game.save
      turn
    end
  end

  def win_ship(ship)
    ship.state = SCORED
    ship.player = self
    ship.target = nil
    ship.attackers.each do |a|
      a.player = nil
      a.target = nil
      a.state = DISCARDED
      a.save
    end
    ship.save
  end

  def score
    ships.select { |s| s.state == SCORED }
  end
end

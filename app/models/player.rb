class Player < ActiveRecord::Base
  belongs_to :game
  belongs_to :user
  attr_accessible :name, :game, :user
  has_many :merchants, as: :target, class_name: 'Ship'
  has_many :ships
  has_many :turns

  def hand
    ships.select { |s| s.state == IN_HAND }
  end

  def name
    user.name
  end

  def merchant_targets(refresh = false)
    ships(refresh).select { |s| s.is_pirate? and s.state == PLAYED }.map {|s| s.target}.uniq
  end

  def gather_loot(turn_num)
    merchant_targets.each do |merchant|
      if merchant.latest_attacker == self and merchant.winning_attacker == self
        merchant.state = SCORED
        merchant.player = self
        merchant.target = nil
        merchant.won_in = turn_num
        merchant.attackers.each do |attacker|
          attacker.player = nil
          attacker.target = nil
          attacker.state = DISCARDED
          attacker.save
        end
        merchant.save
      end
    end
  end

  def take_turn(ship, target = nil)
    transaction do
      raise "Not your turn." if game.current_player != self

      turn_num = game.turns_length + 1
      gather_loot turn_num

      if !ship # no ship used so draw a new ship
        drawn = game.deck.shift
        drawn.state = IN_HAND
        self.ships << drawn
        turn = Turn.create(num: turn_num, player: self, target: drawn)
      else
        raise "You don't have that ship." if !hand.include? ship
        ship.sail target
        turn = Turn.create(num: turn_num, player: self, ship: ship, target: target)
      end

      turns << turn
      game.next_player
      game.save
      turn
    end
  end

  def score
    ships.select {|s| s.state == SCORED }.inject(0){ |total, s| total + s.strength }
  end

  def as_json(options = {})
    super(options.merge(except: [:created_at, :updated_at, :game_id],
                        methods: :merchants
          ))
  end
end

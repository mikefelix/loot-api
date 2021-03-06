class Player < ActiveRecord::Base
  PLAYER_JSON = {
      except: [:created_at, :updated_at, :game_id],
      methods: :name,
      include: {
          merchants: {
              only: [:id, :player_id, :strength],
              include: {
                  attackers: {
                      only: [:id, :strength, :player_id],
                      methods: :color_str
                  }
              }
          }
      }
  }

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
      game.next_player!
      game.save
      turn
    end
  end

  def score
    ships.select {|s| s.state == SCORED }.inject(0){ |total, s| total + s.strength }
  end

  #{
  #  "id": 1,
  #  "user_id": 1,
  #  "name": "Mike",
  #  "merchants": [{
  #          "player_id": 1,
  #          "strength": 4,
  #          "attackers": [{
  #                  "id": 7,
  #                  "player_id": 2,
  #                  "strength": 2,
  #                  "color_str": "green"
  #              }
  #          ]
  #      }
  #  ],
  #  "hand": [{
  #               "id": 1,
  #      "strength": 2,
  #      "color_str": "purple"
  #  }, {
  #      "id": 2,
  #      "strength": 2,
  #      "color_str": "green"
  #  }, {
  #      "id": 4,
  #      "strength": 3,
  #      "color_str": "purple"
  #  }, {
  #      "id": 5,
  #      "strength": 4,
  #      "color_str": "merchant"
  #  }, {
  #      "id": 6,
  #      "strength": 2,
  #      "color_str": "purple"
  #  }]
  # }
  def as_json(options = {})
    opts = options.merge(PLAYER_JSON)
    if options[:hand]
      opts[:include][:hand] = {
          only: [:strength, :id],
          methods: :color_str
      }
    end

    s = super(opts)
    #puts "Player.as_json is using:"
    #for key in opts.keys
    #  puts "#{key}: #{opts[key]}"
    #end
    s
  end

end

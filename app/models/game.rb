class Game < ActiveRecord::Base
  attr_accessible :name, :turn
  belongs_to :current_player, class_name: 'Player'
  has_many :ships
  has_many :players
  #has_many :turns

  def turns_length
    players.inject(0) { |total, p| total + p.turns.length }
  end

  def deck
    ships.select {|s| s.state == IN_DECK }
  end

  def next_player
    idx = players.find_index current_player
    self.current_player = players[(idx + 1) % players.length]
    self.turn += 1
  end

  def self.create_game(opts={})
    name = opts[:name]
    users = opts[:users]
    raise "Need name and player_names" if not name or not users

    g = Game.create name: name

    users.each do |u|
      g.players.create user: u, game: g
    end

    g.new_deck opts[:ships_at_front]

    g.players.each do |player|
      6.times do
        ship = g.deck.shift
        ship.state = IN_HAND
        #puts "Giving #{ship.to_s} to player #{player.name}"
        player.ships << ship
      end
    end

    g.current_player = g.players.first
    g.turn = 1
    g.save
    g
  end

  def new_deck(ships_at_front)
    cards = []
    [2,2,2,2,2,3,3,3,3,3,3,4,4,4,4,4,5,5,5,5,5,6,6,7,8].each do |str|
      cards << Ship.new(color: MERCHANT, game: self, strength: str, state: IN_DECK)
    end

    [GREEN, YELLOW, PURPLE, BLUE].each do |col|
      [1,1,2,2,2,2,3,3,3,3,4,4,100].each do |str|
        cards << Ship.new(color: col, game: self, strength: str, state: IN_DECK)
      end
    end

    cards << Ship.new(color: ADMIRAL, game: self, strength: 1000, state: IN_DECK)

    (ships_at_front || []).each do |type|
      #noinspection RubyArgCount
      idx = cards.find_index { |ship| ship.color == type[:color] and ship.strength == type[:strength] }
      ship = cards.slice!(idx)
      #puts "Adding #{ship.to_s} to deck"
      ships.push ship
    end

    cards.shuffle!

    while cards.length > 0
      ships.push cards.shift
    end

    save!
  end

  def players_in_order
    num = players.length
    start = if current_player.nil?
              0
            else
              players.find_index {|p| p == current_player}
            end
    res = []
    for i in 0..(num-1)
      res << players[(start + i) % num]
    end
    res
  end

  def as_json(options = {})
    super(options.merge(except: [:created_at, :updated_at, :current_player_id],
                        #include: :players,
                        methods: :players_in_order))
  end
end

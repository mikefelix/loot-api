class Game < ActiveRecord::Base
  attr_accessible :name, :turn
  belongs_to :current_player, class_name: 'Player'
  has_many :ships
  has_many :players
  has_many :turns

  def deck
    ships.select {|s| s.state == IN_DECK }
  end

  def gather_loot
    players.each do |p|
      p.merchants.each do |merch|
        current_player.win_ship(merch) if merch.latest_attacker == current_player and merch.winning_attacker == current_player
      end
    end

  end

  def self.create_game(opts={})
    name = opts[:name]
    player_names = opts[:player_names]
    raise "Need name and player_names" if not name or not player_names

    @take_ship = opts[:take_ship]
    @take_ship = lambda {|coll| coll.slice!((rand * coll.length).to_i) } if !@take_ship

    g = Game.create name: name
    player_names.each do |p|
      g.players.create name: p, game: g
    end

    new_deck g
    g.players.each do |player|
      6.times do
        ship = @take_ship.call g.ships
        # lame hack
        ship = ship[0] if ship.respond_to? :length
        ship.state = IN_HAND
        player.ships << ship
      end
    end

    g.current_player = g.players.first
    g
  end

  def take_turn(action, target)
    current_player.gather_loot

    if action == 'draw'
      current_player.draw
    elsif !action or /^\d+$/.match action
      Ship.find(action).sail! target
    else
      raise "Invalid turn \"#{action}\"."
    end
  end

  def draw_ship
    @take_ship.call deck
  end

  def self.new_deck(game)
    deck = []
    [2,2,2,2,2,3,3,3,3,3,3,4,4,4,4,4,5,5,5,5,5,6,6,7,8].each do |str|
      deck << Ship.create(color: MERCHANT, game: game, strength: str, state: IN_DECK)
    end

    [GREEN, YELLOW, PURPLE, BLUE].each do |col|
      [1,1,2,2,2,2,3,3,3,3,4,4,100].each do |str|
        deck << Ship.create(color: col, game: game, strength: str, state: IN_DECK)
      end
    end

    deck << Ship.create(color: ADMIRAL, game: game, strength: 100, state: IN_DECK)
    deck
  end

  def as_json(options = {})
    super(options.merge(except: [:created_at, :updated_at]))
  end
end

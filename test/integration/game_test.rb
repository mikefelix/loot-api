require 'test_helper'

class GameTest < ActiveSupport::TestCase
  test "game creation" do
    g = Game.create_game name: 'Test game', player_names: ['Mike', 'Greg'], ships_at_front: [
        {color: MERCHANT, strength: 2},
        {color: BLUE, strength: 3},
    ]

    assert g.name == 'Test game'
    assert g.players.length == 2
    mike = g.players[0]
    greg = g.players[1]

    assert mike.name == 'Mike'
    assert mike.ships.length == 6

    merchant = mike.ships[0]
    assert mike.merchants.length == 0
    assert merchant.color == MERCHANT
    merchant.sail!
    assert mike.merchants(true).length == 1
    assert mike.hand.length == 5

    pirate = greg.ships[0]
    assert pirate.color != MERCHANT
    pirate.sail! merchant
    assert pirate.target == merchant
    assert merchant.attackers.length == 1
    assert greg.merchant_targets.length == 1
    assert greg.merchant_targets[0] == merchant
    assert greg.ships.length == 6, greg.ships.length.to_s
    assert greg.hand.length == 5
  end

  test "turns" do
    g = Game.create_game name: 'Test game', player_names: ['Mike', 'Greg'], ships_at_front: [
      # hands
      {color: MERCHANT, strength: 6},   # 1:  Mike plays merchant 1
      {color: BLUE, strength: 3},       # 2:  Greg attacks merchant 1
      {color: YELLOW, strength: 3},     # 3:  Mike defends merchant 1, battle is tied
      {color: MERCHANT, strength: 2},   # 4:  Greg plays merchant 2
      {color: BLUE, strength: 4},       # 5:  Mike attacks merchant 2
      {color: BLUE, strength: 100},     # 6:  Greg attacks merchant 1 with captain
      {color: MERCHANT, strength: 4},   # 7:  Mike wins merchant 2, plays merchant 3
      {color: PURPLE, strength: 2},     # 8:  Greg wins merchant 1, attacks merchant 3
      {color: BLUE, strength: 2},       # 9:  Mike
      {color: MERCHANT, strength: 7},   # 10: Greg
      {color: ADMIRAL, strength: 1000}, # 11: Mike
      {color: MERCHANT, strength: 5},   # 12: Greg
      # deck
      {color: PURPLE, strength: 2}, # Greg
      {color: GREEN, strength: 4}, # Mike
    ]

    assert g.ships.first.color == MERCHANT
    assert g.ships.first.strength == 6
    assert g.ships.first == g.players[0].hand.first
    assert g.deck.first.color == PURPLE
    assert g.deck.first.strength == 2

    mike = g.players[0]
    greg = g.players[1]

    t = mike.take_turn mike.hand[0]
    assert t.num == 1
    merch1 = t.ship
    assert mike.hand.length == 5
    assert merch1.color == MERCHANT
    assert merch1.target == mike
    assert mike.merchants.length == 1
    assert greg.merchants.length == 0

    t = greg.take_turn greg.hand[0], merch1
    assert t.num == 2
    assert greg.hand.length == 5
    assert t.ship.color == BLUE
    assert t.ship.target == merch1
    assert greg.merchant_targets.length == 1

    t = mike.take_turn mike.hand[0], merch1
    assert t.num == 3
    assert mike.hand.length == 4
    assert t.ship.color == YELLOW
    assert greg.merchant_targets.length == 1
    assert mike.merchant_targets.length == 1

    t = greg.take_turn greg.hand[0]
    assert t.num == 4
    merch2 = t.ship
    assert greg.hand.length == 4
    assert merch2.color == MERCHANT
    assert mike.merchants.length == 1
    assert greg.merchants.length == 1
    assert mike.merchant_targets.length == 1
    assert greg.merchant_targets.length == 1

    t = mike.take_turn mike.hand[0], merch2
    assert t.num == 5
    assert mike.hand.length == 3
    assert t.ship.color == BLUE
    assert greg.merchant_targets.length == 1
    assert mike.merchant_targets.length == 2

    t = greg.take_turn greg.hand[0], merch1
    assert t.num == 6
    assert greg.hand.length == 3
    assert t.ship.color == BLUE
    assert t.ship.strength == 100
    assert mike.merchants.length == 1
    assert greg.merchants.length == 1
    assert mike.merchant_targets.length == 1
    assert greg.merchant_targets.length == 1

    # Mike wins merchant 2, plays merchant 3
    t = mike.take_turn mike.hand[0]
    assert t.num == 7
    assert mike.hand.length == 2
    assert t.ship.color == MERCHANT
    assert greg.merchant_targets.length == 1
    assert greg.merchants.length == 0
    assert mike.merchant_targets.length == 0
    assert mike.merchants.length == 1

    # Greg wins merchant 1, attacks merchant 3
    t = greg.take_turn greg.hand[0], merch3
    assert t.num == 8
    assert greg.hand.length == 2
    assert t.ship.color == PURPLE
    assert t.ship.strength == 100
    assert mike.merchant_targets.length == 0
    assert mike.merchants.length == 1
    assert greg.merchant_targets.length == 1
    assert greg.merchants.length == 0

    assert mike.score == 2
    assert greg.score == 6
  end
end

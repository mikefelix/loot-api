require 'test_helper'

class GameTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "game creation" do
    took_merch = false
    take_func = lambda do |coll|
      if took_merch then
        coll.delete(coll.find {|s| s.color != MERCHANT })
      else
        took_merch = true
        coll.delete(coll.find {|s| s.color == MERCHANT })
      end
    end

    g = Game.create_game 'Test game', ['Mike', 'Greg'], take_func

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

  end
end

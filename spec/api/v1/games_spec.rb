require 'spec_helper'

describe "/api/v1/games", :type => :controller do

  describe "creating a new game" do

    context "when authorized" do
      it "should create a new game" do
        #c = Game.count
        #json = { name: 'Test', players: [ 'Mike', 'Greg' ] }
        #post :create, json
        #Game.count.should == c + 1
        #response.status.should eq(200)
        ##JSON.parse(response.body)["message"] =~ /authorized/
      end
    end
  end

  describe "turns" do
    it "should execute a sample game" do
      g = Game.create_game name: 'Test game', player_names: ['Mike', 'Greg'], ships_at_front: [
          # hands
          {color: MERCHANT, strength: 6},   # 1:  Mike plays merchant 1
          {color: YELLOW, strength: 3},     # 3:  Mike defends merchant 1, battle is tied
          {color: BLUE, strength: 4},       # 5:  Mike attacks merchant 2
          {color: MERCHANT, strength: 4},   # 7:  Mike wins merchant 2, plays merchant 3
          {color: BLUE, strength: 2},       # 9:  Mike
          {color: ADMIRAL, strength: 1000}, # 11: Mike
          {color: BLUE, strength: 3},       # 2:  Greg attacks merchant 1
          {color: MERCHANT, strength: 2},   # 4:  Greg plays merchant 2
          {color: BLUE, strength: 100},     # 6:  Greg attacks merchant 1 with captain
          {color: PURPLE, strength: 2},     # 8:  Greg wins merchant 1, attacks merchant 3
          {color: MERCHANT, strength: 7},   # 10: Greg
          {color: MERCHANT, strength: 5},   # 12: Greg
          # deck
          {color: PURPLE, strength: 2}, # Greg
          {color: GREEN, strength: 4}, # Mike
      ]

      assert g.ships.first.color == MERCHANT, g.ships.first.color.to_s + g.ships.first.strength.to_s
      assert g.ships.first.strength == 6
      assert g.ships.first == g.players[0].hand.first
      assert g.deck.first.color == PURPLE
      assert g.deck.first.strength == 2

      mike = g.players[0]
      greg = g.players[1]

      assert mike.hand[0].color == MERCHANT, mike.hand[0].to_s
      t = mike.take_turn mike.hand[0]
      assert t.num == 1
      merch1 = t.ship
      assert mike.hand.length == 5
      assert merch1.color == MERCHANT
      assert merch1.target == mike
      assert mike.merchants(true).length == 1
      assert greg.merchants(true).length == 0

      assert greg.hand[0].color == BLUE, greg.hand[0].to_s
      t = greg.take_turn greg.hand[0], merch1
      assert t.num == 2
      assert greg.hand.length == 5
      assert t.ship.color == BLUE
      assert t.ship.target == merch1
      assert merch1.attackers(true).include? t.ship
      assert greg.merchant_targets(true).length == 1
      assert merch1.attackers(true).length == 1
      assert merch1.latest_attacker == greg
      assert merch1.winning_attacker == greg

      t = mike.take_turn mike.hand[0], merch1
      assert t.num == 3
      assert mike.hand.length == 4
      assert t.ship.color == YELLOW
      assert greg.merchant_targets(true).length == 1
      assert mike.merchant_targets(true).length == 1
      assert merch1.attackers(true).include? t.ship
      assert merch1.attackers(true).length == 2
      assert merch1.latest_attacker == mike
      assert merch1.winning_attacker == nil

      t = greg.take_turn greg.hand[0]
      assert t.num == 4
      merch2 = t.ship
      assert greg.hand.length == 4
      assert merch2.color == MERCHANT
      assert mike.merchants(true).length == 1
      assert greg.merchants(true).length == 1
      assert mike.merchant_targets(true).length == 1
      assert greg.merchant_targets(true).length == 1

      t = mike.take_turn mike.hand[0], merch2
      assert t.num == 5
      assert mike.hand.length == 3
      assert t.ship.color == BLUE
      assert greg.merchant_targets(true).length == 1
      assert mike.merchant_targets(true).length == 2

      t = greg.take_turn greg.hand[0], merch1
      assert t.num == 6
      assert greg.hand.length == 3
      assert t.ship.color == BLUE
      assert t.ship.strength == 100
      assert t.target == merch1
      assert mike.merchants(true).length == 1
      assert greg.merchants(true).length == 1
      assert mike.merchant_targets(true).length == 2
      assert greg.merchant_targets(true).length == 1
      assert merch1.attackers(true).include? t.ship
      assert merch1.attackers(true).length == 3, merch1.attackers.inject(""){ |s,a| s + a.to_s + "," }
      assert merch1.latest_attacker == greg
      assert merch1.winning_attacker == greg

      # Mike wins merchant 2, plays merchant 3
      t = mike.take_turn mike.hand[0]
      assert t.num == 7
      assert mike.hand.length == 2
      assert t.ship.color == MERCHANT
      assert t.ship.strength == 4
      captured = t.captures[0]
      assert captured.ship.color == MERCHANT
      assert captured.ship.strength == 4
      assert captured.player == mike
      assert captured.target == nil
      assert greg.merchant_targets(true).length == 1
      assert !greg.merchants(true).include?(captured)
      assert greg.merchants(true).length == 0, greg.merchants.inject(""){ |s,a| s + a.to_s + "," }
      assert mike.merchant_targets(true).length == 0
      assert mike.merchants(true).length == 1
      assert mike.score == 2
      assert greg.score == 0

      # Greg wins merchant 1, attacks merchant 3
      t = greg.take_turn greg.hand[0], merch3
      assert t.num == 8
      assert greg.hand.length == 2
      assert t.ship.color == PURPLE
      assert t.ship.strength == 100
      assert mike.merchant_targets(true).length == 0
      assert mike.merchants(true).length == 1
      assert greg.merchant_targets(true).length == 1
      assert greg.merchants(true).length == 0
      assert mike.score == 2
      assert greg.score == 6

    end
  end
end
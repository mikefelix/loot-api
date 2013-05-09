describe 'Game model', ->
  game = null
  merch1 = null

  beforeEach module 'LootApp'

  beforeEach inject (Models) ->
    att1 = new Models.Pirate
      id: 4
      strength: 2
      color_str: 'blue'
      player_id: 2
    merch1 = new Models.Merchant
      id: 5
      strength: 2
      attackers: [ att1 ]
    m = new Models.Player
      id: 1
      user_id: 1
      name: 'Mike'
      merchants: [ merch1 ]
      hand: []
    k = new Models.Player
      id: 2
      user_id: 1
      name: 'Mike'
      merchants: []
      hand: []
    game = new Models.Game
      id: 9
      name: 'Test'
      turn: 1
      players: [ m, k ]

  describe 'Game', ->
    xit 'calculates its winner', ->
      expect(game.winner()?.id).toBe 2

  describe 'Merchant', ->
    it 'calculates its winner', ->
      expect(+merch1.winner()).toBe 2
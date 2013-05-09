describe 'GameCtrl', ->
  scope = null
  httpBackend = null
  ctrl = null

  beforeEach(module 'LootApp')

#  afterEach ->
#    httpBackend.verifyNoOutstandingExpectation()
#    httpBackend.verifyNoOutstandingRequest()

  beforeEach inject ($rootScope, $injector, $controller, GameMapper) ->
    scope = $rootScope.$new()
    httpBackend = $injector.get '$httpBackend'
    httpBackend.whenGET('/api/v1/games/1').respond '''
      {
        "id": 1,
        "name": "afd",
        "turn": 3,
        "players": [
          {
            "id": 1,
            "user_id": 1,
            "name": "Mike",
            "merchants": [
              {
                "id": 3,
                "player_id": 1,
                "strength": 4,
                "attackers": [
                  {
                    "id": 7,
                    "player_id": 2,
                    "strength": 2,
                    "color_str": "green"
                  }
                ]
              },
              {
                "id": 33,
                "player_id": 1,
                "strength": 5,
                "attackers": [
                  {
                    "id": 17,
                    "player_id": 2,
                    "strength": 2,
                    "color_str": "green"
                  },
                  {
                    "id": 18,
                    "player_id": 1,
                    "strength": 2,
                    "color_str": "blue"
                  }
                ]
              },
              {
                "id": 34,
                "player_id": 1,
                "strength": 3,
                "attackers": [
                  {
                    "id": 27,
                    "player_id": 2,
                    "strength": 2,
                    "color_str": "green"
                  },
                  {
                    "id": 28,
                    "player_id": 1,
                    "strength": 3,
                    "color_str": "blue"
                  }
                ]
              }
            ]
          },
          {
            "id": 2,
            "user_id": 2,
            "name": "Kimberly",
            "merchants": [
              {
                "id": 64,
                "player_id": 2,
                "strength": 3,
                "attackers": []
              }
            ]
          },
          {
            "id": 3,
            "user_id": 3,
            "name": "Aaron",
            "merchants": []
          },
          {
            "id": 4,
            "user_id": 4,
            "name": "Greg",
            "merchants": []
            },
          {
            "id": 5,
            "user_id": 5,
            "name": "Lily",
            "merchants": []
          }
        ]
      }
    '''

    httpBackend.whenGET('/api/v1/players/1').respond '''
      {
        "id": 1,
        "user_id": 1,
        "name": "Mike",
        "merchants": [
          {
            "id": 3,
            "player_id": 1,
            "strength": 4,
            "attackers": [
              {
                "id": 7,
                "player_id": 2,
                "strength": 2,
                "color_str": "green"
              }
            ]
          }
        ],
        "hand": [
          {
            "id": 1,
            "strength": 2,
            "color_str": "purple"
          },
          {
            "id": 2,
            "strength": 2,
            "color_str": "green"
          },
          {
            "id": 4,
            "strength": 3,
            "color_str": "purple"
          },
          {
            "id": 5,
            "strength": 4,
            "color_str": "merchant"
          },
          {
            "id": 6,
            "strength": 2,
            "color_str": "purple"
          }
        ]
      }
    '''

    currentGame = GameMapper.retrieve 1
    httpBackend.flush()

    ctrl = $controller 'GameCtrl',
      $scope: scope
      $window: {alert: (s) -> window.alert(s)}
      currentGame: currentGame
      PlayerMapper: $injector.get 'PlayerMapper'
      loggedInUser: { name: 'Mike', id: 1 }
      Drawing: {}

    httpBackend.flush()

  it 'should generate correct game html', ->
    expect(scope.loggedInUser.name).toBe 'Mike'
    expect(scope.game.id).toEqual 1
    expect(scope.players.length).toEqual 5
    expect(scope.player.id).toEqual 1

    kimberly = _.find scope.players, (p) -> p.name == 'Kimberly'
    mike = _.find scope.players, (p) -> p.name == 'Mike'

    expect(mike.merchants[0].winner()).toBe kimberly
    expect(mike.merchants[0].attackers[0].imageUrl()).toBe 'ships/green.png'

    expect(mike.merchants[1].winner()).toBe null
    expect(mike.merchants[1].attackers[0].imageUrl()).toBe 'ships/green.png'
    expect(mike.merchants[1].attackers[1].imageUrl()).toBe 'ships/blue.png'
    expect(mike.merchants[1].attackers[1].strength).toEqual 2

    expect(mike.merchants[2].winner()).toBe mike

    expect(kimberly.merchants[0].winner()).toBe kimberly

#    expect(scope.game.winner()).toBe mike   # Can't know this yet.
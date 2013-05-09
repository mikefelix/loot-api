LootApp.factory 'PlayerMapper', (ModelMapper, Models) ->
  ModelMapper.map Models.Player, '/api/v1/players/:id'

LootApp.factory 'GameMapper', (ModelMapper, Models) ->
  ModelMapper.map Models.Game, '/api/v1/games/:id'

LootApp.factory 'GameResource', ($resource) ->
  $resource '/api/v1/games/:id', id: '@id'

###
Game = LootApp.factory 'Game', ($resource, WaitFor, Merchant) ->
  res = $resource '/api/v1/games/:id', id: '@id'
  attachMethods = (game) ->
    angular.extend game,
      winner: -> _.max game.players, (p) -> p.score()
    _.each game.players, (p) ->
      _.each p.merchants, (m) ->
        angular.extend m, Merchant

  res.getSynchronous = (opts) ->
    WaitFor.resource res, opts, attachMethods
  res

LootApp.factory 'Player', ($resource) ->
  $resource '/api/v1/players/:id', id: '@id'

LootApp.factory 'User', ($resource) ->
  $resource '/api/v1/users/:id', id: '@id'

LootApp.factory 'Turn', ($resource) ->
  $resource '/api/v1/games/:gameId/turns/:turnId'
            turnId: '@id'
            gameId: '@game_id'
###

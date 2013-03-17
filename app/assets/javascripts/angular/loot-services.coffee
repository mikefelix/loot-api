
LootApp.factory 'Game', ($resource) ->
  $resource '/api/v1/games/:id'
            id: '@id'

LootApp.factory 'Player', ($resource) ->
  $resource '/api/v1/players/:id'
            id: '@id'

LootApp.factory 'User', ($resource) ->
  $resource '/api/v1/users/:id'
            id: '@id'

LootApp.factory 'Turn', ($resource) ->
  $resource '/api/v1/games/:gameId/turns/:turnId'
            turnId: '@id'
            gameId: '@game_id'

LootApp.service 'Drawing', ->
  @playerCoords = (numPlayers, radius, origin, xWeight = 1, yWeight = 1) ->
    div = Math.PI * 2 / numPlayers
    ninety = Math.PI / 2
    [ origin[0] + xWeight * parseInt(radius * Math.cos(i * div + ninety)),
      origin[1] + yWeight * parseInt(radius * Math.sin(i * div + ninety)) ] for i in [0..numPlayers - 1]

LootApp.service 'Defer', ($route, $q) ->
  @resource = (resourceMethod, args) ->
    deferred = $q.defer()
    resourceMethod args, (successData) -> deferred.resolve successData, () -> deferred.reject()
    deferred.promise

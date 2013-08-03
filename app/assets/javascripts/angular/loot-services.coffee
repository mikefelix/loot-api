LootApp.service 'Drawing', ->
  @playerCoords = (numPlayers, radius, origin, xWeight = 1, yWeight = 1) ->
    div = Math.PI * 2 / numPlayers
    ninety = Math.PI / 2
    [ origin[0] + xWeight * parseInt(radius * Math.cos(i * div + ninety)),
      origin[1] + yWeight * parseInt(radius * Math.sin(i * div + ninety)) ] for i in [0..numPlayers - 1]

LootApp.service 'Defer', ($q) ->
  @resource = (resourceMethod, args, onSuccess) ->
    deferred = $q.defer()
    success = (successData) ->
      onSuccess successData if onSuccess?
      deferred.resolve successData
    error = (err) -> deferred.reject err
    resourceMethod args, success, error
    deferred.promise

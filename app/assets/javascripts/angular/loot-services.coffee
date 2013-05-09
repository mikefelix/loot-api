LootApp.service 'ModelMapper', ($http) ->
  getId = (model) ->
    if typeof(model) == 'number'
      model
    else
      model['id']

  # Returns a copy of source, as an instance of modelClass if applicable.
  # Valid usages, given class A:
  #   copyProperty 1 -> 1 (argument returned)
  #   copyProperty '1' -> '1' (argument returned)
  #   copyProperty [1, 2] -> [1, 2] (copied array)
  #   copyProperty {a: 1}, -> {a: 1} (copied object)
  #   copyProperty {a: 1}, A -> new A({a:1}) (model with copied properties)
  #   copyProperty [{a: 1},{b:2}], A -> [ new A({a:1}), new A({'b':2}) ] (array of models with copied properties)
  # Invalid usages:
  #   copyProperty 1, A
  #   copyProperty '1', A
  #   copyProperty [1,2], A
  copyProperty = @copyAsModel = (source, modelClass) ->
    if $.isArray source
      arr = []
      for p, i in source
        arr[i] = copyProperty p, modelClass
      arr
    else if typeof source == 'object'
      alert "string #{modelClass}" if typeof modelClass is 'string'
      model = if modelClass? then new modelClass() else {}
      for own p of source
        model[p] = copyProperty source[p], modelClass?.propertyTypes?[p]
      model
    else
      throw "Specified #{modelClass} but #{source} is not an object." if modelClass?
      source

  @map = (modelClass, url) ->
    throw 'No RESTful URL provided' if !url?
    throw 'No :id parameter in GET URL' if not /:\bid\b/.test url
    createUrl = url.replace /\/:\bid\b/g, ''
    genericError = (err) -> console.log "ERROR in DataMapper: #{err}"

    retrieve: (id, onSuccess = (->), onError = genericError) ->
      model = new modelClass()
      $http.get(url.replace(/:\bid\b/g, id))
        .success (data) ->
          for own p of data
            model[p] = copyProperty data[p], modelClass.propertyTypes?[p]
          onSuccess model, data
        .error (err) ->
          onError err, model
      model

    create: (model, onSuccess = (->), onError = genericError) ->
      $http.post(createUrl, model)
        .success (data) ->
          angular.extend model, data
          onSuccess model, data
        .error (err) ->
          onError err, model
      model

    update: (model, onSuccess = (->), onError = genericError) ->
      id = getId model
      throw 'No id found in model' if !id?

      $http.put(url.replace(/:\bid\b/g, id), model)
        .success (data) ->
          onSuccess model, data
        .error (err) ->
          onError err, model
      model

    destroy: (model, onSuccess = (->), onError = genericError) ->
      id = getId model
      throw 'No id found in model' if !id?

      $http({url: url.replace(/:\bid\b/g, id), method: 'DELETE'})
        .success (data) ->
          onSuccess model, data
        .error (err) ->
          onError err, model
      model

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

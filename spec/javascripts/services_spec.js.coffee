describe 'ModelMapper', ->
  mapper = null
  backend = null

  class Jacket
    constructor: (@color) ->
    pop: -> 'Collar!'

  class Tire
    constructor: (@level) ->
    pop: -> "#{@level} is too much! Boom!"

  class Trunk
    constructor: (@empty) ->

  class Car
    @propertyTypes:
      tires: Tire
      trunk: Trunk
    constructor: (@name, @tires) ->
    drive: () -> 'Vroom.'

  class Person
    @propertyTypes:
      cars: Car
      jacket: Jacket
    @requiredProps: [ 'name', 'jacket' ]
    constructor: (@name, @cars, @jacket) ->
    drive: () -> 'Wheeeee!'

  beforeEach module 'LootApp'

  beforeEach inject (ModelMapper, $httpBackend) ->
    backend = $httpBackend
    mapper = ModelMapper.map Person, '/fake/url/:id'

  afterEach ->
    backend.verifyNoOutstandingExpectation()
    backend.verifyNoOutstandingRequest()

  it 'maps properties to new models', inject (ModelMapper) ->
    expect(ModelMapper.copyAsModel 1).toBe 1
    expect(ModelMapper.copyAsModel [1,2]).toEqual [1,2]
    expect(ModelMapper.copyAsModel {a:1}).toEqual {a:1}

    model = ModelMapper.copyAsModel {level: 6}, Tire
    expect(model.pop()).toBe '6 is too much! Boom!'

    models = ModelMapper.copyAsModel [{level: 7}, {level: 8}], Tire
    expect(models[0].pop()).toBe '7 is too much! Boom!'
    expect(models[1].pop()).toBe '8 is too much! Boom!'

    model = ModelMapper.copyAsModel { name:"Blaster", tires: [ {level: 4} ], trunk: {empty: false} }, Car
    expect(model.name).toBe 'Blaster'
    expect(model.trunk.empty).toBe false
    expect(model.trunk._parent).toBe model
    expect(model.tires[0].pop()).toBe '4 is too much! Boom!'
    expect(model.tires[0]._parent).toBe model

  it 'can retrieve models', ->
    backend.expectGET('/fake/url/1').respond '''
                                             {
                                               "id": 1,
                                               "name": "Joe",
                                               "cars": [
                                                 {
                                                   "id": 1,
                                                   "name": "Honks",
                                                   "tires": [
                                                     { "id": 1, "level": 11 },
                                                     { "id": 2, "level": 22 },
                                                     { "id": 3, "level": 33 },
                                                     { "id": 4, "level": 44 }
                                                   ],
                                                   "trunk": { "empty": false }
                                                 },
                                                 {
                                                   "id": 2,
                                                   "name": "Beeps",
                                                   "tires": [
                                                     { "id": 11, "level": 21 },
                                                     { "id": 12, "level": 22 },
                                                     { "id": 13, "level": 23 },
                                                     { "id": 14, "level": 24 }
                                                   ],
                                                   "trunk": { "empty": true }
                                                 }
                                               ],
                                               "jacket": { "id": 8, "color": "fuchsia" }
                                             }
                                             '''
    joe = mapper.retrieve 1
    backend.flush()

    beeps = joe.cars[1]

    expect(joe.id).toBe 1
    expect(joe.name).toBe 'Joe'
    expect(joe.drive()).toBe 'Wheeeee!'

    expect(joe.jacket.color).toBe 'fuchsia'
    expect(joe.jacket.pop()).toBe 'Collar!'

    expect(beeps.name).toBe 'Beeps'
    expect(beeps.drive()).toBe 'Vroom.'
    expect(beeps.tires[3].level).toBe 24
    expect(beeps.tires[1].pop()).toBe '22 is too much! Boom!'
    expect(beeps.tires[2]._parent).toBe beeps

    expect(beeps.trunk.empty).toBe true
    expect(beeps.trunk._parent).toBe beeps


  it 'errors on save with insufficient data', ->

  it 'can save new models', ->
    backend.expectPOST('/fake/url', '{"level":20}').respond '{ "id": 1 }'
    t = new Tire 20
    mapper.create t
    backend.flush()

    expect(t.id).toBe 1
    expect(t.level).toBe 20

  it 'can update models', ->
    backend.expectPUT('/fake/url/1').respond 200
    t = new Tire 20
    t.id = 1
    mapper.update t
    backend.flush()

  it 'can delete models', ->
    backend.expectDELETE('/fake/url/1').respond 200
    t = new Tire 20
    t.id = 1
    mapper.destroy t
    backend.flush()

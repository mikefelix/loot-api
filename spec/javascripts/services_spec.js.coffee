describe 'ModelMapper', ->
  mapper = null
  backend = null

  class Jacket
    constructor: (@color) ->
    pop: -> 'Collar!'

  class Tire
    constructor: (@level) ->
    pop: -> "#{@level} is too much! Boom!"

  class Car
    @propertyTypes:
      tires: Tire
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

  xit 'maps properties to new models', inject (ModelMapper) ->
    expect(ModelMapper.copyAsModel 1).toBe 1
    expect(ModelMapper.copyAsModel [1,2]).toEqual [1,2]
    expect(ModelMapper.copyAsModel {a:1}).toEqual {a:1}

    model = ModelMapper.copyAsModel {level: 6}, Tire
    expect(model.pop()).toBe '6 is too much! Boom!'

    models = ModelMapper.copyAsModel [{level: 7}, {level: 8}], Tire
    expect(models[0].pop()).toBe '7 is too much! Boom!'
    expect(models[1].pop()).toBe '8 is too much! Boom!'

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
                                                   ]
                                                 },
                                                 {
                                                   "id": 2,
                                                   "name": "Beeps",
                                                   "tires": [
                                                     { "id": 11, "level": 21 },
                                                     { "id": 12, "level": 22 },
                                                     { "id": 13, "level": 23 },
                                                     { "id": 14, "level": 24 }
                                                   ]
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
    expect(joe.drive()).toBe 'Wheeee!'

    expect(joe.jacket.color).toBe 'fuchsia'
    expect(joe.jacket.pop()).toBe 'Collar!'

    expect(beeps.name).toBe 'Beeps'
    expect(beeps.drive()).toBe 'Vroom.'
    expect(beeps.tires[3].level).toBe 24
    expect(beeps.tires[1].pop()).toBe '22 is too much! Boom!'

  xit 'errors on save with insufficient data', ->

  xit 'can save new models', ->
    backend.expectPOST('/fake/url', '{"str":"I am new"}').respond '{ "id": 1 }'
    t = new Test 'I am new'
    mapper.create t
    backend.flush()

    expect(t.id).toBe 1
    expect(t.str).toBe 'I am new'

  xit 'can update models', ->
    backend.expectPUT('/fake/url/1').respond 200
    t = new Test 'stuff'
    t.id = 1
    mapper.update t
    backend.flush()

  xit 'can delete models', ->
    backend.expectDELETE('/fake/url/1').respond 200
    t = new Test 'stuff'
    t.id = 1
    mapper.destroy t
    backend.flush()

describe 'card', ->
#  loadFixtures 'baz' # located at 'spec/javascripts/fixtures/baz.html.haml'
  elem = null
  scope = null

  beforeEach(module 'LootApp')

  beforeEach inject ($rootScope, $compile) ->
    elem = angular.element '''<div>
                           <card ship="ship" id="ship_{{ship.id}}" />
                           </div>'''
    scope = $rootScope.$new()
    scope.ship = {id: 1, strength: 4, color_str: 'blue'}
    $compile(elem)(scope)
    scope.$digest()

  it 'should generate the html', ->
    ship = elem.children()[0]
    expect(ship.id).toBe 'ship_1'

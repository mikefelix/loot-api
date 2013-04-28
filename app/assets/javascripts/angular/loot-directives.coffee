LootApp.directive 'ngPlaceholder', () ->
  restrict: 'A'
  transclude: false
  link: (scope, elem, attrs) ->
    if elem.val() == ''
      scope.placeholding = true
      elem.val attrs.ngPlaceholder
      elem.css 'color', '#ddd'
    elem.bind 'focus', ->
      if scope.placeholding
        elem.val('')
        elem.css 'color', '#000'
        scope.placeholding = false
    elem.bind 'blur', ->
      if elem.val() == ''
        elem.val(attrs.placeholder)
        elem.css 'color', '#ddd'
        scope.placeholding = true

LootApp.directive 'card', () ->
  restrict: 'E'
  transclude: false
  replace: true
  template: '<div class="{{ship.color_str}}">{{ship.strength}}</div>'
  scope:
    ship: '='
#  link: (scope, elem) ->
#    elem.class scope.card.color_str
#    elem.html scope.card.strength

###
LootApp.directive 'player', () ->
  restrict: 'A'
  scope: {
    player: '='
  }
  link: (scope, elem, attrs) ->
    numPlayers = attrs['numPlayers']
    elem.css 'width', '100%'
    step = parseInt(elem.width / numPlayers)
    i = 0
    angular.forEach elem.find('div'), (e) ->
      e.css 'position', 'absolute'
      e.css 'left', "#{step + i}px"
      i += 1

LootApp.directive 'merchant', () ->
  restrict: 'AC'
  transclude: true
  replace: false
  scope: {
    merchant: '='
  }
  template: '<div class="merchant"><div ng-transclude /></div>'
  compile: (elem, attrs) ->
    content = elem.children()
    for i in attrs.repeat
      tElement.append(content.clone());

LootApp.directive 'carrier', () ->
  restrict: 'AC'
  link: (scope, elem, attrs) ->

LootApp.directive 'attackers', () ->
  restrict: 'AC'
  replace: false
  require: '^merchant'
  template: '<div class="attackers"><div ng-repeat="a in attackers" /></div>'
  scope: {
    attackers: '='
  }
  link: (scope, elem, attrs, ctrlrs) ->
###



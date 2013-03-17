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

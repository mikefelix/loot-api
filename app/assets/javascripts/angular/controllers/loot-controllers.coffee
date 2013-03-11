'use strict'

LootApp = angular.module('LootApp', ['ngResource']);

LootApp.config ['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
  $routeProvider.when '/games'
    templateUrl: '/partials/games'
    controller: 'GameChooseCtrl'
  $routeProvider.when '/newGame'
    templateUrl: '/partials/newGame'
    controller: 'NewGameCtrl'
  $routeProvider.when '/game/:id'
    templateUrl: '/partials/game'
    controller: 'GameCtrl'
  $routeProvider.otherwise
    redirectTo: '/games'
#  $locationProvider.html5Mode true
]

LootApp.controller 'NewGameCtrl', ($rootScope, $scope, Game, User) ->
  $rootScope.user =
    id: 1
    name: 'You'
    token: 'dHp8H23Uuiq1'
  $scope.searchResults = []
  $scope.newGameUsers = [$scope.user]
  $scope.userSearch = 'Search for a user'
  users = User.query() #search $scope.userSearch
  $scope.usernameTextEntered = ->
    if $scope.userSearch == ''
      $scope.searchResults = []
      return
    r = []
    regex = new RegExp('^' + $scope.userSearch, 'i')
    for u in users
      r.push u if regex.test u.name
    r
    $scope.searchResults = r
  $scope.addUser = (u) ->
    $scope.newGameUsers.push u
    $scope.searchResults = []
    $scope.userSearch = ''
    $('#userSearch').focus()
  $scope.createGame = () ->
    Game.save
      name: $scope.gameName
      users: { u } for u in $scope.newGameUsers

LootApp.controller 'GameChooseCtrl', ($rootScope, $scope, Game, User) ->
  $scope.games = Game.query()

LootApp.controller 'GameCtrl', ($scope, Game, Player, $routeParams) ->
  $scope.game = Game.get
    id: $routeParams.id
  $scope.player = Player.get
    id: getPlayerId user, game

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

LootApp.filter 'fitsSearch', ($scope) ->
  (users) ->
    r = []
    regex = new RegExp('^' + $scope.userSearch)
    for u in users
      r.push u if regex.test u.name
    r

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


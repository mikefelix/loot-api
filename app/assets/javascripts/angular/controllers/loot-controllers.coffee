'use strict'

LootApp = angular.module('LootApp', ['ngResource']);

LootApp.config ['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
  $routeProvider.when '/games'
    templateUrl: '/partials/games'
    controller: 'GameChooseCtrl'
  $routeProvider.when '/game/:id'
    templateUrl: '/partials/game'
    controller: 'GameCtrl'
  $routeProvider.otherwise
    redirectTo: '/games'
#  $locationProvider.html5Mode true
]

LootApp.controller 'GameChooseCtrl', ($scope, Game) ->
  $scope.games = Game.query()
  $scope.createGame = (name, players) ->
    game =
      name: name
      player_names: players
    Game.save game

LootApp.controller 'GameCtrl', ($scope, Game, $routeParams) ->
  $scope.game = Game.get
    id: $routeParams.id

LootApp.factory 'Game', ($resource) ->
  $resource '/api/v1/games/:id'
    id: '@id'

LootApp.factory 'Turn', ($resource) ->
  $resource '/api/v1/games/:gameId/turns/:turnId'
    turnId: '@id'
    gameId: '@game_id'

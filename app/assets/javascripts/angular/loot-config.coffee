LootApp.value 'loggedInUser'
  name: 'Mike'
  id: 1

LootApp.config ['$routeProvider', ($routeProvider) ->
  $routeProvider.when '/games'
                      templateUrl: '/partials/games'
                      controller: 'GameChooseCtrl'
  $routeProvider.when '/newGame'
                      templateUrl: '/partials/newGame'
                      controller: 'NewGameCtrl'
                      resolve:
                        allUsers: (User) -> User.query()
  $routeProvider.when '/game/:id'
                      templateUrl: '/partials/game'
                      controller: 'GameCtrl'
                      resolve:
                        currentGame: ($route, GameMapper) ->
                          GameMapper.retrieve $route.current.params['id']

  $routeProvider.otherwise
    redirectTo: '/games'

#  $locationProvider.html5Mode true
]

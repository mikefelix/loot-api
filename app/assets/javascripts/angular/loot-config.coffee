LootApp.value 'loggedInUser'
  name: 'Mike'
  id: 1

LootApp.config ['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
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
                        currentGame: ($route, Game) -> Game.get id: $route.current.params['id']
#                        currentGame: ($route, $q, Game) ->
#                          deferred = $q.defer()
#                          Game.get
#                            id: $route.current.params['id']
#                            (successData) -> deferred.resolve successData
#                            () -> deferred.reject()
#                          deferred.promise
  $routeProvider.otherwise
    redirectTo: '/games'

#  $locationProvider.html5Mode true
]

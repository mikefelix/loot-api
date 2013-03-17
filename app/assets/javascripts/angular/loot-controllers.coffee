
LootApp.controller 'GameChooseCtrl', ($rootScope, $scope, Game, User, loggedInUser) ->
  $scope.games = Game.query()

LootApp.controller 'GameCtrl', ($scope, $window, currentGame, Player, loggedInUser, Drawing) ->
  $scope.game = currentGame
  $scope.players = $scope.game.players_in_order
  player = $scope.players.filter (p) -> p.user_id == loggedInUser.id
  $scope.player = Player.get
    id: player[0].id
  height = $window.innerHeight;
  width = $window.innerWidth;
  radius = parseInt(Math.min(width, height) / 2) - 100
  origin = [parseInt(width / 2), parseInt(height / 2)]
  playerCoords = Drawing.playerCoords $scope.players.length, radius, origin, 1.5
  for i in [0..playerCoords.length - 1]
    $scope.players[i].coords = playerCoords[i];

LootApp.controller 'NewGameCtrl', ($rootScope, $scope, Game, allUsers, loggedInUser, $location, $window) ->
  $scope.addedUsers = []
  $scope.userNames = []
  $scope.usersByName = {}

  for u in allUsers when u.id != loggedInUser.id
    $scope.userNames.push u.name
    $scope.usersByName[u.name] = u

  $scope.userAdded = (name) ->
    $scope.addedUsers.push $scope.usersByName[name]
    delete $scope.usersByName[name]
    $scope.userNames.splice $scope.userNames.indexOf(name), 1
    $window.setTimeout "var d=$('#userSearch');d.val('');d.blur();d.focus();", 100
#    $('#userSearch').val '' # Doesn't work because of typeahead

  $scope.createGame = () ->
    users = (u.id for u in $scope.addedUsers)
    users.unshift loggedInUser.id
    Game.save
      name: $scope.gameName
      users: users
    $location.url('/games')

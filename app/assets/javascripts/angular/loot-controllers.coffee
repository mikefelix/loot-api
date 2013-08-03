
LootApp.controller 'GameChooseCtrl', ($rootScope, $scope, GameResource) ->
  $scope.games = GameResource.query()

LootApp.controller 'GameCtrl', ($scope, $window, currentGame, PlayerMapper, loggedInUser, Drawing) ->
  $scope.loggedInUser = loggedInUser
  $scope.game = currentGame

  $window.alert 'game is missing! ' if !currentGame
  if not $scope.game.players
    $window.alert "players are missing! #{$scope.game.id}/#{Object.keys($scope.game).join(',')}"

  $scope.players = $scope.game.players

  # This service returns restricted information
  $scope.player = PlayerMapper.retrieve(($scope.players.filter (p) -> p.user_id == loggedInUser.id)[0].id)

  $scope.trackHeight = Math.floor(100 / $scope.players.length) + '%'

  $scope.merchLeft = (i) ->
    for p, i in $scope.players
      currentPlayerIdx = i if p.id is $scope.player.id
    halfWidth = Math.floor(100 / ($scope.players.length * 2))
    "#{halfWidth * i + halfWidth}%"

#  height = $window.innerHeight;
#  width = $window.innerWidth;
#  radius = parseInt(Math.min(width, height) / 2) - 100
#  origin = [parseInt(width / 2), parseInt(height / 2)]
#  playerCoords = Drawing.playerCoords $scope.players.length, radius, origin, 1.5

#  playerCoords = []
#
#  for i in [0..playerCoords.length - 1]
#    $scope.players[i].coords = playerCoords[i];

  $scope.isCurrentPlayer = (player) -> player.id is $scope.game.currentPlayer().id

  $scope.acceptPirate = (e, ui) ->
    draggable = ui.draggable[0]
    droppable = e.target
    hand = $scope.player.hand
    i = _.indexOf hand, _.find(hand, (s) -> 'ship_' + ship.id == draggable.id)
    alert 'Cannot find ship.' if !i?
    removed = hand.splice i, 1
    for p in $scope.players
      for s in p.merchants
        if s.id == 'ship_' + droppable.id
          s.attackers.push removed

  $scope.acceptMerch = (e, ui) ->
    draggable = ui.draggable[0]
    droppable = e.target
    hand = $scope.player.hand
    i = _.indexOf hand, _.find(hand, (s) -> 'ship_' + ship.id == draggable.id)
    alert 'Cannot find ship.' if !i?
    removed = hand.splice i, 1
    player = _.find $scope.players, (p) -> droppable.id == "player_" + p.id
    player.merchants.push removed

LootApp.controller 'NewGameCtrl', ($rootScope, $scope, GameMapper, allUsers, loggedInUser, $location, $window) ->
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
    game = new Game
      name: $scope.gameName
      users: users
    GameMapper.create game
    $location.url('/games')

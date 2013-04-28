
LootApp.controller 'GameChooseCtrl', ($rootScope, $scope, Game) ->
  $scope.games = Game.query()

LootApp.controller 'GameCtrl', ($scope, $window, currentGame, Player, loggedInUser, Drawing) ->
  $scope.loggedInUser = loggedInUser
  $scope.game = currentGame

  $window.alert 'game is missing! ' if !currentGame
  if not $scope.game.players
    $window.alert "players are missing! #{$scope.game.id}/#{Object.keys($scope.game).join(',')}"

  $scope.players = $scope.game.players
  player = $scope.players.filter (p) -> p.user_id == loggedInUser.id

  # This service returns restricted information
  $scope.player = Player.get
    id: player[0].id

  winner = (attackers) ->
    totals = {}
    for s in attackers
      totals[s.player_id] = (totals[s.player_id]? or 0) + s.strength
    totals = totals # rubymine you suck
    scores = for p, s of totals
      player: p
      score: s
    scores = scores.sort (a,b) ->
      if a.score < b.score -1
      else if b.score < a.score 1
      else 0
    if scores.length == 1 or (scores.length > 1 and scores[0].score > scores[1].score)
      scores[0].player
    else
      null

  for p in $scope.players
    for m in p.merchants
      m.winner = $scope.game.pmap[winner m.attackers]
      for a in m.attackers
        a.imageUrl = "ships/#{a.color_str}.png"

#  height = $window.innerHeight;
#  width = $window.innerWidth;
#  radius = parseInt(Math.min(width, height) / 2) - 100
#  origin = [parseInt(width / 2), parseInt(height / 2)]
#  playerCoords = Drawing.playerCoords $scope.players.length, radius, origin, 1.5

#  playerCoords = []
#
#  for i in [0..playerCoords.length - 1]
#    $scope.players[i].coords = playerCoords[i];

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

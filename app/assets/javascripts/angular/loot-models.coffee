LootApp.service 'Models', () ->
  @Model = class Model
      constructor: (props) ->
        return if not props?
        @[prop] = props[prop] for own prop of props
#        @validatePresenceOf @requiredProperties, ['id']
#      requiredProperties: -> ['id']
#      validatePresenceOf: (props, except) ->
#        for p in props
#          throw "Missing property #{prop}." if !this[p]? and !_.contains except, p
#      @validateArrival: ->
#        @validatePresenceOf @requiredProperties()
#      @prevalidateDeparture: ->
#        @validatePresenceOf @requiredProperties(), ['id']
#      setupChildren: ->
#        return if not @propertyTypes?
#        for cls of @propertyTypes



  @Ship = class Ship extends Model
      @requiredProperties: ['strength']

  @Pirate = class Pirate extends Ship
      @requiredProperties: ['color_str', 'player_id']

  @Merchant = class Merchant extends Ship
      @requiredProperties: ['attackers']
      @propertyTypes:
        attackers: Pirate
      winner: ->
        return null if !@attackers? or @attackers.length < 1
        totals = {}
        for s in @attackers
          totals[s.player_id] = (totals[s.player_id]? or 0) + s.strength
        totals = totals # rubymine you suck
        scores = for p, s of totals
          player_id: p
          score: s
        scores = scores.sort (a,b) ->
          if a.score < b.score -1
          else if b.score < a.score 1
          else 0
        if scores.length == 1 or (scores.length > 1 and scores[0].score > scores[1].score)
          scores[0].player_id
        else
          null

  @Player = class Player extends Model
      @requiredProperties: ['user_id', 'name', 'merchants', 'hand']
      @propertyTypes:
        merchants: Merchant
      score: -> @finalScore or 0

  @Game = class Game extends Model
      @requiredProperties: -> _.union super, ['players', 'name', 'turn']
      @propertyTypes:
        players: Player
      winner: ->
        _.max @players, (p) -> p.score() # TODO: hook up the sub-functions!



{ id, log, qsa, on-tap } = require \../std

{ Pane } = require \../pane


PlayerView = (dom, q = dom~query-selector) ->

  q = dom~query-selector
  image  = q \img
  score  = q \.score

  update: -> score.text-content = it
  on-tap: -> on-tap dom, it
  populate: (combatant) ->
    log combatant.player
    image.src = combatant.player.image
    score.text-content = combatant.score



module.exports = new Pane '[data-view="match"]', (host) ->

  @callbacks.point   = id
  @callbacks.forfeit = id

  player-views = (qsa host, '[data-combat-player]').map PlayerView

  player-views.map (player, ix) ~>
    player.on-tap ~> @callbacks.point ix

  update = ({ scores }) ->
    player-views.map (player, ix) ->
      player.update scores[ix]


  @begin-new-match = ({ players }:match-state) ->

    log \BEGIN, match-state

    for view, ix in player-views
      view.populate players[ix]



  @on-point    = @register \point
  @on-complete = @register \complete
  @on-cancel   = @register \cancel

  @update = update



{ id, log, qsa, on-tap } = require \../std

{ Pane } = require \../pane

module.exports = new Pane '[data-view="match"]', (host) ->

  # TODO: Push this into the global persistable state
  scores = [ MAX_SCORE - 1, 0 ]

  player-view = (dom, q = dom~query-selector) ->
    q = dom~query-selector
    image  = q \img
    score  = q \.score

    update: -> score.text-content = it
    on-tap: -> on-tap dom, it
    populate: (player) ->
      image.src = player.image
      score.text-content = 0

  player-views = (qsa host, '[data-player-view]').map player-view

  player-views.map (player, ix) ->
    player.on-tap ->
      scores[ix] += 1
      player.update scores[ix]

      if scores[ix] >= MAX_SCORE
        log \done


  @begin-new-match = (players) ->
    State.panes.match.players = players
    State.panes.match.stage   = GAME_STAGE_IN_PROGRESS
    State.panes.match.scores  = [ 0, 0 ]
    for view, ix in player-views => view.populate players[ix]

  @on-match-complete = @register \complete
  @on-cancel         = @register \cancel



require \./config
require \./const

{ id, log, rand, max, qsa, int, on-tap, contains, to-array } = require \./std
{ initial-state, persist-state, get-all-players } = require \./persist

{ generate-stats } = require \./stats

{ Pane } = require \./pane


# Data model

new-player = ({ name, image }) ->
  { name, image, id: next-available-player-id! }

get-player-from-id = (pid) ->
  State.records.players[pid]

next-available-player-id = ->
  1 + State.players.reduce (-> max &0, &1.id), 0

match-player = ({ id }, x) --> x.id is id

including-player = (player) -> (game) ->
  game.player-a.id is player.id or game.player-b.id is player.id

most-recent = (a, b) ->
 if a.time > b.time then a else b

derive-player-ranking = (players, games) ->
  rankings = [ player.id for player in players ]
  ranking-of = rankings~index-of

  for { winner-id, loser-id }, i in games
    if (ranking-of winner-id) > (ranking-of loser-id)
      [ loser ] = rankings.splice (ranking-of winner-id), 1
      rankings.splice (ranking-of loser-id), 0, loser

  return rankings

new-game-state = ->
  stage: GAME_STAGE_BRAND_NEW
  player-a: { info: NO_PLAYER_SELECTED, score: 0 }
  player-b: { info: NO_PLAYER_SELECTED, score: 0 }


# Media


# Renderers

render-player-ranking = (player-id, ix) ->
  player = get-player-from-id player-id
  """<img src="#{player.image}"><span>#{player.name}</span>"""

render-stats-row = ({ player, wins, total, ratio, score }) ->
  """<tr>
      <td><img src="#{player.image}">#{player.name}</td>
      <td>#wins</td>
      <td>#ratio</td>
      <td>#total</td>
      <td>#score</td>
    </tr>
  """


# Init

Leaderboard = new Pane '[data-view="ranking"]', ->
  for event, action of @actions
    @callbacks[event] = id
    action.on-action this~enqueue event

  @on-start-match = @register \startGame
  @on-add-player  = @register \addPlayer


PlayerSelect = new Pane '[data-view="player-select"]', (host) ->

  @dom.choices = host.query-selector '[data-player-choices]'
  @dom.buttons = []

  @state.selected-players = []

  select-player = (player-id) ~> ~>
    if @state.selected-players `contains` player-id
      @state.selected-players .= filter (isnt player-id)
    else if @state.selected-players.length >= 2
      console.warn "Can't select more than two, obviously"
    else
      @state.selected-players.push player-id

    @actions.ready.el.disabled = @state.selected-players.length < 2

    mark-selected-players @state.selected-players

  mark-selected-players = (player-ids) ~>
    @dom.buttons.map ->
      switch player-ids.index-of int it.dataset.player
      | 0 => it.dataset.selection = "first"
      | 1 => it.dataset.selection = "second"
      | _ => it.dataset.selection = ""; it.disabled = player-ids.length >= 2

  ready = ~>
    @dispatch \select, @state.selected-players
    @state.selected-players = []

  @callbacks.select = id

  @actions.ready.on-action ready

  @on-players-selected = @register \select
  @on-cancel           = @register \cancel

  @populate-choices = (players) ->
    @dom.choices.innerHTML = ""
    for player in players
      button = document.create-element \button
      button.dataset.player = player.id
      button.innerHTML = "<img src='#{player.image}'> #{player.name}"
      @dom.choices.append-child button
      on-tap button, select-player player.id
    @dom.buttons = to-array @dom.choices.children


MatchProgress = new Pane '[data-view="match"]', (host) ->

  player-view = (dom, q = dom~query-selector) ->
    q = dom~query-selector
    name   = q \.name
    image  = q \img
    score  = q \.score
    button = q \button

    populate: (player) ->
      name.text-content = player.name
      image.src = player.image
      score.text-content = '0'
      button.text-content = "+1"

  player-views = (qsa host, '[data-player-view]').map player-view

  @begin-new-match = (players) ->
    State.panes.match.players = players
    State.panes.match.stage   = GAME_STAGE_IN_PROGRESS
    State.panes.match.scores  = [ 0, 0 ]
    for view, ix in player-views => view.populate players[ix]


PlayerStats = new Pane '[data-view="stats"]', (host) ->


AddPlayer   = new Pane '[data-view="add-player"]', (host) ->


set-metastate = (metastate, options) ->

  State.current-pane.conceal!

  switch metastate
  | META_STATE_PLAYER_SELECT =>
    PlayerSelect.reveal!
    PlayerSelect.populate-choices get-all-players!
  | META_STATE_LEADERBOARD =>
    Leaderboard.reveal!
    Leaderboard.update-ranking State
  | META_STATE_GAME_IN_PROGRESS =>
    MatchProgress.reveal!
    MatchProgress.begin-new-match options
  | META_STATE_STATS =>
    PlayerStats.reveal!
    PlayerStats.populate-stats State.players, State.games
  | otherwise =>
    return console.error "Unknown metagamestate: ", metastate

  State.metastate = metastate


Leaderboard.on-start-match ->
  set-metastate META_STATE_PLAYER_SELECT

PlayerSelect.on-players-selected (player-ids) ->
  State.panes.match.players = player-ids.map get-player-from-id
  set-metastate META_STATE_GAME_IN_PROGRESS, player-ids.map get-player-from-id

PlayerSelect.on-cancel ->
  log \bail



# Init

global.State = initial-state current-pane: PlayerSelect
#console.table State.records.players
#console.table State.records.games

PlayerSelect.populate-choices State.records.players

#MatchProgress.begin-new-match [ State.records.players.0, State.records.players.1 ]
State.current-pane.reveal!



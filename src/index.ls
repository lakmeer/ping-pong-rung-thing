
require \./config
require \./const

{ id, log, rand, max, qsa, int, on-tap, contains, to-array } = require \./std
{ initial-state, persist-state, get-all-players, get-player-from-id } = require \./persist

{ generate-stats } = require \./stats

{ Pane } = require \./pane


# Data model

new-player = ({ name, image }) ->
  { name, image, id: next-available-player-id! }

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

Leaderboard   = require \./panes/leaderboard
PlayerSelect  = require \./panes/player-select
PlayerStats   = require \./panes/stats
MatchProgress = require \./panes/match-progress
AddPlayer     = require \./panes/add-player


set-metastate = (metastate, options) ->

  State.current-pane.conceal!

  switch metastate
  | META_STATE_LEADERBOARD =>
    Leaderboard.update-ranking State
    Leaderboard.reveal!

  | META_STATE_PLAYER_SELECT =>
    PlayerSelect.populate-choices get-all-players!
    PlayerSelect.reveal!

  | META_STATE_GAME_IN_PROGRESS =>
    MatchProgress.begin-new-match options
    MatchProgress.reveal!

  | META_STATE_STATS =>
    PlayerStats.populate-stats State.players, State.games
    PlayerStats.reveal!

  | META_STATE_ADD_PLAYER =>
    AddPlayer.begin!
    AddPlayer.reveal!

  | otherwise =>
    return console.error "Unknown metagamestate: ", metastate

  State.metastate = metastate



# Wire everything together

Leaderboard.on-start-match -> set-metastate META_STATE_PLAYER_SELECT
Leaderboard.on-show-stats  -> set-metastate META_STATE_STATS
Leaderboard.on-add-player  -> set-metastate META_STATE_ADD_PLAYER

PlayerSelect.on-selection -> set-metastate META_STATE_GAME_IN_PROGRESS, it.map get-player-from-id
PlayerSelect.on-cancel    -> log \bail

MatchProgress.on-match-complete -> log \complete, it
MatchProgress.on-cancel         -> log \bail

PlayerStats.on-start-match   -> set-metastate META_STATE_PLAYER_SELECT
PlayerStats.on-add-player    -> set-metastate META_STATE_ADD_PLAYER
PlayerStats.on-show-rankings -> set-metastate META_STATE_LEADERBOARD

AddPlayer.on-complete -> log \complete
AddPlayer.on-cancel   -> log \cancel


# Init

global.State = initial-state current-pane: AddPlayer
#console.table State.records.players
#console.table State.records.games

#Leaderboard.update-ranking derive-player-ranking State.records.players, State.records.games
#MatchProgress.begin-new-match [ State.records.players.0, State.records.players.1 ]
AddPlayer.begin!

State.current-pane.reveal!


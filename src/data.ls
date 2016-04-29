
{ id, log, max, contains } = require \./std

{ Persist } = require \./persist

MockData = require \./mock-data


# Canonical Data Structure

DATA =
  if DEBUG_USE_MOCK_DATA
    current-pane: conceal: id
    metastate: META_STATE_LEADERBOARD

    panes:
      stats: { last-stats: [] }
      match: { stage: null, players: [] }
      ranking: { last-ranking: [] }
      player: {}
      select: { selection: [] }

    records:
      games:   MockData.games
      players: MockData.players

  else
    current-pane: conceal: id
    metastate: META_STATE_LEADERBOARD

    panes:
      stats: { last-stats: [] }
      match: { stage: null, players: [] }
      ranking: { last-ranking: [] }
      player: {}
      select: { selection: [] }

    records:
      games:   []
      players: []

PLAYERS = DATA.records.players
GAMES   = DATA.records.games


# Data processing functions

derive-player-ranking = ->
  rankings = [ player.id for player in PLAYERS ]
  ranking-of = rankings~index-of . (.id)

  for { winner, loser }, i in GAMES
    if (ranking-of winner) > (ranking-of loser)
      [ x ] = rankings.splice (ranking-of winner), 1
      rankings.splice (ranking-of loser), 0, x

  return rankings.map get-player-from-id

new-player = ({ name, image }) ->
  { name, image, id: next-available-player-id! }

match-player = ({ id }, x) --> x.id is id

including-player = (player) -> (game) ->
  game.player-a.id is player.id or game.player-b.id is player.id

most-recent = (a, b) ->
 if a.time > b.time then a else b

get-player-from-id = (pid) ->
  DATA.records.players[pid]

select-player = (pid) ->
  { selection } = DATA.panes.select

  if selection `contains` pid
    DATA.panes.select.selection .= filter (isnt pid)
  else if selection.length >= 2
    console.warn "Can't select more than two, obviously"
  else
    selection.push pid


# Interface

module.exports =

  # Meta
  get-pane-state: (pane) -> DATA.panes[pane]
  set-metastate:    -> DATA.metastate = it
  set-current-pane: -> DATA.current-pane = it
  get-current-pane: -> DATA.current-pane

  # Records
  get-player-list: -> PLAYERS
  next-available-player-id: -> 1 + DATA.players.reduce (-> max &0, &1.id), 0

  # Leaderboard
  get-player-rankings: -> derive-player-ranking DATA.records.players, DATA.records.games

  # Player Select
  select-player: -> select-player it
  get-player-selection: -> DATA.panes.select.selection.map get-player-from-id
  clear-player-selection: -> DATA.panes.select.selection = []

  # Match Progress
  prepare-match-state: (players) ->
    DATA.panes.match.players = players.map ({ id }) -> { id, score: 0 }
    DATA.panes.match.stage = GAME_STAGE_IN_PROGRESS




{ id, log, max, len, sigfig, contains } = require \./std

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

group-by = (λ, list) ->
  res = {}
  list.map (x) -> res[][λ x].push x
  return res

sum-score = (player-key, games) -->
  if games?
    games.reduce (-> &0 + &1[player-key].score), 0
  else
    0

generate-stats = (players, games) ->
  games-by-winner = group-by (.winner.id), games
  games-by-loser  = group-by (.loser.id), games

  for player in players
    win-points  = sum-score \winner, games-by-winner[player.id]
    lose-points = sum-score \loser,  games-by-loser[player.id]

    player: player
    wins:  wins = len games-by-winner[player.id]
    total: total = wins + len games-by-loser[player.id]
    ratio: if total then sigfig 3, wins / total else 0
    score: win-points + lose-points

index = (ix, list) --> list[ix]

generate-hero = (player-id) ->
  player = get-player-from-id player-id

  player: player
  rank:   derive-player-ranking PLAYERS |> (.index-of player) |> (+ 1)
  stats:  generate-stats PLAYERS, GAMES |> (index player-id)


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
  gen-hero-stats: -> generate-hero it
  get-player-selection: -> DATA.panes.select.selection.map generate-hero
  clear-player-selection: -> DATA.panes.select.selection = []

  # Match Progress
  prepare-match-state: (selection) ->
    DATA.panes.match.players = selection.map -> { player: it.player, score: 0 }
    DATA.panes.match.stage = GAME_STAGE_IN_PROGRESS

  # Players Stats
  get-player-stats: ->
    generate-stats PLAYERS, GAMES


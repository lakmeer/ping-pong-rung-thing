
{ id, log, rand } = require \./std

blank-dataset = ({ current-pane }) ->
  current-pane: current-pane
  metastate: META_STATE_LEADERBOARD

  panes:
    stats: {}
    match: { stage: GAME_STAGE_NO_GAME, players: [] }
    ranking: { ranking: [] }
    add-player: {}
    select-player: {}

  records:
    games:   if DEBUG_REGEN_GAMES   then gen-mock-games!   else []
    players: if DEBUG_REGEN_PLAYERS then gen-mock-players! else []


gen-mock-players = ->
  players =
    * id: 0,  name: \Arya,      image: \/images/arya.jpeg
    * id: 1,  name: \Brienne,   image: \/images/brienne.jpeg
    * id: 2,  name: \Cersei,    image: \/images/cersei.jpeg
    * id: 3,  name: \Daenerys,  image: \/images/daenerys.jpeg

gen-mock-games = ->
  games =
    for i from 0 to 20
      new-game { id: (rand 0, 2), score: MAX_SCORE },
               { id: (rand 0, 2), score: (rand 0, MAX_SCORE - 1) }
  games.filter valid-game

valid-game = (game) ->
  game.winner-id isnt game.loser-id

new-game = (a, b) ->
  { winner, loser } = find-outcome a, b
  time:      Date.now!
  winner-id: winner.id
  loser-id:  loser.id
  loser-score: loser.score

find-outcome = (a, b) ->
  if a.score > b.score then winner: a, loser: b else winner: b, loser: a


export initial-state = (config) ->
  if local-storage.get-item STORAGE_KEY
    JSON.parse that
  else
    blank-dataset config

export persist-state = ->
  local-storage.set-item STORAGE_KEY, JSON.stringify it

export hydrate-state = ->
  JSON.parse local-storage.get-item STORAGE_KEY

export get-all-players = ->
  State.records.players


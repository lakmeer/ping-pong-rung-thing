
{ id, log, len, sigfig } = require \./std

group-by = (λ, list) ->
  res = {}
  list.map (x) -> res[][λ x].push x
  return res

sum-losers-score = (games) ->
  if games?
    games.reduce (-> &0 + &1.loser-score), 0
  else
    0


export generate-stats = ({ players, games }) ->

  games-by-winner = group-by (.winner-id), games
  games-by-loser  = group-by (.loser-id), games

  for player in players
    player: player
    wins:  wins = len games-by-winner[player.id]
    total: total = wins + len games-by-loser[player.id]
    ratio: if total then sigfig 3, wins / total else 0
    score: wins * MAX_SCORE + sum-losers-score games-by-loser[player.id]


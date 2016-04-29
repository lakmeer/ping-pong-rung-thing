
{ id, log, len, sigfig } = require \./std

{ Pane } = require \../pane

group-by = (λ, list) ->
  res = {}
  list.map (x) -> res[][λ x].push x
  return res

sum-losers-score = (games) ->
  if games?
    games.reduce (-> &0 + &1.loser.score), 0
  else
    0

render-stats-row = ({ player, wins, total, ratio, score }) ->
  """<tr>
      <td><img src="#{player.image}">#{player.name}</td>
      <td>#wins</td>
      <td>#ratio</td>
      <td>#total</td>
      <td>#score</td>
    </tr>
  """


module.exports = new Pane '[data-view="stats"]', (host) ->

  # TODO: This is wrong now that players can score > MAX_SCORE
  generate-stats = ({ players, games }) ->
    games-by-winner = group-by (.winner-id), games
    games-by-loser  = group-by (.loser-id), games

    for player in players
      player: player
      wins:  wins = len games-by-winner[player.id]
      total: total = wins + len games-by-loser[player.id]
      ratio: if total then sigfig 3, wins / total else 0
      score: wins * MAX_SCORE + sum-losers-score games-by-loser[player.id]

  @on-start-match   = @register \startMatch
  @on-add-player    = @register \addPlayer
  @on-show-rankings = @register \showRankings


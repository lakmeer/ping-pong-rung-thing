
{ id, log, len, sigfig } = require \../std

{ Pane } = require \../pane


render-stats-row = ({ player, wins, total, ratio, score }) ->
  """<tr class="stats-row">
      <td><img src="#{player.image}">#{player.name}</td>
      <td>#wins</td>
      <td>#ratio</td>
      <td>#total</td>
      <td>#score</td>
    </tr>
  """


module.exports = new Pane '[data-view="stats"]', (host) ->

  table = host.query-selector '[data-stats-rows]'

  for event, action of @actions
    @callbacks[event] = id
    action.on-action this~enqueue event

  @on-start-match   = @register \startMatch
  @on-add-player    = @register \addPlayer
  @on-show-rankings = @register \showRanking

  @populate-stats = (rows) ->
    row-html = rows.map render-stats-row
    table.innerHTML = row-html.join ''


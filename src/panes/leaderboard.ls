
{ id, log, qsa } = require \../std

{ Pane } = require \../pane

render-player-ranking = (player, ix) ->
  """<div class="ranked-player"><img src="#{player.image}"><span>#{player.name}</span></div>"""

module.exports = new Pane '[data-view="ranking"]', (host) ->
  @dom.ranks = host.query-selector '[data-rankings]'

  for event, action of @actions
    @callbacks[event] = id
    action.on-action this~enqueue event

  @on-start-match = @register \startGame
  @on-add-player  = @register \addPlayer
  @on-show-stats  = @register \showStats

  @update-ranking = (rankings) ~>
    rank-html = rankings.map render-player-ranking
    @dom.ranks.innerHTML = rank-html.join ''


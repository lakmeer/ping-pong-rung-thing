
{ id, log } = require \../std

{ Pane } = require \../pane

module.exports = new Pane '[data-view="stats"]', (host) ->

  @on-start-match   = @register \startMatch
  @on-add-player    = @register \addPlayer
  @on-show-rankings = @register \showRankings


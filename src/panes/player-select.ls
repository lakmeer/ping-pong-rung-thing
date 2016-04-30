
{ id, log, delay, qsa, contains, int, on-tap, to-array, ordinal } = require \../std

{ Pane } = require \../pane

{ PlayerHero } = require \../player-hero


module.exports = new Pane '[data-view="player-select"]', (host) ->

  # Dom
  @dom.choices = host.query-selector '[data-player-choices]'
  @dom.buttons = []
  @dom.backdrop = host.query-selector '.backdrop'

  heroes = qsa host, \.player-hero .map PlayerHero

  # State
  @callbacks.select = id
  @callbacks.ready  = id

  # Helpers
  select-player = (player-id) ~> ~>
    @callbacks.select player-id

  mark-selected-players = (player-ids) ~>
    @dom.buttons.map ->
      switch player-ids.index-of int it.dataset.player
      | 0 => it.dataset.selection = "first"
      | 1 => it.dataset.selection = "second"
      | _ => it.dataset.selection = ""; it.disabled = player-ids.length >= 2

  update-backdrop = (heroes) ~>
    for ix from 0 to 1
      @dom.backdrop.class-list.toggle 'selected-' + (if ix => \b else \a), heroes[ix]?

  populate-hero-info = (hero-data) ->
    for ix from 0 to 1
      heroes[ix].update hero-data[ix]


  populate-choices = (players) ->
    @dom.choices.innerHTML = ""
    for player in players
      button = document.create-element \button
      button.dataset.player = player.id
      button.class-list.add \selectable-player
      button.innerHTML = "<img src='#{player.image}'>"
      @dom.choices.append-child button
      on-tap button, select-player player.id
    @dom.buttons = to-array @dom.choices.children

  update-view = (selection) ->
    @actions.ready.el.disabled = selection.length < 2
    update-backdrop       selection
    mark-selected-players selection.map (.player.id)
    populate-hero-info    selection

  ready = ~>
    @dispatch \ready

  # Listeners
  @actions.ready.on-action ready
  @actions.cancel.on-action @dispatch \cancel

  # Interface
  @on-ready     = @register \ready
  @on-selection = @register \select
  @on-cancel    = @register \cancel
  @update-view  = update-view
  @populate-choices = populate-choices


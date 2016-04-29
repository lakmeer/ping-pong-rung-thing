
{ id, log, contains, int, on-tap, to-array } = require \../std

{ Pane } = require \../pane

module.exports = new Pane '[data-view="player-select"]', (host) ->

  @dom.choices = host.query-selector '[data-player-choices]'
  @dom.buttons = []

  @state.selected-players = []

  select-player = (player-id) ~> ~>
    if @state.selected-players `contains` player-id
      @state.selected-players .= filter (isnt player-id)
    else if @state.selected-players.length >= 2
      console.warn "Can't select more than two, obviously"
    else
      @state.selected-players.push player-id

    @actions.ready.el.disabled = @state.selected-players.length < 2

    mark-selected-players @state.selected-players

  mark-selected-players = (player-ids) ~>
    @dom.buttons.map ->
      switch player-ids.index-of int it.dataset.player
      | 0 => it.dataset.selection = "first"
      | 1 => it.dataset.selection = "second"
      | _ => it.dataset.selection = ""; it.disabled = player-ids.length >= 2

  ready = ~>
    @dispatch \select, @state.selected-players
    @state.selected-players = []

  @callbacks.select = id

  @actions.ready.on-action ready


  @populate-choices = (players) ->
    @dom.choices.innerHTML = ""
    for player in players
      button = document.create-element \button
      button.dataset.player = player.id
      button.class-list.add \selectable-player
      button.innerHTML = "<img src='#{player.image}'>"
      @dom.choices.append-child button
      on-tap button, select-player player.id
    @dom.buttons = to-array @dom.choices.children

  @on-selection = @register \select
  @on-cancel    = @register \cancel



{ id, log, find-dom, on-tap, qsa } = require \./std


action-buttons = (subdom) ->
  button-info = (qsa subdom, '[data-action]').map (button) ->
    el: button
    action: button.dataset.action
    on-action: -> on-tap button, it

  { [ info.action, info ] for info in button-info }


export class Pane

  (selector, init) ->
    @dom = main: find-dom selector
    @state = {}
    @callbacks = {}
    @actions = action-buttons @dom.main
    init.call this, @dom.main
    @conceal!

  use: (state) ->
    @state = state

  register: (event, λ) ~~>
    @callbacks[event] = λ

  dispatch: (event, ...args) ~>
    log \dispatch event
    @callbacks[event]?.apply null, args

  enqueue: (event, args = []) ~> ~>
    @callbacks[event]?.apply null, args

  reveal: ->
    @dom.main.style.opacity = 1

  conceal: ->
    @dom.main.style.opacity = 0.2


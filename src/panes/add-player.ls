
{ id, log, qsa, on-tap, delay } = require \../std

{ BigText } = require \../big-text
{ Camera }  = require \../camera
{ Pane }    = require \../pane


module.exports = new Pane '[data-view="add-player"]', (host) ->

  countdown-data = [ [ 2, "LOOK MEAN IN..." ] [ 1, "3" ] [ 1, "2" ] [ 1, "1" ] ]

  big-text = BigText host.query-selector '[data-big-text]'
  camera   = Camera  host.query-selector '[data-camera]'

  # Helpers

  countdown = (data, λ) ->
    elapsed = 0
    start = Date.now!
    for let [ t, text ], i in data
      delay elapsed, -> big-text.show text
      elapsed += t * 1000
    delay elapsed, λ

  take-photo = ->
    big-text.clear!
    camera.capture!
    image-data = camera.get-img!
    camera.stop!

  @on-complete = @register \complete
  @on-cancel   = @register \cancel

  @begin = -> camera.init!

  # Listeners
  camera.on-button -> countdown countdown-data, take-photo


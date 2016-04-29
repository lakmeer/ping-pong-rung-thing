
{ id, log, on-tap } = require \./std

get-user-media =
  if navigator.webkit-get-user-media?
    navigator~webkit-get-user-media
  else
    navigator~get-user-media

export Camera = (host, size = 1000) ->

  # Dom
  canvas = host.query-selector \canvas
  button = host.query-selector \button
  video  = host.query-selector \video

  # State
  state = stream: null

  # MediaStream Callbacks
  on-stream-available = (stream) ->
    state.stream = stream
    video.src = URL.create-object-URL stream
    video.play!

  on-media-fail = ->
    console.error "Can't get userMedia:", it

  # Helpers
  clear = ->
    ctx.clear-rect 0, 0 size, size

  # Init
  ctx = canvas.get-context \2d
  canvas.width = canvas.height = size

  # Listeners
  on-tap canvas, clear

  # Interface
  init:    -> get-user-media { video: true }, on-stream-available, on-media-fail
  clear:   -> clear!
  capture: -> ctx.draw-image video, 0, 0, size, size
  stop:    -> state.stream.get-video-tracks!map (.stop!)
  get-img: -> canvas.to-data-URL 'image/jpeg', 0.8
  on-button: -> on-tap button, it


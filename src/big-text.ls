
{ id, log, delay } = require \./std

const animation-class = \reveal

export BigText = (host) ->

  # Dom
  span = host.query-selector \span

  # Helpers
  show = (text) ->
    host.style.visibility = \hidden
    host.class-list.remove animation-class
    span.text-content = text
    <- delay 0
    host.style.visibility = \visible
    <- delay 0
    host.class-list.add animation-class

  # Interface
  show:  -> show it
  clear: -> host.style.visibility = \hidden



export id    = -> it

export log   = -> console.log.apply console, &; &0

export max   = Math.max
export floor = Math.floor
export round = Math.round

export rand  = (a, b) -> a + floor Math.random! * (b - a + 1)

export invoke = (args, λ) --> λ ...args

export len = -> if it? then that.length else 0

export sigfig = (α, n) -> (round n * 10^α) / 10^α

export to-array = -> [ x for x in it ]

export qsa = (scope, selector) --> to-array scope.query-selector-all selector

export int = parse-int _, 10

export find-dom = document~query-selector

export contains = (list, needle) -> (list.index-of needle) > -1

export on-tap = (el, λ) ->
  el.add-event-listener \click, λ
  el.add-event-listener \touchstart, λ

export clear = (host) ->
  host.innerHTML = ""
  return host

export into = (type, items) -->
  el = document.create-element type
  items.map el~append-child
  return el


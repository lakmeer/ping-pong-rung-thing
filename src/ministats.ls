
{ id, log, qsa } = require \./std

export MiniStats = (host) ->

  render-row = (key, value) -> """<tr><td>#key</td><td>#value</td></tr>"""

  rows = qsa host, \.stats-row

  update: ({ wins, total, ratio }) ->
    host.innerHTML =
      (render-row \Wins, wins) +
      (render-row \Games, total) +
      (render-row \Ratio, ratio)


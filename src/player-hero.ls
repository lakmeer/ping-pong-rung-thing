
{ id, log, delay, ordinal } = require \./std

{ MiniStats } = require \./ministats

$ = (host, selector) --> host.query-selector selector

NullHero = { player: id: -1 }

export PlayerHero = (host, ix) ->

  $$ = $ host

  image = $$ \img
  name  = $$ '[data-name]'
  badge = $$ '[data-rank-badge]'
  mini-stats = MiniStats $$ \.mini-stats

  hide-dir    = if ix then '120%' else '-120%'
  reveal-time = 0.5

  state = current-hero: NullHero

  clear = (t = reveal-time) ->
    TweenMax.to host, t, { x: hide-dir, ease: Power3.ease-out }
    state.current-hero = NullHero

  fill = ({ player }:hero) ->
    TweenMax.to host, reveal-time, { x: '0%', ease: Bounce.ease-out }
    mini-stats.update hero.stats
    name.text-content = player.name
    image.src = player.image
    badge.text-content = hero.rank + ordinal hero.rank
    badge.dataset.rank-badge = hero.rank
    state.current-hero = hero

  clear 0

  update: (hero) ->
    if not hero?
      clear!
    else if hero.player.id isnt state.current-hero.player.id
      if state.current-hero isnt NullHero
        clear!
        <- delay reveal-time
        fill hero
      else
        fill hero

    else
      log \no-change, ix


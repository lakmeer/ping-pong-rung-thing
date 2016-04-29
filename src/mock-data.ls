
export players =
  * id: 0,  name: \Arya,      image: \/images/arya.jpeg
  * id: 1,  name: \Brienne,   image: \/images/brienne.jpeg
  * id: 2,  name: \Cersei,    image: \/images/cersei.jpeg
  * id: 3,  name: \Daenerys,  image: \/images/daenerys.jpeg

export games =
  * time: 1461927234249, winner: { id: 1, score: 11 }, loser: { id: 0, score: 3 }
  * time: 1461927234250, winner: { id: 2, score: 11 }, loser: { id: 1, score: 7 }
  * time: 1461927234251, winner: { id: 0, score: 11 }, loser: { id: 1, score: 9 }
  * time: 1461927234252, winner: { id: 0, score: 11 }, loser: { id: 1, score: 9 }
  * time: 1461927234253, winner: { id: 2, score: 11 }, loser: { id: 0, score: 8 }
  * time: 1461927234254, winner: { id: 0, score: 11 }, loser: { id: 1, score: 9 }
  * time: 1461927234255, winner: { id: 0, score: 11 }, loser: { id: 1, score: 3 }
  * time: 1461927234256, winner: { id: 1, score: 11 }, loser: { id: 0, score: 9 }
  * time: 1461927234257, winner: { id: 0, score: 11 }, loser: { id: 1, score: 10 }
  * time: 1461927234258, winner: { id: 0, score: 11 }, loser: { id: 2, score: 6 }
  * time: 1461927234259, winner: { id: 0, score: 11 }, loser: { id: 1, score: 6 }
  * time: 1461927234260, winner: { id: 0, score: 11 }, loser: { id: 1, score: 7 }
  * time: 1461927234261, winner: { id: 2, score: 11 }, loser: { id: 0, score: 6 }

export random-games = (n) ->

  valid-game = (game) ->
    game.winner-id isnt game.loser-id

  find-outcome = (a, b) ->
    if a.score > b.score then winner: a, loser: b else winner: b, loser: a

  new-game = (a, b) ->
    { winner, loser } = find-outcome a, b
    { time: Date.now!, winner, loser }

  games = []

  while games.lenth < n
    game = new-game { id: (rand 0, 2), score: MAX_SCORE },
                    { id: (rand 0, 2), score: (rand 0, MAX_SCORE - 1) }
    games.push game if valid-game game



require \./config
require \./const

Data = require \./data

{ id, log, qsa } = require \./std

{ Pane } = require \./pane


# Init

Leaderboard   = require \./panes/leaderboard
PlayerSelect  = require \./panes/player-select
PlayerStats   = require \./panes/stats
MatchProgress = require \./panes/match-progress
AddPlayer     = require \./panes/add-player


# Wire everything together

Leaderboard.on-start-match ->
  PlayerSelect.populate-choices Data.get-player-list!
  show PlayerSelect

Leaderboard.on-show-stats  ->
  PlayerStats.populate-stats Data.get-player-stats!
  show PlayerStats

Leaderboard.on-add-player ->
  AddPlayer.begin!
  show AddPlayer


PlayerSelect.on-cancel go-home

PlayerSelect.on-ready ->
  Data.prepare-match-state Data.get-player-selection!
  Data.clear-player-selection!
  MatchProgress.begin-new-match Data.get-pane-state \match
  show MatchProgress

PlayerSelect.on-selection (pid) ->
  Data.select-player pid
  PlayerSelect.update-view Data.get-pane-state \select


MatchProgress.on-complete -> log \complete, it

MatchProgress.on-cancel go-home


PlayerStats.on-start-match ->
  PlayerSelect.populate-choices Data.get-player-list!
  show PlayerSelect

PlayerStats.on-add-player ->
  AddPlayer.begin!
  show AddPlayer

PlayerStats.on-show-rankings go-home


AddPlayer.on-complete -> log \complete

AddPlayer.on-cancel go-home


# Metacommon Transitions

show = (pane) ->
  Data.get-current-pane!conceal!
  Data.set-current-pane pane
  pane.reveal!

go-home = ->
  Leaderboard.update-ranking Data.get-player-rankings!
  show Leaderboard


# Init

#Data.select-player 0
#Data.select-player 1
#Data.prepare-match-state Data.get-player-selection!

Leaderboard.update-ranking Data.get-player-rankings!
show Leaderboard



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
  Data.gen-hero-stats pid
  PlayerSelect.update-view Data.get-player-selection!


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
  log \go-home
  Leaderboard.update-ranking Data.get-player-rankings!
  show Leaderboard


# Init

if not BYPASS_LEADERBOARD = no
  Leaderboard.update-ranking Data.get-player-rankings!
  show Leaderboard

if TESTING_PLAYER_SELECT = no
  Data.select-player 0
  Data.select-player 1
  PlayerSelect.populate-choices Data.get-player-list!
  PlayerSelect.update-view Data.get-player-selection!
  show PlayerSelect

if TESTING_MATCH
  Data.select-player 1
  Data.select-player 0
  Data.prepare-match-state Data.get-player-selection!
  MatchProgress.begin-new-match Data.get-pane-state \match
  show MatchProgress


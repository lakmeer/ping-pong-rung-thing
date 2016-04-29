
{ id, log, rand } = require \./std


export initial-state = (config) ->
  if local-storage.get-item STORAGE_KEY
    JSON.parse that
  else
    blank-dataset config

export persist-state = ->
  local-storage.set-item STORAGE_KEY, JSON.stringify it

export fetch-state = ->
  JSON.parse local-storage.get-item STORAGE_KEY



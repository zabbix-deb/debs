#!/usr/bin/env lua

local ssll = require('ssllabs')
local options = {
  host = arg[1],
  fromCache = true,
  maxAge = 36
}

if not options.host then os.exit(1) end

local function sleep(s)
  os.execute('sleep ', tonumber(s))
end

local function worst_state(result)
  local states = { 
    ['A+'] = 100, ['A-'] = 90, A = 80,
    B = 70, C = 60, D = 50, E = 40,
    F = 30, T = 20, M = 10
  }
  local state = 'A+'

  for i = 1, #result.endpoints do
    local s = result.endpoints[i].grade
    if states[s] < states[state] then
      state = s
    end
  end

  return state
end

local result = ssll.analyze(options)

if result.status == 'READY' then
  io.write(string.format('%s\n', worst_state(result)))
elseif result.status == 'ERROR' then
  io.write(string.format('%s\n', result.statusMessage))
  os.exit(0)
else
  io.write(string.format('%s\n', result.status))
  os.exit(0)
end
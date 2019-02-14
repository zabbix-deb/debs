#!/usr/bin/env lua

local ssll = require('ssllabs')
local sleep = require('socket').sleep

local DB_FILE = '/etc/zabbix/zabbix-check-ssllabs.db'


----
-- Helper functions
----
-- parses the two options or throws an error
local function _parse_opts(args)
  local opts = {
    update = false
  }

  if args[1] == '-u' then
    opts.update = true
  elseif args[1] == '-h' then
    assert(args[2], 'Missing argument for option -h')
    opts.host = args[2]
  else
    error('None, or wrong options or arguments given')
  end

  return opts
end

-- gives back the worst grade
local function _worst_grade(endpoints)
  local grades = {}

  for _, v in ipairs(endpoints) do
    table.insert(grades, v.grade)
  end

  table.sort(grades, function(a, b)
    return a:sub(1, 1) > b:sub(1, 1) or a:sub(1, 1) == b:sub(1, 1) and a:sub(2, 2) == '-'
  end)

  return grades[1]
end


----
-- Check class
----
local Check = {}

-- Constructor
function Check.new(db_path)
  local obj = {
    db_file = db_path or DB_FILE,
    checks = {}
  }

  setmetatable(obj, { __index = Check })

  obj:_read_database()

  return obj
end

-- returns grade if host is found database
-- if host is found, but has empty grade, it tries to get grade from the cached result (maxAge 48h) on ssllabs
-- if not found try to get the grade from the cached result on ssllabs (maxAge 48h) add it to the database and returns it
-- if there is no cached result on ssllabs, a new assessment gets started automatically. Cause an assessment takes long
-- it returns 'NA' and adds the host with an empty grade to the database
function Check:single(host)
  -- if host == '' update only the grade and don't write new line
  -- I guess we have to write the whole file every time to prevent this
  if not self.db[host] or self.db[host] == '' then
    local resp = ssll.from_cache(host, 46)

    if resp.status == 'READY' then
      local grade = _worst_grade(resp.endpoints)

      self.db[host] = grade
      self:_write_database()

      return grade
    elseif not resp or resp.status == 'ERROR' then
      self.db[host] = ''
      self:_write_database()

      return 'ERR'
    elseif resp.status ~= 'DNS' or resp.status ~= 'IN_PROGRESS' then
      self.db[host] = ''
      self:_write_database()

      return 'NA'
    end
  elseif self.db[host] then
    return self.db[host]
  end
end

-- renews the whole database, by starting a new assessment for every host in it
-- max 5 concurrent assessment are started
function Check:renew_grades()
  self:_generate_checks()

  local new_grades = {}

  while true do
    local noc = #self.checks

    local query = ( noc > 5 and 5 ) or noc

    if noc == 0 then break end

    for i = 1, query do
      local _, resp = coroutine.resume(self.checks[i])

      if resp.status ~= 'DNS' and resp.status ~= 'IN_PROGRESS' then
        new_grades[resp.host] = ( resp.status == 'READY' and _worst_grade(resp.endpoints) ) or 'ERR'

        table.remove(self.checks, i)

        break
      end
    end

    sleep(20)
  end

  self:_write_database(new_grades)
end

-- read the whole database and store it in instance variable db
function Check:_read_database()
  local fd = io.open(self.db_file, 'r')
  self.db = {}

  if not fd then return end

  for line in fd:lines() do
    line:gsub('(.*);([A-FTM]?[+-]?)', function(host, grade)
      self.db[host] = grade
    end)
  end

  fd:close()
end

-- write an completly new database file, by overwriting the old one
function Check:_write_database(grades)
  grades = grades or self.db
  local fd = assert(io.open(self.db_file, 'w'))

  for host, grade in pairs(grades) do
    assert(fd:write(host .. ';' .. grade .. '\n'))
  end

  fd:close()
end

-- generates threads for each host and save the to instance variable checks
-- checks is then used renew_grades()
function Check:_generate_checks()
  for host in pairs(self.db) do

    table.insert(self.checks, coroutine.create(function()
      local opts = { host = host, startNew = nil }
      local resp, err = ssll.analyze(opts)
      opts.startNew = nil

      while true do
        if not resp and err then return 'ERROR' end

        coroutine.yield(resp)

        resp, err = ssll.analyze(opts)
      end
    end))
  end
end

local function main(opts)
  local check = Check.new()

  if opts.update then
    check:renew_grades()
  elseif opts.host and opts.host ~= '' then
    print(check:single(opts.host))
  end
end

-- for tests
if _TEST then
  return {
    Check = Check,
    _worst_grade = _worst_grade,
    _parse_opts = _parse_opts
  }
end

local opts = _parse_opts(arg)

main(opts)
local DB_FILE = 'zabbix-check-ssllabs.db'
local zchk_ssllabs, check

describe("Test Zabbix externalcheck zabbix-check-ssllabs", function()
  setup(function()
    _G._TEST = true
    zchk_ssllabs = require('zabbix-check-ssllabs')
    check = zchk_ssllabs.Check.new(DB_FILE)
  end)

  teardown(function()
    _G._TEST = nil

    os.remove(DB_FILE)
  end)

  it('- returns worst grade', function()
    local worst = zchk_ssllabs._worst_grade({ { grade = 'A+' }, { grade = 'A-' }, { grade = 'B' } })
    local worst2 = zchk_ssllabs._worst_grade({ { grade = 'A+' }, { grade = 'A-' } })
    local expected = 'B'
    local expected2 = 'A-'

    assert.are.equals(expected, worst)
    assert.are.equals(expected2, worst2)
  end)

  it('- parse options', function()
    local p1 = zchk_ssllabs._parse_opts({ '-u' })
    local p2 = zchk_ssllabs._parse_opts({ '-h', 'example.com' })

    assert.is_true(p1.update)
    assert.is_false(p2.update)
    assert.are.equals('example.com', p2.host)
    assert.has_error(function() zchk_ssllabs._parse_opts({}) end)
  end)

  it('- db table in obj is empty, and db_file is set', function()
    assert.are.equals(#check.db, 0)
    assert.are.equals(DB_FILE, check.db_file)
  end)

  it('- write something to DB file', function()
    check:_write_database({ ['example.com'] = 'A+' })
    check:_read_database()

    local expected = { ['example.com'] = 'A+' }

    assert.are.same(expected, check.db)
  end)

  it('- should return grade if found in DB', function()
    assert.are.equals('A+', check:single('example.com'))
  end)

  it('- generate check coroutine for each host in DB', function()
      check:_generate_checks()

      assert.are.equals(1, #check.checks)
  end)
end)
--- Tests for the stack module
-- @license GNU GPL v2+
-- @author John Erling Blad < jeblad@gmail.com >

local testframework = require 'Module:TestFramework'

local cache = require 'templatedata/Cache'
assert( cache )

local function makeCache( opts, ... )
	local obj = cache.create( opts )
	for _,v in ipairs( {...} ) do
		obj:insert( unpack(v) )
	end
	return obj
end

local function testExists()
	return type( cache )
end

local function testCreate( opts )
	return type( makeCache( opts ) )
end

local function testIsEmpty( opts, ... )
	return makeCache( opts, ... ):isEmpty()
end

local function testDepth( opts, ... )
	return makeCache( opts, ... ):depth()
end

local function testIsMax( opts, ... )
	return makeCache( opts, ... ):isMax()
end

local function testTypes( opts, ... )
	local obj = cache.create( opts )
	local items = {}
	for _,v in ipairs( {...} ) do
		local method = table.remove( v, 1 )
		local types = {}
		for _,w in ipairs( { obj[method]( obj, unpack( v ) ):get( v[1] ) } ) do
			table.insert( types, type( w ) )
		end
		table.insert( items, types )
	end
	return items
end

local function testIsConsistent( opts, ... )
	local obj = cache.create( opts )
	for _,v in ipairs( {...} ) do
		local method = table.remove( v, 1 )
		obj[method]( obj, unpack( v ) )
	end
	return obj:isConsistent(), obj:depth()
end

local function FakeTime( opts )
	opts = opts or {}
	local self = {}
	local count = opts.count or 0
	function self.time()
		count = count + 1
		return count
	end
	function self.difftime( a, b )
		local diff = a - b
		return diff
	end
	return self
end

local function testIsValid( opts, key, ... )
	return makeCache( opts, ... ):isValid( key )
end

local function testGet( opts, key, ... )
	return makeCache( opts, ... ):get( key )
end

local func = function( ... ) return ... end

local function testCall( opts, key, ... )
	local obj = cache.create( opts )
	for _,v in ipairs( {...} ) do
		local k = table.remove( v, 1 )
		obj( k, func, unpack(v) )
	end
	return obj:get( key )
end

local tests = {
	{ -- #1
		name = 'cache lib exists',
		func = testExists,
		type = 'ToString',
		expect = { 'table' }
	},
	{ -- #2
		name = 'cache.create, no args',
		func = testCreate,
		type = 'ToString',
		args = {},
		expect = { 'table' }
	},
	{ -- #3
		name = 'cache.create, empty options',
		func = testCreate,
		type = 'ToString',
		args = { {} },
		expect = { 'table' }
	},
	{ -- #4
		name = 'cache:isEmpty, empty options, no cached values',
		func = testIsEmpty,
		args = { {} },
		expect = { true }
	},
	{ -- #5
		name = 'cache:isEmpty, empty options, one cached value',
		func = testIsEmpty,
		args = { {},
			{ 'foo', 'ping' }
		},
		expect = { false }
	},
	{ -- #6
		name = 'cache:isEmpty, empty options, two cached values',
		func = testIsEmpty,
		args = { {},
			{ 'foo', 'ping' },
			{ 'bar', 'pong' }
		},
		expect = { false }
	},
	{ -- #7
		name = 'cache:depth, empty options, no cached values',
		func = testDepth,
		args = { {} },
		expect = { 0 }
	},
	{ -- #8
		name = 'cache:depth, empty options, one cached value',
		func = testDepth,
		args = { {},
			{ 'foo', 'ping' }
		},
		expect = { 1 }
	},
	{ -- #9
		name = 'cache:depth, empty options, two cached values',
		func = testDepth,
		args = { {},
			{ 'foo', 'ping' },
			{ 'bar', 'pong' }
		},
		expect = { 2 }
	},
	{ -- #10
		name = 'cache:isMax, options has size=1, no cached values',
		func = testIsMax,
		args = { { size = 1 } },
		expect = { false }
	},
	{ -- #11
		name = 'cache:isMax, options has size=1, one cached value',
		func = testIsMax,
		args = { { size = 1 },
			{ 'foo', 'ping' }
		},
		expect = { false }
	},
	{ -- #12
		name = 'cache:isMax, options has size=1, two cached values',
		func = testIsMax,
		args = { { size = 1 },
			{ 'foo', 'ping' },
			{ 'bar', 'pong' }
		},
		expect = { true }
	},
	{ -- #13
		name = 'cache:insert, empty options, no cached values',
		func =  testTypes,
		args = { {} },
		expect = { {} }

	},
	{ -- #14
		name = 'cache:insert, empty options, one cached value',
		func =  testTypes,
		args = { {},
			{ 'insert', 'foo', 'ping' }
		},
		expect = { {
			{ 'string' }
		} }
	},
	{ -- #15
		name = 'cache:insert, empty options, insert-remove cached value',
		func =  testTypes,
		args = { {},
			{ 'insert', 'foo', 'ping' },
			{ 'remove', 'foo' }
		},
		expect = { {
			{ 'string' },
			{}
		} }

	},
	{ -- #16
		name = 'cache:insert, empty options, insert-remove cached value',
		func =  testTypes,
		args = { {},
			{ 'insert', 'foo', 'ping' },
			{ 'insert', 'bar', 'pong', 42 },
			{ 'insert', 'baz', 'zong', 42, 'mong' },
			{ 'remove', 'foo' },
			{ 'insert', 'foo', 42, 'ming' }
		},
		expect = { {
			{ 'string' },
			{ 'string', 'number' },
			{ 'string', 'number', 'string' },
			{},
			{ 'number', 'string' }
		} }

	},
	{ -- #17
		name = 'cache:isConsistent, empty options, no cached values',
		func = testIsConsistent,
		args = { {} },
		expect = { true, 0 }
	},
	{ -- #18
		name = 'cache:isConsistent, empty options, one cached value',
		func = testIsConsistent,
		args = { {},
			{ 'insert', 'foo', 'ping' }
		},
		expect = { true, 1 }
	},
	{ -- #19
		name = 'cache:isConsistent, empty options, two cached values',
		func =  testIsConsistent,
		args = { {},
			{ 'insert', 'foo', 'ping' },
			{ 'insert', 'bar', 'pong' }
		},
		expect = { true, 2 }
	},
	{ -- #20
		name = 'cache:isConsistent, empty options, three cached values, one removed',
		func =  testIsConsistent,
		args = { {},
			{ 'insert', 'foo', 'ping' },
			{ 'insert', 'bar', 'pong' },
			{ 'remove', 'bar' }
		},
		expect = { true, 1 }
	},
	{ -- #21
		name = 'cache:isConsistent, empty options, various cache operations',
		func =  testIsConsistent,
		args = { {},
			{ 'insert', 'foo', 'ping' },
			{ 'insert', 'bar', 'pong' },
			{ 'insert', 'baz', 'zong' },
			{ 'remove', 'foo' },
			{ 'insert', 'foo', 'zing' }
		},
		expect = { true, 3 }
	},
	{ -- #22
		name = 'cache:isValid, options has os=FakeTime, non-existing key, no cached values',
		func = testIsValid,
		args = { { os = FakeTime(), time = 10 }, 'baz' },
		expect = { false }
	},
	{ -- #23
		name = 'cache:isValid, options has os=FakeTime, non-existing key, two cached values',
		func = testIsValid,
		args = { { os = FakeTime(), time = 10 }, 'baz',
			{ 'insert', 'foo', 'ping' },
			{ 'insert', 'bar', 'pong' }
		},
		expect = { false }
	},
	{ -- #24
		name = 'cache:isValid, options has os=FakeTime, existing key, two cached values',
		func = testIsValid,
		args = { { os = FakeTime(), time = 10 }, 'foo',
			{ 'insert', 'foo', 'ping' },
			{ 'insert', 'bar', 'pong' }
		},
		expect = { false }
	},
	{ -- #25
		name = 'cache:isValid, options has os=FakeTime, existing key, two cached values',
		func = testIsValid,
		args = { { os = FakeTime(), time = 0 }, 'foo',
			{ 'insert', 'foo', 'ping' },
			{ 'insert', 'bar', 'pong' }
		},
		expect = { false }
	},
	{ -- #26
		name = 'cache:get, options has os=FakeTime, non-existing key, no cached values',
		func = testGet,
		args = { { os = FakeTime(), time = 10 }, 'baz' },
		expect = { nil }
	},
	{ -- #27
		name = 'cache:get, options has os=FakeTime, non-existing key, two cached values',
		func = testGet,
		args = { { os = FakeTime(), time = 10 }, 'baz',
			{ 'foo', 'ping' },
			{ 'bar', 'pong' }
		},
		expect = { nil }
	},
	{ -- #28
		name = 'cache:get, options has os=FakeTime, existing key, two cached values – to old, will be removed',
		func = testGet,
		args = { { os = FakeTime(), time = 2 }, 'foo',
			{ 'foo', 'ping' },
			{ 'bar', 'pong' },
			{ 'baz', 'zong' }
		},
		expect = { nil }
	},
	{ -- #29
		name = 'cache:get, options has os=FakeTime, existing key, two cached values – to old, will be removed',
		func = testGet,
		args = { { os = FakeTime(), time = 2 }, 'bar',
			{ 'foo', 'ping' },
			{ 'bar', 'pong' },
			{ 'baz', 'zong' }
		},
		expect = { nil }
	},
	{ -- #30
		name = 'cache:get, options has os=FakeTime, existing key, two cached values – new enough, will be kept',
		func = testGet,
		args = { { os = FakeTime(), time = 2 }, 'baz',
			{ 'foo', 'ping' },
			{ 'bar', 'pong' },
			{ 'baz', 'zong' }
		},
		expect = { 'zong' }
	},
	{ -- #31
		name = 'cache:__call, existing key, two cached values',
		func = testCall,
		args = { { os = FakeTime() }, 'foo',
			{ 'foo', 'ping' },
			{ 'bar', 'pong' }
		},
		expect = { 'ping' }
	},
}

return testframework.getTestProvider( tests )
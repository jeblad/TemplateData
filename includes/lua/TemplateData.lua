--- Access to the TemplateData extension, and management of provided data.
-- @module mw.templatedata

-- @var class var for lib
local TemplateData = {}
local php

local root = require 'templatedata/Root'

-- @var metatable for the library
local metatable = {}

--- Call on library.
-- @function mw.templatedata.__call
-- @usage local root = mw.templatedata( 'Template:Foo' )
-- @param ... varargs passed to @{templatedata.load}
-- @return Root instance holding TemplateData proxy
function metatable:__call( ... )
	return root.bless( self.load( ... ) )
end

setmetatable( TemplateData, metatable )

-- @var reused in load(), initialized in setupInterface()
local cache = nil

--- Create a read-only proxy for the loaded data
-- Wrapper borrowed from Scribuntos mw.lua. It creates the read-only dummy table
-- for accessing the real data. If (and when) the function in mw.lua is made public,
-- then this can be removed.
-- @param data table Data to access
-- @param seen table|nil Table of already-seen tables.
-- @return table
local function makeReadOnlyProxy( data, seen )
	local t = {}
	seen = seen or { [data] = t }

	local function pairsfunc( _, k )
		k = next( data, k )
		if k ~= nil then
			return k, t[k]
		end
		return nil
	end

	local function ipairsfunc( _, i )
		i = i + 1
		if data[i] ~= nil then
			return i, t[i]
		end
		return -- no nil to match default ipairs()
	end

	local mt = {
		mw_loadData = true,
		__index = function ( tt, k )
			assert( t == tt )
			local v = data[k]
			if type( v ) == 'table' then
				seen[v] = seen[v] or makeReadOnlyProxy( v, seen )
				return seen[v]
			end
			return v
		end,
		__newindex = function ()
			error( "table is read-only", 2 )
		end,
		__pairs = function ( tt )
			assert( t == tt )
			return pairsfunc, t, nil
		end,
		__ipairs = function ( tt )
			assert( t == tt )
			return ipairsfunc, t, 0
		end,
	}
	-- This is just to make setmetatable() fail
	mt.__metatable = mt

	return setmetatable( t, mt )
end

--- Load TemplateData from a page
-- @usage local tdata = mw.templatedata.load( 'Template:Foo' )
-- @function mw.templatedata.load
-- @param title string for lookup (optional)
-- @param langCode string for lookup and realization (optional)
-- @return read-only proxy for the TemplateData table
function TemplateData.load( title, langCode )
	local titleType = type( title )
	title = (titleType == 'string' and title)
		or (titleType == 'table' and title.prefixedText)
		or nil
	local langCodeType = type( langCode )
	langCode = (langCodeType == 'string' and langCode)
		or (langCodeType == 'table' and langCode:getCode())
		or nil

	local loadKey = (langCode or '')
		.. (langCode and title and '|' or '')
		.. (title or '')

	local loadFunc = function()
		local value, status = php.loadTemplateData( title, langCode )

		if value == nil then
			value = {}
		elseif type( value ) ~= 'table' then
			value = { value }
		end

		if status then
			value['status'] = status
		end

		return value
	end

	-- limit caching to a single value
	local t = cache( loadKey, loadFunc )
	return makeReadOnlyProxy( t )
end

--- install the module in the global space
-- @local interface specific
-- @param options passed on to the cache instance
function TemplateData.setupInterface( options ) -- luacheck: no unused args
	-- Boilerplate
	TemplateData.setupInterface = nil
	php = mw_interface
	mw_interface = nil

	-- Register this library in the "mw" global
	mw = mw or {}
	mw.templatedata = TemplateData

	local Cache = require 'templatedata/Cache'
	cache = Cache.create( options )

	package.loaded['mw.templatedata'] = TemplateData
end

return TemplateData

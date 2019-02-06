--- Root holding an blessed access to TemplateData proxy.
-- @classmod Root

-- @var class var for lib
local Root = {}

--- Lookup of missing class members.
-- @param key used for lookup of member
-- @return any
function Root:__index( key ) -- luacheck: no self
	return Root[key]
end

--- Bless an existing table into an instance.
-- @function Root.bless
-- @param tbl table to be blessed
-- @return self
function Root.bless( tbl )

	local self = setmetatable( {}, Root )

	self._blessed = tbl or {}

	if not self:isValid() then
		self._valid = true
		self._parameters = {} -- points into the blessed
		self._aliases = {} --points into the blessed
		self._values = {} --dangerous, must copy value

		-- initialize the aliases lookup structure
		do
			local params = self._blessed.params or {}
			for k,v in pairs(params or {}) do
				for i,w in ipairs((params[k] or {}).aliases) do
					self._aliases[w] = k
				end
			end
		end
	end

	return self
end

--- Validate the assumptions.
-- The class makes some assumptions about the blessed reference.
-- @return boolean
function Root:isValid()
	if self._valid then
		return true
	end

	local types = {
		params = 'table',
		format = 'string',
		description = 'string',
		sets = 'table',
		maps = 'table',
		paramOrder = 'table'
	}

	for k,v in pairs( self._blessed ) do
		if types[k] then
			if type( types[k] ) == 'table' then
				if not types[k][type( v )] then
					return false
				end
			else
				if type( v ) ~= types[k] then
					return false
				end
			end
		end
	end

	if self._blessed.params then
		for _,v in pairs( self._blessed.params ) do
			if type( v ) ~= 'table' then
				return false
			end
		end
	end

	if self._blessed.paramOrder then
		for _,v in ipairs( self._blessed.paramOrder ) do
			if type( v ) ~= 'string' then
				return false
			end
		end
	end

	-- @todo needs refinement
	if self._blessed.sets then
		for _,v in ipairs( self._blessed.sets ) do
			if type( v ) ~= 'table' then
				return false
			end
		end
	end

	-- @todo needs refinement
	if self._blessed.maps then
		for _,v in ipairs( self._blessed.maps ) do
			if type( v ) ~= 'table' then
				return false
			end
		end
	end

	return true
end

--- Has ordered params.
--@return boolean
function Root:hasOrderedParams()
	return not not self._blessed.paramOrder
end

--- Has sets.
--@return boolean
function Root:hasSets()
	return not not self._blessed.sets
end

--- Has maps.
--@return boolean
function Root:hasMaps()
	return not not self._blessed.maps
end

--- Get names in order.
-- Order names according to param order.
-- @return list of names
function Root:getOrderedNames()
	local collected = {}

	for i,v in ipairs( self._blessed.paramOrder or {} ) do
		collected[i] = v
	end

	return unpack( collected )
end

--- Get all names.
-- All names, no particular order.
-- @return list of names
function Root:getAllNames()
	local collected = {}

	for k,_ in pairs( self._blessed.params or {} ) do
		table.insert( collected, k )
	end

	return unpack( collected )
end

--- Is completely ordered.
-- Checks if the param order is complete given the params.
-- All existing params must be ordered, but non-existing params
-- does not matter.
-- @return boolean
function Root:isCompletelyOrdered()
	local collected = {}

	for k,_ in pairs( self._blessed.params or {} ) do
		collected[k] = true
	end

	for _,k in ipairs( self._blessed.paramOrder or {} ) do
		collected[k] = nil
	end

	for k,v in pairs(collected) do
		if v then
			return false
		end
	end

	return true
end

--- Get names from sets.
-- This will not maintain any particular order.
-- @param ... of names
-- @return list of names
function Root:getNamesFromSets( ... )
	local collected = {}
	local sets = self._blessed.sets or {}

	for _,v in ipairs({...}) do
		local t = sets[v]
		if t then
			for _,w in ipairs(t) do
				collected[w] = true
			end
		end
	end

	local names = {}
	for k,_ in pairs( collected ) do
		table.insert( names, k )
	end

	return unpack( names )
end

-- Return the final class
return Root

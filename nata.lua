local nata = {
	_VERSION = 'nata',
	_DESCRIPTION = 'OOP and ECS entity management for LÖVE',
	_URL = 'https://github.com/tesselode/nata',
	_LICENSE = [[
		MIT License

		Copyright (c) 2017 Andrew Minnich

		Permission is hereby granted, free of charge, to any person obtaining a copy
		of this software and associated documentation files (the "Software"), to deal
		in the Software without restriction, including without limitation the rights
		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
		copies of the Software, and to permit persons to whom the Software is
		furnished to do so, subject to the following conditions:

		The above copyright notice and this permission notice shall be included in all
		copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
		SOFTWARE.
	]]
}

local function remove(t, v)
	for i = 1, #t do
		if t[i] == v then
			table.remove(t, i)
			return true
		end
	end
	return false
end

local Pool = {}

function Pool:add(entity, ...)
	for _, system in ipairs(self._systems) do
		if not system.filter or system.filter(entity) then
			table.insert(self._cache[system], entity)
			if system.sort then
				table.sort(self._cache[system], system.sort)
			end
			if system.add then system.add(entity, ...) end
		end
	end
	table.insert(self.entities, entity)
	return entity
end

function Pool:sort(system)
	if system then
		assert(system.sort, 'system does not have a sort function')
		table.sort(self._cache[system], system.sort)
	else
		for _, system in ipairs(self._systems) do
			if system.sort then
				table.sort(self._cache[system], system.sort)
			end
		end
	end
end

function Pool:callOn(entity, event, ...)
	for _, system in ipairs(self._systems) do
		if system[event] then
			if not system.filter or system.filter(entity) then
				system[event](entity, ...)
			end
		end
	end
end

function Pool:call(event, ...)
	for _, system in ipairs(self._systems) do
		if system[event] then
			for _, entity in ipairs(self._cache[system]) do
				system[event](entity, ...)
			end
		end
	end
end

function Pool:remove(f, ...)
	assert(f and type(f) == 'function', 'no function provided for pool.remove')
	for i = #self.entities, 1, -1 do
		local entity = self.entities[i]
		if f(entity) then
			for _, system in ipairs(self._systems) do
				if remove(self._cache[system], entity) then
					if system.remove then system.remove(entity, ...) end
				end
			end
			table.remove(self.entities, i)
		end
	end
end

function nata.oop(events, sort)
	local eventEnabled = {}
	if events then
		if type(events) == 'string' then
			eventEnabled[events] = true
		elseif type(events) == 'table' then
			for _, event in ipairs(events) do
				eventEnabled[event] = true
			end
		else
			assert 'events must be a string or table'
		end
	else
		setmetatable(eventEnabled, {
			__index = function(t, k)
				return true
			end
		})
	end
	return setmetatable({sort = sort,}, {
		__index = function(t, k)
			if k == 'filter' or k == 'sort' then
				return rawget(t, k)
			elseif eventEnabled[k] then
				return function(e, ...)
					if e[k] and type(e[k]) == 'function' then
						e[k](e, ...)
					end
				end
			end
		end
	})
end

function nata.new(systems)
	local pool = setmetatable({
		_systems = systems or {nata.oop()},
		entities = {},
		_cache = {},
	}, {__index = Pool})
	for _, system in ipairs(pool._systems) do
		pool._cache[system] = {}
	end
	return pool
end

return nata

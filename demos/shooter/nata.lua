--[[

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

local function remove(t, v)
	for i = 1, #t do
		if t[i] == v then
			table.remove(t, i)
			break
		end
	end
end

local Pool = {}

function Pool:add(entity, ...)
	for _, system in ipairs(self._systems) do
		system._entities = system._entities or {}
		local filter = system.filter or function()
			return true
		end
		if filter(entity) then
			table.insert(system._entities, entity)
		end
	end
	table.insert(self._entities, entity)
	self:callOn(entity, 'add', ...)
	return entity
end

function Pool:get(f)
	if f then
		local entities = {}
		for _, entity in pairs(self._entities) do
			if f(entity) then
				table.insert(entities, entity)
			end
		end
		return entities
	else
		return self._entities
	end
end

function Pool:callOn(entity, event, ...)
	for _, system in ipairs(self._systems) do
		if system[event] then
			system[event](entity, ...)
		end
	end
end

function Pool:call(event, ...)
	for _, system in ipairs(self._systems) do
		if system[event] then
			for _, entity in ipairs(system._entities) do
				system[event](entity, ...)
			end
		end
	end
end

function Pool:remove(f, ...)
	f = f or function() return true end
	for i = #self._entities, 1, -1 do
		local entity = self._entities[i]
		if f(entity) then
			self:callOn(entity, 'remove', ...)
			for _, system in ipairs(self._systems) do
				remove(system._entities, entity)
			end
			table.remove(self._entities, i)
		end
	end
end

return function(systems)
	local passthroughSystem = setmetatable({
		filter = function() return true end,
	}, {
		__index = function(self, k)
			if k == 'filter' or k == 'add' or k == '_entities' then
				return rawget(self, k)
			else
				return function(e, ...)
					if e[k] and type(e[k]) == 'function' then
						e[k](e, ...)
					end
				end
			end
		end
	})

	return setmetatable({
		_systems = systems or {passthroughSystem},
		_entities = {},
	}, {
		__index = Pool,
	})
end

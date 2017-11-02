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

local Pool = {}

function Pool:add(entity, ...)
	self:callOn(entity, 'add', ...)
	table.insert(self._entities, entity)
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
	if self.systems[event] then
		for _, system in ipairs(self.systems[event]) do
			system(entity, ...)
		end
	end
end

function Pool:call(event, ...)
	if self.systems[event] then
		for _, system in ipairs(self.systems[event]) do
			for _, entity in pairs(self._entities) do
				system(entity, ...)
			end
		end
	end
end

function Pool:remove(f)
	f = f or function() return true end
	for i = #self._entities, 1, -1 do
		local entity = self._entities[i]
		if f(entity) then
			self:callOn(entity, 'remove')
			table.remove(self._entities, i)
		end
	end
end

return function(systems)
	local defaultSystems = setmetatable({}, {
		__index = function(t, k)
			return {
				function(e, ...)
					if k == 'add' then
						return false
					end
					if e[k] and type(e[k]) == 'function' then
						e[k](e, ...)
					end
				end
			}
		end
	})

	return setmetatable({
		systems = systems or defaultSystems,
		_entities = {},
	}, {
		__index = Pool,
	})
end

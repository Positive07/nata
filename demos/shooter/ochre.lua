local World = setmetatable({}, {
	__index = function(self, k)
		return rawget(self, k) or function(self, ...)
			self:callAll(k, ...)
		end
	end
})

function World:add(entity, ...)
	self:call(entity, 'add', ...)
	table.insert(self._entities, entity)
	return entity
end

function World:get(f)
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

function World:call(entity, event, ...)
	if self.systems[event] then
		for _, system in ipairs(self.systems[event]) do
			system(entity, ...)
		end
	end
end

function World:callAll(event, ...)
	if self.systems[event] then
		for _, system in ipairs(self.systems[event]) do
			for _, entity in pairs(self._entities) do
				system(entity, ...)
			end
		end
	end
end

function World:remove(f)
	f = f or function() return true end
	for i = #self._entities, 1, -1 do
		local entity = self._entities[i]
		if f(entity) then
			self:call(entity, 'remove')
			table.remove(self._entities, i)
		end
	end
end

return function(systems)
	local defaultSystems = setmetatable({}, {
		__index = function(t, k)
			return {
				function(e, ...)
					if e[k] then e[k](e, ...) end
				end
			}
		end
	})

	return setmetatable({
		systems = systems or defaultSystems,
		_entities = {},
	}, {
		__index = World,
	})
end
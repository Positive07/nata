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

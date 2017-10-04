local ochre = {}

local World = {}

-- user-definable functions

function World:onAdd(entity, ...) end
function World:onRemove(entity) end

-- main API

function World:add(entity, ...)
	self:onAdd(entity, ...)
	for _, system in pairs(self.systems.onAdd or {}) do
		system(self, entity, ...)
	end
	table.insert(self._entities, entity)
	return entity
end

function World:get(f)
	f = f or function() return true end
	local entities = {}
	for _, entity in pairs(self._entities) do
		if f(entity) then
			table.insert(entities, entity)
		end
	end
	return entities
end

function World:call(event, ...)
	for _, entity in pairs(self._entities) do
		for _, system in pairs(self.systems[event] or {}) do
			system(self, entity, ...)
		end
		if entity[event] then
			entity[event](entity, ...)
		end
	end
end

function World:remove(f)
	f = f or function() return true end
	for i = #self._entities, 1, -1 do
		if f(self._entities[i]) then
			self:onRemove(self._entities[i])
			for _, system in pairs(self.systems.onRemove or {}) do
				system(self, self._entities[i])
			end
			table.remove(self._entities, i)
		end
	end
end

function ochre.new()
	return setmetatable({
		systems = {},
		_entities = {},
	}, {
		__index = World,
	})
end

return ochre
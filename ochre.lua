local ochre = {}

local World = {}

-- user-definable functions

function World:onAdd(entity, ...) end
function World:onRemove(entity) end

-- main API

function World:add(entity, ...)
	if self.systems.onAdd then
		for i = 1, #self.systems.onAdd do
			self.systems.onAdd[i](self, entity, ...)
		end
	end
	self:onAdd(entity, ...)
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
		if self.systems[event] then
			for i = 1, #self.systems[event] do
				self.systems[event][i](self, entity, ...)
			end
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
			if self.systems.onRemove then
				for i = 1, #self.systems.onRemove do
					self.systems.onRemove[i](self, entity)
				end
			end
			self:onRemove(self._entities[i])
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
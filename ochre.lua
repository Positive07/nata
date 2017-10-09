local ochre = {}

local World = setmetatable({}, {
	__index = function(self, k)
		return rawget(self, k) or function(self, ...)
			self:callAll(k, ...)
		end
	end
})

function World:add(entity, ...)
	self:call(entity, 'onAdd', ...)
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
			system(self.parent, entity, ...)
		end
	end
end

function World:callAll(event, ...)
	for _, entity in pairs(self._entities) do
		self:call(entity, event, ...)
	end
end

function World:remove(f)
	f = f or function() return true end
	for i = #self._entities, 1, -1 do
		local entity = self._entities[i]
		if f(entity) then
			self:call(entity, 'onRemove')
			table.remove(self._entities, i)
		end
	end
end

function ochre.new(systems)
	return setmetatable({
		systems = systems or {},
		parent = self,
		_entities = {},
	}, {
		__index = World,
	})
end

ochre.systems = {
	simple = {
		update = {
			function(w, e, dt)
				if e.update then e:update(dt) end
			end
		},
		draw = {
			function(w, e)
				if e.draw then e:draw() end
			end
		},
		onRemove = {
			function(w, e)
				if e.onRemove then e:onRemove() end
			end
		},
	}
}

return ochre
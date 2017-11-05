local nata = {}

local Pool = {}

function Pool:add(entity, ...)
    for i = 1, #self._systems do
        local system = self._systems[i]
        local filter = system.filter or function()
            return true
        end
        if system.add and filter(entity) then
            system.add(entity, ...)
        end
    end
    table.insert(self._entities, entity)
    return entity
end

function Pool:remove(f, ...)
    f = f or function() return true end
    for i = #self._entities, 1, -1 do
        local entity = self._entities[i]
        if f(entity) then
            for j = 1, #self._systems do
                local system = self._systems[j]
                local filter = system.filter or function()
                    return true
                end
                if system.remove and filter(entity) then
                    system.remove(entity, ...)
                end
            end
            table.remove(self._entities, i)
        end
    end
end

function Pool:get(f)
    if f then
        local entities = {}
        for i = 1, #self._entities do
            local entity = #self._entities[i]
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
    for i = 1, #self._systems do
        local system = self._systems[i]
        local filter = system.filter or function()
            return true
        end
        if system[event] and filter(entity) then
            system[event](entity, ...)
        end
    end
end

function Pool:call(event, ...)
    for i = 1, #self._systems do
        local system = self._systems[i]
        if system[event] then
            for j = 1, #self._entities do
                local entity = self._entities[j]
                local filter = system.filter or function()
                    return true
                end
                if filter(entity) then
                    system[event](entity, ...)
                end
            end
        end
    end
end

nata.oop = setmetatable({}, {
	__index = function(self, k)
		if k == 'filter' or k == 'add' then
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

function nata.new(systems)
    return setmetatable({
        _systems = systems or {nata.oop},
        _entities = {},
    }, {__index = Pool})
end

return nata
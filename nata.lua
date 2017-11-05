local nata = {}

local Pool = {}

function Pool:add(entity, ...)
    for i = 1, #self._systems do
        local system = self._systems[i]
        if system.add and system.filter(entity) then
            system.add(entity ...)
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
                if system.remove and system.filter(entity) then
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
        if system[event] and system.filter(entity) then
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
                if system.filter(entity) then
                    system[event](entity, ...)
                end
            end
        end
    end
end

function nata.new(systems)
    return setmetatable({
        _systems = systems or {},
        _entities = {},
    }, {__index = Pool})
end

return nata
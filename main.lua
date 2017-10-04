local ochre = require 'ochre'

function newSquare(x, y)
	return {
		x = x,
		y = y,
		update = function(self, dt)
			self.x = self.x + 100 * dt
			self.y = self.y + 200 * dt
		end,
		draw = function(self)
			love.graphics.rectangle('fill', self.x, self.y, 50, 50)
		end,
	}
end

local world = ochre.new()

function world:onAdd(entity, message)
	print('spawned entity: ' .. tostring(entity) .. ' (message: ' .. message .. ')')
end

function world:onRemove(entity)
	print('removed entity: ' .. tostring(entity))
end

world:add(newSquare(50, 50), 'hi')
world:add(newSquare(50, 250), 'hello')
world:add(newSquare(350, 100), 'nice day')
world:add(newSquare(650, 25), 'fuck off')

function love.update(dt)
	world:call('update', dt)
	world:remove(function(e) return e.delete end)
end

function love.keypressed(key)
	if key == 'space' then
		if #world:get() > 0 then
			local n = love.math.random(1, #world:get())
			world._entities[n].delete = true
		end
	end
	if key == 'escape' then
		love.event.quit()
	end
end

function love.draw()
	world:call 'draw'
	love.graphics.print(tostring(#world:get(function(e)
		return e.x > 400
	end)))
end
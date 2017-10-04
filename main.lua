local ochre = require 'ochre'

function newSquare(x, y)
	return {
		x = x,
		y = y,
		w = 50,
		h = 50,
		update = function(self, dt)
			self.x = self.x + 100 * dt
			self.y = self.y + 200 * dt
		end,
	}
end

local world = ochre.new()

world.systems.onAdd = {
	debug = function(w, e, m)
		print('spawned entity: ' .. tostring(e) .. ' (message: ' .. m .. ')')
	end
}

world.systems.onRemove = {
	debug = function(w, e)
		print('removed entity: ' .. tostring(e))
	end
}

world.systems.draw = {
	bbox = function(w, e)
		if e.x and e.y and e.w and e.h then
			love.graphics.setColor(255, 255, 255)
			love.graphics.rectangle('fill', e.x, e.y, e.w, e.h)
		end
	end,
	circle = function(w, e)
		if e.x and e.y then
			love.graphics.setColor(255, 0, 0)
			love.graphics.circle('fill', e.x, e.y, 8)
		end
	end,
}

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
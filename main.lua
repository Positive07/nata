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
		draw = function(self)
			love.graphics.setColor(255, 255, 255)
			love.graphics.rectangle('fill', self.x, self.y,
				self.w, self.h)
		end,
	}
end

local world = ochre.new()

world:add(newSquare(50, 50))
world:add(newSquare(50, 250))
world:add(newSquare(350, 100))
world:add(newSquare(650, 25))

function love.update(dt)
	world:update(dt)
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
	world:draw()
end
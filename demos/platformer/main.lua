local bump = require 'bump'



local System = {Add = {}, Do = {}, Update = {}, Draw = {}}

function System.Add.Physical(e, physics)
	if not e.physical then
		return false
	end
	physics:add(e, e.physical.x, e.physical.y,
		e.physical.w, e.physical.h)
end

function System.Do.Jump(e, physics)
	if not (e.physical and e.vx and e.vy and e.gravity
		and e.jumpPower) then
		return false
	end
	if e._onGround then
		e.vy = -e.jumpPower
	end
end

function System.Update.Velocity(e, physics, dt)
	if not (e.physical and e.vx and e.vy) then
		return false
	end
	local x, y = physics:getRect(e)
	physics:move(e, x + e.vx * dt, y + e.vy * dt)
end

function System.Update.Gravity(e, physics, dt)
	if not (e.physical and e.vx and e.vy and e.gravity) then
		return false
	end
	e.vy = e.vy + e.gravity * dt
	local x, y = physics:getRect(e)
	local _, _, cols = physics:check(e, x, y + 1, function(_, other)
		if other.physical.solid then
			return 'slide'
		end
	end)
	e._onGround = false
	if #cols > 0 then
		e._onGround = true
		e.vy = 0
	end
end

function System.Draw.Physical(e, physics)
	if not (e.physical and e.physical.draw) then
		return false
	end
	love.graphics.setColor(e.physical.draw.color)
	love.graphics.rectangle(e.physical.draw.mode,
		physics:getRect(e))
end



local Entity = {}

function Entity.Wall(x, y, w, h)
	return {
		physical = {
			x = x,
			y = y,
			w = w,
			h = h,
			solid = true,
			draw = {mode = 'fill', color = {150, 150, 150}},
		}
	}
end

function Entity.Player(x, y)
	return {
		physical = {
			x = x,
			y = y,
			w = 32,
			h = 32,
			draw = {mode = 'fill', color = {255, 255, 255}}
		},
		vx = 0,
		vy = 0,
		gravity = 1000,
		jumpPower = 500,
	}
end



local physics = bump.newWorld()
local pool = require 'nata' {
	add = {
		System.Add.Physical,
	},
	update = {
		System.Update.Velocity,
		System.Update.Gravity,
	},
	draw = {
		System.Draw.Physical,
	}
}
pool:add(Entity.Wall(0, 500, 800, 20), physics)
local player = pool:add(Entity.Player(400, 300), physics)

function love.update(dt)
	pool:update(physics, dt)
end

function love.keypressed(key)
	if key == 'up' then
		System.Do.Jump(player, physics)
	end
end

function love.draw()
	pool:draw(physics)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print('On ground: ' .. tostring(player._onGround))
end
local bump = require 'bump'



local System = {
	Add = {},
	Do = {},
	Update = {},
	Keypressed = {},
	Draw = {}
}

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
	local _, _, cols = physics:move(e, x + e.vx * dt, y + e.vy * dt)
	for _, col in ipairs(cols) do
		if col.other.physical.solid then
			if col.normal.x ~= 0 then
				e.vx = 0
			end
			if col.normal.y ~= 0 then
				e.vy = 0
			end
		end
	end
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

function System.Update.Player(e, physics, dt)
	if not (e.player) then
		return false
	end
	if love.keyboard.isDown 'left' then
		e.vx = e.vx - e.player.runSpeed * dt
	end
	if love.keyboard.isDown 'right' then
		e.vx = e.vx + e.player.runSpeed * dt
	end
	e.vx = e.vx - e.vx * e.player.friction * dt
end

function System.Keypressed.Player(e, physics, key)
	if not (e.player) then
		return false
	end
	if key == 'up' then
		System.Do.Jump(e, physics)
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
		player = {runSpeed = 800, friction = 2},
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
		System.Update.Player,
	},
	keypressed = {
		System.Keypressed.Player,
	},
	draw = {
		System.Draw.Physical,
	}
}
pool:add(Entity.Wall(0, 500, 800, 20), physics)
pool:add(Entity.Wall(0, 200, 800, 20), physics)
pool:add(Entity.Wall(0, 0, 20, 600), physics)
pool:add(Entity.Wall(780, 0, 20, 600), physics)
pool:add(Entity.Wall(400, 350, 400, 150), physics)
pool:add(Entity.Wall(300, 450, 100, 50), physics)
local player = pool:add(Entity.Player(200, 300), physics)

function love.update(dt)
	pool:call('update', physics, dt)
end

function love.keypressed(key)
	pool:call('keypressed', physics, key)
end

function love.draw()
	pool:call('draw', physics)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print('On ground: ' .. tostring(player._onGround))
end
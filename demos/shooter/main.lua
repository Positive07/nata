local Object = require 'classic'

local Class = {}



Class.Player = Object:extend()

function Class.Player:new(x, y)
	self.x = x
	self.y = y
	self.w = 32
	self.h = 32
	self.reloadTimer = 0
end

function Class.Player:update(dt, entities)
	local speed = 300
	if love.keyboard.isDown 'left' then
		self.x = self.x - speed * dt
	end
	if love.keyboard.isDown 'right' then
		self.x = self.x + speed * dt
	end
	if love.keyboard.isDown 'up' then
		self.y = self.y - speed * dt
	end
	if love.keyboard.isDown 'down' then
		self.y = self.y + speed * dt
	end

	self.reloadTimer = self.reloadTimer - dt
	if love.keyboard.isDown 'x' and self.reloadTimer <= 0 then
		self.reloadTimer = 1/8
		entities:add(Class.PlayerBullet(self.x+16-2, self.y+16-8))
	end
end

function Class.Player:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle('fill', self.x, self.y,
		self.w, self.h)
end



Class.PlayerBullet = Object:extend()

function Class.PlayerBullet:new(x, y)
	self.x = x
	self.y = y
	self.w = 4
	self.h = 16
	self.isBullet = true
end

function Class.PlayerBullet:update(dt)
	self.y = self.y - 800 * dt
	if self.y < -self.h then
		self.dead = true
	end
end

function Class.PlayerBullet:collide(other)
	if other.isEnemy then
		self.dead = true
	end
end

function Class.PlayerBullet:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle('fill', self.x, self.y,
		self.w, self.h)
end



Class.Enemy = Object:extend()

function Class.Enemy:new(x, y)
	self.x = x
	self.y = y
	self.w = 32
	self.h = 32
	self.isEnemy = true
end

function Class.Enemy:update(dt)
	self.y = self.y + 200 * dt
	if self.y > 600 then
		self.dead = true
	end
end

function Class.Enemy:collide(other)
	if other.isBullet then
		self.dead = true
	end
end

function Class.Enemy:draw()
	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle('fill', self.x, self.y,
		self.w, self.h)
end



local pool = require('nata')()

pool:add(Class.Player(400-16, 300-16))

local enemySpawnTimer = 1

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and
	       x2 < x1+w1 and
	       y1 < y2+h2 and
	       y2 < y1+h1
end

function love.update(dt)
	-- spawn enemies every second
	enemySpawnTimer = enemySpawnTimer - dt
	while enemySpawnTimer <= 0 do
		enemySpawnTimer = enemySpawnTimer + 1
		pool:add(Class.Enemy(love.math.random(800)-16, -32))
	end

	-- update entities
	pool:update(dt, pool)

	-- process collisions
	local entities = pool:get()
	for i = 1, #entities do
		for j = i + 1, #entities do
			local a = entities[i]
			local b = entities[j]
			if CheckCollision(a.x, a.y, a.w, a.h,
				b.x, b.y, b.w, b.h) then
				pool:call(a, 'collide', b)
				pool:call(b, 'collide', a)
			end
		end
	end

	-- remove entities
	pool:remove(function(e)
		return e.dead
	end)
end

function love.draw()
	pool:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.print('Total entities: '..#pool:get())
end
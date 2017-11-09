nata = require 'nata'

uptime = 0

startPositionSystem = {
    add = function(e)
        e.x = 400
        e.y = 300
    end
}

horizontalMovementSystem = {
    filter = function(e) return e.xspeed end,
    update = function(e, dt)
        e.x = 400 + 200 * math.sin(uptime * e.xspeed * .5)
    end
}

verticalMovementSystem = {
    filter = function(e) return e.yspeed end,
    update = function(e, dt)
        e.y = 300 + 200 * math.sin(uptime * e.yspeed * .5)
    end
}

drawSystem = {
    filter = function(e) return e.color end,
    sort = function(a, b) return a.z > b.z end,
    draw = function(e)
        love.graphics.setColor(e.color)
        love.graphics.circle('fill', e.x, e.y, e.radius, 64)
    end
}

pool = nata.new {
    startPositionSystem,
    horizontalMovementSystem,
    verticalMovementSystem,
    nata.oop(),
    drawSystem,
}

pool:add {z = 1, radius = 32, xspeed = 1, color = {150, 150, 150}}
pool:add {z = 2, radius = 32, xspeed = 2, color = {200, 100, 150}}
pool:add {z = 3, radius = 32, xspeed = 3, yspeed = .1, color = {100, 200, 150}}
pool:add {z = 4, radius = 32, xspeed = 4, yspeed = .2, color = {100, 150, 200}}
pool:add {z = 5, radius = 32, xspeed = 5, color = {150, 200, 100},
    update = function(e, dt)
        e.radius = 32 + 16 * math.sin(uptime)
    end
}

function love.update(dt)
    uptime = uptime + dt
    pool:call('update', dt)
end

function love.draw()
    pool:call 'draw'
    love.graphics.setColor(255, 255, 255)
    love.graphics.print 'the gray circle should be on top'
end
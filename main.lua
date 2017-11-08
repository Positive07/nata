nata = require 'nata'

UpdateSystem = {
    update = function(e, dt)
        e.time = e.time + dt
    end
}

VerticalWiggleSystem = {
    filter = function(e) return e.wiggle end,

    update = function(e, dt)
        e.wiggle = e.wiggle + dt
    end
}

DrawSystem = {
    sort = function(a, b) return a.z > b.z end,

    draw = function(e)
        love.graphics.setColor(e.color)
        local x = 400 + 200*math.sin(e.time)
        local y = 300 + 100*math.sin(e.wiggle or 0)
        love.graphics.circle('fill', x, y + e.y, 32, 64)
    end
}

pool = nata.new {
    UpdateSystem,
    VerticalWiggleSystem,
    DrawSystem,
}

pool:add {z = 5, time = 0, y = 0, color = {100, 100, 100}}
pool:add {z = 4, time = 1, y = 20, color = {150, 75, 100}}
pool:add {z = 0, time = 2, y = 40, wiggle = 1, color = {75, 150, 100}}
pool:add {z = 2, time = 3, y = 60, color = {100, 150, 75}}
pool:add {z = 3, time = 4, y = 80, color = {100, 75, 150}}

function love.update(dt)
    pool:call('update', dt)
end

function love.draw()
    pool:call('draw')
end
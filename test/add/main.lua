nata = require 'nata'

setSystem = {
    update = function(e)
        e.nice = true
    end,
}

addSystem = {
    update = function(e, pool)
        if e.cool then
            pool:add {}
            e.cool = false
        end
    end
}

checkSystem = {
    update = function(e)
        assert(e.nice, 'this is wrong: entities added during a pool:call() should not be called in the same loop')
    end
}

pool = nata.new {
    setSystem,
    addSystem,
    checkSystem,
}
pool:add {cool = true}

function love.update()
    pool:call('update', pool)
end
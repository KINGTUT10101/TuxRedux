local tux = require ("tux")

function love.update (dt)
    tux.callbacks.update (dt)

    tux.show.label ({colors = {1, 0, 0, 1}}, 100, 100, 250, 100)
    tux.show.label ({colors = {1, 0, 0, 1}}, 150, 150, 250, 100)

    tux.show.button (nil, 400, 300, 100, 200)
    tux.show.button (nil, 450, 350, 100, 200)
end

function love.draw ()
    tux.callbacks.draw ()
end
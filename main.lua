local tux = require ("tux")

function love.update (dt)
    tux.callbacks.update (dt)

    tux.show.label ({colors = {1, 0, 0, 1}}, 100, 100, 250, 100)
    tux.show.label ({colors = {1, 0, 0, 1}}, 150, 150, 250, 100)

    tux.show.button (nil, 400, 300, 100, 200)
    if tux.show.button (nil, 450, 350, 100, 200) == "start" then
        print ("start")
    end

    tux.show.noClickZone ({debug = true}, 550, 100, 100, 100)
    if tux.show.button (nil, 600, 150, 100, 200) == "held" then
        print ("held")
    end
end

function love.draw ()
    tux.callbacks.draw ()

    -- Print cursor coordinates
    local mx, my = love.mouse.getPosition ()
    love.graphics.setColor (1, 1, 1, 1)
    love.graphics.print (mx .. ", " .. my, 725, 25)
end
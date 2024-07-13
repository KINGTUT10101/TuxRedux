local tux = require ("tux")

local checkboxData = {checked = false}
local checkColor = {
    on = {0, 1, 0, 1},
    off = {1, 0, 0, 1},
}
local sliderData = {value = 0}

function love.update (dt)
    tux.callbacks.update (dt)

    tux.show.label ({colors = {1, 0, 0, 1}}, 100, 100, 250, 100)
    tux.show.label ({colors = {1, 0, 0, 1}}, 150, 150, 250, 100)

    if tux.show.button (nil, 400, 300, 100, 200) == "end" then
        print ("end")
    end
    if tux.show.button (nil, 450, 350, 100, 200) == "start" then
        print ("start")
    end

    tux.show.noPressZone (nil, 550, 100, 100, 100)
    if tux.show.button (nil, 600, 150, 100, 200) == "held" then
        print ("held")
    end

    if tux.show.button ({text="Debug mode"}, 25, 525, 50, 50) == "start" then
        tux.utils.setDebugMode (not tux.utils.getDebugMode ())
    end
    
    tux.show.checkbox ({data = checkboxData, mark = "cross"}, 500, 25, 100, 50)

    tux.show.toggle ({data = checkboxData, checkColor = checkColor}, 25, 350, 50, 50)

    tux.show.slider ({data = sliderData}, 150, 300, 200, 50)
    tux.show.slider ({data = sliderData}, 150, 400, 450, 75)

    tux.show.label ({text = math.floor (sliderData.value * 100) / 100}, 25, 25, 50, 25)
end

function love.draw ()
    tux.callbacks.draw ()

    -- Prints the cursor coordinates
    local mx, my = love.mouse.getPosition ()
    love.graphics.setColor (1, 1, 1, 1)
    love.graphics.print (mx .. ", " .. my, 700, 25)

    -- Prints the current debug mode
    love.graphics.print ("Debug: " .. tostring (tux.utils.getDebugMode ()), 700, 50)
end
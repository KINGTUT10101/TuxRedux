local tux = require ("tux")

local checkboxData = {checked = false}
local checkColor = {
    on = {0, 1, 0, 1},
    off = {1, 0, 0, 1},
}
local sliderData = {value = 0}
local singleInputData = {
    text = "First data",
    inFocus = false,
}

local singleInputData2 = {
    text = "222222222222",
    inFocus = false,
}

local singleInputData3 = {
    text = "freeeeeeeee",
    inFocus = false,
}

function love.update (dt)
    tux.callbacks.update (dt)

    tux.show.label ({text = "Hello world!", fsize = 50, colors = {1, 0, 0, 1},}, 100, 100, 250, 100)
    tux.show.label ({
        colors = {1, 0, 1, 1},
        tooltip = {
            text = "This is a test"
        }
    }, 150, 150, 250, 100)

    if tux.show.button (nil, 400, 300, 100, 200) == "end" then
        print ("end")
    end
    if tux.show.button (nil, 450, 350, 100, 200) == "start" then
        print ("start")
    end

    tux.show.noPressZone ({
        text = "You can't see me!"
    }, 550, 100, 100, 100)
    if tux.show.button (nil, 600, 150, 100, 200) == "held" then
        print ("held")
    end

    if tux.show.button ({text="Debug mode"}, 25, 525, 50, 50) == "start" then
        tux.utils.setDebugMode (not tux.utils.getDebugMode ())
    end
    
    tux.show.checkbox ({data = checkboxData, mark = "cross"}, 500, 25, 100, 50)

    tux.show.toggle ({data = checkboxData, checkColor = checkColor}, 25, 350, 50, 50)

    tux.show.slider ({data = sliderData}, 150, 300, 200, 50)

    tux.show.label ({
        text = math.floor (sliderData.value * 100) / 100,
        colors = {1, 0, 1, 1},
    }, 25, 25, 50, 25)

    tux.show.singleInput ({data = singleInputData, clearButton = true, defaultText = "Default AF"}, 150, 400, 200, 50)

    tux.show.singleInput ({data = singleInputData2}, 150, 500, 200, 50)

    tux.show.singleInput ({data = singleInputData3}, 600, 500, 200, 50)

    tux.layout.pushGrid ({
        margins = {
            all = 5
        },
        primaryAxis = "x",
        dir = "right",
        vdir = "down",
    }, 600, 375)

    tux.show.button ({
        text = "1",
    }, tux.layout.nextItem (nil, 25, 25))

    tux.show.button ({
        text = "2",
    }, tux.layout.nextItem (nil, 25, 25))

    tux.show.button ({
        text = "3",
    }, tux.layout.nextItem (nil, 25, 25))

    tux.layout.nextLine ()

    tux.show.button ({
        text = "4",
    }, tux.layout.nextItem ({margins = {top = 25, left = 0}}, 25, 50))

    tux.show.button ({
        text = "5",
    }, tux.layout.nextItem (nil, 25, 25))

    tux.layout.popGrid ()
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

function love.textinput (text)
    tux.callbacks.textinput (text)
end

function love.keypressed (key, scancode, isrepeat)
    tux.callbacks.keypressed (key, scancode, isrepeat)
end
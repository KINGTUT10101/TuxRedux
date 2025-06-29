local f = io.open("trace.log", "w")
function log(msg)
    f:write(os.time() .. " | " .. msg .. "\n")
    f:flush()
end

log ("========== START PROGRAM - " .. os.time ()  .. " ==========")
-- local origPrint = print
-- local printQueue = {}
-- print = function (...)
--     local printItems = {}
--     for k, v in ipairs ({...}) do
--         table.insert(printItems, v)
--     end
--     table.insert(printQueue, printItems)
-- end
local compareTables = require ("compareTables")
local tux = require ("tux")
local copyTable = require("tux.helpers.copyTable")

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

local lastTux = copyTable(tux)
local printComp = false
function love.update (dt)
    printQueue = {}
    tux.callbacks.update (dt)

    -- tux.show.label ({text = "Hello world!", fsize = 50, colors = {1, 0, 0, 1},}, 100, 100, 250, 100)
    -- tux.show.label ({
    --     colors = {1, 0, 1, 1},
    --     tooltip = {
    --         text = "This is a test"
    --     }
    -- }, 150, 150, 250, 100)

    -- if tux.show.button (nil, 400, 300, 100, 200) == "end" then
    --     print ("end")
    -- end
    -- if tux.show.button (nil, 450, 350, 100, 200) == "start" then
    --     print ("start")
    -- end

    -- tux.show.noPressZone ({
    --     text = "You can't see me!"
    -- }, 550, 100, 100, 100)
    -- if tux.show.button (nil, 600, 150, 100, 200) == "held" then
    --     print ("held")
    -- end

    if tux.show.button ({text="Debug mode"}, 25, 525, 50, 50) == "start" then
        tux.utils.setDebugMode (not tux.utils.getDebugMode ())
    end
    
    -- tux.show.checkbox ({data = checkboxData, mark = "cross"}, 500, 25, 100, 50)

    -- tux.show.toggle ({data = checkboxData, checkColor = checkColor}, 25, 350, 50, 50)

    -- tux.show.slider ({data = sliderData}, 150, 300, 200, 50)

    -- tux.show.label ({
    --     text = math.floor (sliderData.value * 100) / 100,
    --     colors = {1, 0, 1, 1},
    -- }, 25, 25, 50, 25)

    -- tux.show.singleInput ({data = singleInputData, clearButton = true, defaultText = "Default AF"}, 150, 400, 200, 50)

    -- tux.show.singleInput ({data = singleInputData2}, 150, 500, 200, 50)

    -- tux.show.singleInput ({data = singleInputData3}, 600, 500, 200, 50)

    -- tux.layout.pushGrid ({
    --     margins = {
    --         all = 5
    --     },
    --     primaryAxis = "y",
    --     dir = "right",
    --     vdir = "down",
    --     maxOverallSize = 120
    -- }, 600, 375)

    -- tux.show.button ({
    --     text = "1",
    -- }, tux.layout.nextItem (nil, 25, 25))

    -- tux.show.button ({
    --     text = "2",
    -- }, tux.layout.nextItem (nil, 25, 25))

    -- tux.show.button ({
    --     text = "3",
    -- }, tux.layout.nextItem (nil, 25, 25))

    -- tux.layout.nextLine ()

    -- tux.show.button ({
    --     text = "4",
    -- }, tux.layout.nextItem ({margins = {top = 25, left = 0}}, 25, 50))

    -- tux.show.button ({
    --     text = "5",
    -- }, tux.layout.nextItem (nil, 25, 25))

    -- tux.layout.popGrid ()


    local originOpt = {scale = 2}
    tux.layout.pushOrigin (originOpt, 100, 100, 500, 300)

    local opt = {
        oalign = "right",
        voalign = "bottom",
        print = printComp,
        text = "br"
    }
    if tux.show.button (opt, 25, 25, 50, 25) == "held" then
        print ("held")
    end

    if printComp == true then
        print("Apply origin in: ", originOpt.ox, originOpt.oy, originOpt.ow, originOpt.oh)
        print("Prev origin: ", originOpt.px, originOpt.py, originOpt.pw, originOpt.ph)
        print("Apply origin out: ", originOpt.x, originOpt.y, originOpt.w, originOpt.h)

        print ("Original: ", opt.ox, opt.oy, opt.ow, opt.oh)
        print ("Origin: ", opt.oox, opt.ooy, opt.oow, opt.ooh)
        print ("Origin stack size: ", opt.oosz)
        print ("Applied: ", opt.x, opt.y, opt.w, opt.h)
        print ()
    end

    tux.show.button({
        oalign = "left",
        voalign = "bottom",
        print = printComp,
        text = "bl"
    }, 25, 25, 50, 25)

    tux.show.button({
        oalign = "right",
        voalign = "top",
        print = printComp,
        text = "tr"
    }, 25, 25, 50, 25)

    tux.show.button({
        oalign = "left",
        voalign = "top",
        print = printComp,
        text = "tl"
    }, 25, 25, 50, 25)

    tux.show.button({
        oalign = "center",
        voalign = "center",
        print = printComp,
        text = "cc"
    }, 0, 0, 50, 25)

    tux.show.button({
        oalign = "center",
        voalign = "bottom",
        print = printComp,
        text = "cb"
    }, 0, 25, 50, 25)

    tux.show.button({
        oalign = "center",
        voalign = "top",
        print = printComp,
        text = "ct"
    }, 0, 25, 50, 25)

    tux.show.button({
        oalign = "left",
        voalign = "center",
        print = printComp,
        text = "lc"
    }, 25, 0, 50, 25)

    tux.show.button({
        oalign = "right",
        voalign = "center",
        print = printComp,
        text = "rc"
    }, 25, 0, 50, 25)

    -- tux.layout.pushOrigin({scale = 0.5}, 5, 5, 150, 75)

    -- tux.show.button({
    --     oalign = "right",
    --     voalign = "bottom"
    -- }, 15, 15, 60, 30)

    -- tux.layout.pushOrigin({ scale = 0.5 }, 5, 5, 150, 75)

    -- tux.show.button({
    --     oalign = "left",
    --     voalign = "bottom"
    -- }, 15, 15, 60, 30)

    -- tux.layout.popOrigin ()

    -- tux.layout.popOrigin ()

    -- tux.layout.pushOrigin({scale = 1}, 175, 15, 50, 50)

    -- tux.show.button({
    --     oalign = "left",
    --     voalign = "top"
    -- }, 5, 5, 20, 20)

    -- tux.layout.popOrigin ()

    tux.layout.popOrigin ()

    -- print ()
end

function love.draw ()
    tux.callbacks.draw ()

    -- Prints the cursor coordinates
    local mx, my = love.mouse.getPosition ()
    love.graphics.setColor (1, 1, 1, 1)
    love.graphics.print (mx .. ", " .. my, 700, 25)

    -- Prints the current debug mode
    love.graphics.print ("Debug: " .. tostring (tux.utils.getDebugMode ()), 700, 50)

    -- Prints the FPS
    love.graphics.print("FPS: " .. love.timer.getFPS (), 700, 75)

    love.graphics.print(PRINTVAL or "", 25, 25)
end

function love.textinput (text)
    tux.callbacks.textinput (text)
end

function love.keypressed (key, scancode, isrepeat)
    tux.callbacks.keypressed (key, scancode, isrepeat)

    if key == "p" then
        for k, printItems in ipairs (printQueue) do
            origPrint(unpack(printItems))
        end
    elseif key == "c" then
        compareTables("Base", tux, lastTux, true)
        lastTux = copyTable(tux)
        print ()
    elseif key == "t" then
        printComp = not printComp
        print (printComp)
        PRINTVAL = nil
    end
end
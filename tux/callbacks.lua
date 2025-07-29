local libPath = (...):match("(.+)%.[^%.]+$") .. "."

local tux = require (libPath .. "tux")

-- This should run BEFORE you show any UI items
function tux.callbacks.update (dt, mx, my, isDown)
    if #tux.layoutData.gridStack ~= 0 then
        local topmostItem = tux.layoutData.gridStack[#tux.layoutData.gridStack]

        if tux.errorForUnclearedStacks == true then
            error ("Grid stack overflow. Found grid item started at (" .. topmostItem.startx .. ", " .. topmostItem.starty.. "). Make sure you're properly popping values from the stack.")
        elseif tux.debugMode == true then
            print ("Grid stack overflow. Found grid item started at (" .. topmostItem.startx .. ", " .. topmostItem.starty.. "). Make sure you're properly popping values from the stack.")
        end
    end

    if #tux.layoutData.originStack ~= 1 then
        local topmostItem = tux.layoutData.originStack[#tux.layoutData.originStack]

        if tux.errorForUnclearedStacks == true then
            error ("Origin stack overflow. Found origin item started at (" .. topmostItem.x .. ", " .. topmostItem.y.. "). Make sure you're properly popping values from the stack.")
        elseif tux.debugMode == true then
            print ("Origin stack overflow. Found origin item started at (" .. topmostItem.x .. ", " .. topmostItem.y.. "). Make sure you're properly popping values from the stack.")
        end
    end

    -- Check if font cache should be cleared
    if tux.fontCacheSize > tux.maxFontsCached then
        tux.utils.clearCachedFonts ()
    end
    
    tux.cursor.wasDown = tux.cursor.isDown
    tux.cursor.lastState = tux.cursor.currentState
    tux.cursor.lastActualState = tux.cursor.currentActualState
    tux.cursor.lastX = tux.cursor.x
    tux.cursor.lastY = tux.cursor.y
    tux.cursor.lastLockedX = tux.cursor.lockedX
    tux.cursor.lastLockedY = tux.cursor.lockedY

    if isDown == nil then
        tux.cursor.isDown = love.mouse.isDown (1)
    else
        tux.cursor.isDown = isDown
    end

    if mx == nil or my == nil then
        tux.cursor.x, tux.cursor.y = love.mouse.getPosition ()
    else
        tux.cursor.x, tux.cursor.y = mx, my
    end

    -- Only update locked cursor position if the mouse isn't held down
    if tux.cursor.isDown == false then
        tux.cursor.lockedX = tux.cursor.x
        tux.cursor.lockedY = tux.cursor.y
    end

    -- Reset flags
    tux.cursor.currentState = "normal"
    tux.cursor.currentActualState = "normal"
    tux.tooltip.text = ""
    tux.tooltip.align = "auto"
end

function tux.callbacks.draw ()
    local origFont = love.graphics.getFont ()

    -- Render UI items
    local queue = tux.renderQueue
    for i = #queue, 1, -1 do
        queue[i].draw (tux, queue[i].opt)
        queue[i] = nil
    end

    -- Render tooltip
    tux.core.tooltip ()

    love.graphics.setFont (origFont)

    tux.pressedKey = nil
    tux.specialPressedKey = nil
end

function tux.callbacks.textinput (text)
    tux.pressedKey = text
end

function tux.callbacks.keypressed (key, scancode, isrepeat)
    tux.specialPressedKey = key
end
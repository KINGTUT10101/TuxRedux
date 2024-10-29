local libPath = (...):match("(.+)%.[^%.]+$") .. "."

local tux = require (libPath .. "tux")

-- This should run BEFORE you show any UI items
function tux.callbacks.update (dt, mx, my, isDown)
    tux.cursor.wasDown = tux.cursor.isDown
    tux.cursor.lastState = tux.cursor.currentState
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
    tux.tooltip.text = ""
    tux.tooltip.align = "auto"

    -- Check if font cache should be cleared
    if tux.fontCacheSize > tux.maxFontsCached then
        tux.utils.clearCachedFonts ()
    end
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
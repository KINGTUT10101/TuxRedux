local libPath = (...):match("(.+)%.[^%.]+$") .. "."

local tux = require (libPath .. "tux")
local setDefaults = require (libPath .. "helpers.setDefaults")

function tux.layout.pushOrigin (x, y, w, h)
    
end

function tux.layout.popOrigin ()

end

local validDirs = {
    left = true,
    right = true,
    up = true,
    down = true,
}
local validAligns = {
    center = true,
    left = true,
    right = true,
    top = true,
    bottom = true,
}
function tux.layout.pushGrid (opt, x, y)
    opt = opt or {}
    assert (type (opt) == "table", "Attempt to use a non-table value for UI item options")

    -- Update position and size
    opt.x, opt.y = x, y

    opt.minLineSize = opt.minLineSize or 0
    opt.maxLineLength = opt.maxLineLength or math.huge

    -- Set default direction
    opt.dir = opt.dir or "right"
    assert (validDirs[opt.dir] == true, "Provided grid direction '" .. opt.dir .. "' is not valid")

    -- Set wrap mode
    opt.wrap = opt.wrap or false

    -- Set alignment
    opt.align = opt.align or "center"
    assert (validAligns[opt.align] == true, "Provided alignment '" .. opt.align .. "' is not valid")
    if opt.dir == "left" or opt.dir == "right" then
        assert (opt.align ~= "top" or opt.align ~= "bottom", "Provided alignment is for a vertical grid, but the provided grid is horizontal")
    else
        assert (opt.align ~= "left" or opt.align ~= "right", "Provided alignment is for a horizontal grid, but the provided grid is vertical")
    end

    -- Set default margins
    opt.margins = opt.margins or {}
    assert (type (opt.margins) == "table", "Attempt to use a non-table value for margins attribute")
    opt.margins = tux.core.processMargins (opt.margins)

    opt.grid = {}
    opt.lineSize = 0 -- Reset when the next line is generated and automatically sized to fit the provided components
    opt.startx = opt.x
    opt.starty = opt.y

    table.insert (tux.layoutData.gridStack, opt)
end

function tux.layout.popGrid ()
    assert (#tux.layoutData.gridStack > 0, "Attempt to pop from the grid stack while it was empty")

    table.remove (tux.layoutData.gridStack)
end

function tux.layout.nextItem (itemOpt, w, h, ...)
    itemOpt = itemOpt or {}
    local providedMargins = itemOpt.margins or {}
    assert (type (providedMargins) == "table", "Attempt to use a non-table value for margins attribute")

    local opt = tux.layoutData.gridStack[#tux.layoutData.gridStack]
    setDefaults (opt.margins, providedMargins)
    providedMargins = tux.core.processMargins (providedMargins)

    local x, y = opt.x, opt.y
    local compX, compY = x + providedMargins.left, y + providedMargins.top
    local fullW, fullH = w + providedMargins.left + providedMargins.right, h + providedMargins.top + providedMargins.bottom

    local horizontal = opt.dir == "left" or opt.dir == "right"

    if horizontal == true then
        local newx = x + fullW

        if newx < opt.startx + opt.maxLineLength then
            opt.x = newx
            if opt.lineSize < fullH then
                opt.lineSize = math.max (opt.minLineSize, fullH)
            end
        elseif opt.wrap == true and fullW <= opt.maxLineLength then
            tux.layout.nextLine ()
            return tux.layout.nextItem (itemOpt, w, h)
        else
            if tux.debugMode == true then
                print ("Warning: No room to add item at (" .. x .. ", " .. y .. ")" .. " to the layout starting at (" .. opt.startx .. ", " .. opt.starty .. ")")
            end

            return 0, 0, 0, 0
        end
    else
        local newy = y + fullH

        if newy < opt.starty + opt.maxLineLength then
            opt.y = newy
            if opt.lineSize < fullW then
                opt.lineSize = math.max (opt.minLineSize, fullW)
            end
        elseif opt.wrap == true and fullH <= opt.maxLineLength then
            tux.layout.nextLine ()
            return tux.layout.nextItem (itemOpt, w, h)
        else
            if tux.debugMode == true then
                print ("Warning: No room to add item at (" .. x .. ", " .. y .. ")" .. " to the layout starting at (" .. opt.startx .. ", " .. opt.starty .. ")")
            end

            return 0, 0, 0, 0
        end
    end

    local align = itemOpt.align or opt.align
    if align == "bottom" then
        compY = compY + opt.lineSize - fullH
    elseif align == "right" then
        compX = compX + opt.lineSize - fullW
    elseif align == "center" then
        if horizontal == true then
            compY = compY + (opt.lineSize - fullH) / 2
        else
            compX = compX + (opt.lineSize - fullW) / 2
        end
    end

    if tux.debugMode == true then
        if horizontal == true then
            tux.show.debugBox (nil, x, y, fullW, opt.lineSize)
        else
            tux.show.debugBox (nil, x, y, opt.lineSize, fullH)
        end
    end
    
    return compX, compY, w, h, ...
end

function tux.layout.nextLine ()
    local opt = tux.layoutData.gridStack[#tux.layoutData.gridStack]

    if opt.dir == "left" or opt.dir == "right" then
        opt.y = opt.y + opt.lineSize
        opt.lineSize = opt.minLineSize
        opt.x = opt.startx
    else
        opt.x = opt.x + opt.lineSize
        opt.lineSize = opt.minLineSize
        opt.y = opt.starty
    end
end

-- Precomputes the layout of a grid and returns it as a table that can be used with the other precomp grid functions
function tux.layout.precompGrid (opt, items)

end

function tux.layout.startPrecompGrid (grid, x, y)

end

function tux.layout.nextPrecompItem (grid)

end
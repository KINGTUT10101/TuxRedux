local libPath = (...):match("(.+)%.[^%.]+$") .. "."
local copyTable = require (libPath .. "helpers.copyTable")

local tux = require (libPath .. "tux")
local setDefaults = require (libPath .. "helpers.setDefaults")

function tux.layout.pushOrigin (opt, x, y, w, h)
    opt = copyTable (opt) or {}

    local prevOrigin = tux.layoutData.originStack[#tux.layoutData.originStack]

    opt.x, opt.y, opt.w, opt.h = tux.core.applyOrigin (opt.oalign, opt.voalign, x, y, w, h)
    opt.scale = opt.scale or 1
    opt.scale = opt.scale * prevOrigin.scale

    if tux.show.debugBox(nil, x, y, w, h) == "end" then
        print (opt.x, opt.y, opt.w, opt.h, opt.scale)
    end
    
    tux.layoutData.originStack[#tux.layoutData.originStack + 1] = opt
end

function tux.layout.popOrigin ()
    assert(#tux.layoutData.originStack > 1, "Attempt to pop from the origin stack while it was empty")

    tux.layoutData.originStack[#tux.layoutData.originStack] = nil
end

local validDirsX = {
    left = true,
    right = true,
}
local validDirsY = {
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
local validAxes = {
    x = true,
    y = true,
}
function tux.layout.pushGrid (opt, x, y)
    opt = opt or {}
    assert (type (opt) == "table", "Attempt to use a non-table value for UI item options")

    -- Update position and size
    opt.x, opt.y = x, y

    opt.minLineSize = opt.minLineSize or 0
    opt.maxLineLength = opt.maxLineLength or math.huge
    opt.maxOverallSize = opt.maxOverallSize or math.huge

    -- Set wrap mode
    opt.wrap = opt.wrap or false

    -- Set default directions
    opt.dir = opt.dir or "right"
    opt.vdir = opt.vdir or "down"
    assert(validDirsX[opt.dir] == true, "Provided grid direction '" .. opt.dir .. "' is not valid")
    assert(validDirsY[opt.vdir] == true, "Provided grid direction '" .. opt.vdir .. "' is not valid")
    
    -- Major axis
    opt.primaryAxis = opt.primaryAxis or "x"
    assert(validAxes[opt.primaryAxis] == true, "Provided primary axis '" .. opt.primaryAxis .. "' is not valid")

    -- Set alignment
    opt.align = opt.align or "center"
    assert(validAligns[opt.align] == true, "Provided alignment '" .. opt.align .. "' is not valid")
    assert ((opt.primaryAxis == "x" and opt.align ~= "left" and opt.align ~= "right") or (opt.primaryAxis == "y" and opt.align ~= "up" and opt.align ~= "down"), "Provided alignment '" .. opt.align .. "' is not valid for the selected major axis")

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

function tux.layout.pushNestedGrid (gridOpt, itemOpt, w, h)
    local x, y, w, h = tux.layout.nextItem (itemOpt, w, h)

    if gridOpt.primaryAxis == "x" then
        gridOpt.maxLineLength = w
        gridOpt.maxOverallSize = h
    else
        gridOpt.maxLineLength = h
        gridOpt.maxOverallSize = w
    end

    if gridOpt.dir == "left" then
        x = x + w
    end

    if gridOpt.vdir == "up" then
        y = y + h
    end

    tux.layout.pushGrid (gridOpt, x, y)
end

function tux.layout.nextItem(itemOpt, w, h, ...)
    itemOpt = itemOpt or {}

    local providedMargins = itemOpt.margins or {}
    assert(type(providedMargins) == "table", "Attempt to use a non-table value for margins attribute")

    local opt = tux.layoutData.gridStack[#tux.layoutData.gridStack]
    setDefaults(opt.margins, providedMargins)
    providedMargins = tux.core.processMargins(providedMargins)

    local x, y = opt.x, opt.y
    local compX, compY = x + providedMargins.left, y + providedMargins.top
    local fullW, fullH = w + providedMargins.left + providedMargins.right, h + providedMargins.top + providedMargins.bottom

    local horizontal = opt.primaryAxis == "x"

    if horizontal == true then
        if y + fullH - opt.starty > opt.maxOverallSize then
            if tux.debugMode == true then
                print("Warning: No room to add item at (" ..
                    x .. ", " .. y .. ")" .. " to the layout starting at (" .. opt.startx .. ", " .. opt.starty .. ") due to reaching the maximum overall size")
            end
            return 0, 0, 0, 0
        end
    else
        if x + fullW - opt.startx > opt.maxOverallSize then
            if tux.debugMode == true then
                print("Warning: No room to add item at (" ..
                    x .. ", " .. y .. ")" .. " to the layout starting at (" .. opt.startx .. ", " .. opt.starty .. ") due to reaching the maximum overall size")
            end
            return 0, 0, 0, 0
        end
    end

    if horizontal == true then
        local newx = x + fullW
        
        if newx < opt.startx + opt.maxLineLength then
            opt.x = newx
            if opt.lineSize < fullH then
                opt.lineSize = math.max(opt.minLineSize, fullH)
            end
        elseif opt.wrap == true and fullW <= opt.maxLineLength then
            tux.layout.nextLine()
            return tux.layout.nextItem(itemOpt, w, h)
        else
            if tux.debugMode == true then
                print("Warning: No room to add item at (" ..
                x .. ", " .. y .. ")" .. " to the layout starting at (" .. opt.startx .. ", " .. opt.starty .. ")")
            end
            return 0, 0, 0, 0
        end
    else
        local newy = y + fullH

        if newy < opt.starty + opt.maxLineLength then
            opt.y = newy
            if opt.lineSize < fullW then
                opt.lineSize = math.max(opt.minLineSize, fullW)
            end
        elseif opt.wrap == true and fullH <= opt.maxLineLength then
            tux.layout.nextLine()
            return tux.layout.nextItem(itemOpt, w, h)
        else
            if tux.debugMode == true then
                print("Warning: No room to add item at (" ..
                x .. ", " .. y .. ")" .. " to the layout starting at (" .. opt.startx .. ", " .. opt.starty .. ")")
            end
            return 0, 0, 0, 0
        end
    end

    local align = itemOpt.align or opt.align
    local origCompX, origCompY = compX, compY
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

    if horizontal == true then
        fullH = math.max(fullH, opt.lineSize)
    else
        fullW = math.max(fullW, opt.lineSize)
    end

    if opt.dir == "left" then
        compX = compX - (x - opt.startx) * 2 - fullW
        origCompX = origCompX - (x - opt.startx) * 2 - fullW
        x = origCompX - providedMargins.left
    end

    if opt.vdir == "up" then
        compY = compY - (y - opt.starty) * 2 - fullH
        origCompY = origCompY - (y - opt.starty) * 2 - fullH
        y = origCompY - providedMargins.top
    end

    if tux.debugMode == true then
        if horizontal == true then
            if tux.show.debugBox(nil, x, y, fullW, opt.lineSize) == "end" then
                print (x, y, fullH, fullW)
            end
        else
            if tux.show.debugBox(nil, x, y, opt.lineSize, fullH) == "end" then
                print(x, y, fullH, fullW)
            end
        end
    end

    compX, compY, w, h = tux.core.applyOrigin(opt.oalign, opt.voalign, compX, compY, w, h)

    return compX, compY, w, h, ...
end

function tux.layout.nextLine()
    local opt = tux.layoutData.gridStack[#tux.layoutData.gridStack]

    if opt.primaryAxis == "x" then
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
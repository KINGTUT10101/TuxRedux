local libPath = (...):match("(.+)%.[^%.]+$") .. "."
local copyTable = require(libPath .. "helpers.copyTable")

local tux = require(libPath .. "tux")
local setDefaults = require(libPath .. "helpers.setDefaults")

-- This should only be used if needed, like when you transition to another UI scene after pushing a button
function tux.layout.clearStacks()
    for i = 2, #tux.layoutData.originStack do
        tux.layoutData.originStack[i] = nil
    end

    for i = 1, #tux.layoutData.gridStack do
        tux.layoutData.gridStack[i] = nil
    end
end

function tux.layout.pushOrigin(opt, x, y, w, h)
    opt = copyTable(opt) or {}

    local prevOrigin = tux.layoutData.originStack[#tux.layoutData.originStack]

    opt.x, opt.y, opt.w, opt.h = tux.core.applyOrigin(nil, opt.oalign, opt.voalign, x, y, w, h)
    opt.scale = opt.scale or 1
    opt.scale = opt.scale * prevOrigin.scale

    opt.defaultoalign = opt.defaultoalign or "left"
    opt.defaultvoalign = opt.defaultvoalign or "top"

    table.insert(tux.layoutData.originStack, opt)
end

function tux.layout.popOrigin()
    assert(#tux.layoutData.originStack > 1, "Attempt to pop from the origin stack while it was empty")

    local opt = tux.layoutData.originStack[#tux.layoutData.originStack]

    table.remove(tux.layoutData.originStack)

    if tux.show.debugBox({
        oalign = "left",
        voalign = "top"
    }, opt.x, opt.y, opt.w, opt.h) == "end" then
        print("Origin: ", opt.x, opt.y, opt.w, opt.h, opt.scale)
    end
end

function tux.layout.setDefaultAlign (oalign, voalign)
    local origin = tux.layoutData.originStack[#tux.layoutData.originStack]

    origin.defaultoalign = oalign or origin.defaultoalign
    origin.defaultvoalign = voalign or origin.defaultvoalign
end

function tux.layout.getOriginWidth ()
    local origin = tux.layoutData.originStack[#tux.layoutData.originStack]
    return origin.w / origin.scale
end

function tux.layout.getOriginHeight ()
    local origin = tux.layoutData.originStack[#tux.layoutData.originStack]
    return origin.h / origin.scale
end

function tux.layout.getOriginDimensions ()
    local origin = tux.layoutData.originStack[#tux.layoutData.originStack]
    return origin.w / origin.scale, origin.h / origin.scale
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
function tux.layout.pushGrid(opt, x, y)
    opt = opt or {}
    assert(type(opt) == "table", "Attempt to use a non-table value for UI item options")

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

    -- local origin = tux.layoutData.originStack[#tux.layoutData.originStack]
    -- if origin.defaultoalign == "right" and opt.dir == "left" then
    --     opt.dir = "right"
    -- end
    -- if origin.defaultvoalign == "bottom" and opt.vdir == "up" then
    --     opt.vdir = "bottom"
    -- end

    -- Major axis
    opt.primaryAxis = opt.primaryAxis or "x"
    assert(validAxes[opt.primaryAxis] == true, "Provided primary axis '" .. opt.primaryAxis .. "' is not valid")

    -- Set alignment
    opt.align = opt.align or "center"
    assert(validAligns[opt.align] == true, "Provided alignment '" .. opt.align .. "' is not valid")
    assert(
    (opt.primaryAxis == "x" and opt.align ~= "left" and opt.align ~= "right") or
    (opt.primaryAxis == "y" and opt.align ~= "up" and opt.align ~= "down"),
        "Provided alignment '" .. opt.align .. "' is not valid for the selected major axis")

    -- Set default margins
    opt.margins = opt.margins or {}
    assert(type(opt.margins) == "table", "Attempt to use a non-table value for margins attribute")
    opt.margins = tux.core.processMargins(opt.margins)

    -- Set default padding
    opt.padding = opt.padding or {}
    assert(type(opt.padding) == "table", "Attempt to use a non-table value for padding attribute")
    opt.padding = tux.core.processPadding(opt.padding)

    opt.grid = {}
    opt.lineSize = 0 -- Reset when the next line is generated and automatically sized to fit the provided components
    opt.startx = opt.x
    opt.starty = opt.y

    table.insert(tux.layoutData.gridStack, opt)
end

function tux.layout.popGrid()
    assert(#tux.layoutData.gridStack > 0, "Attempt to pop from the grid stack while it was empty")

    table.remove(tux.layoutData.gridStack)
end

function tux.layout.pushNestedGrid(gridOpt, itemOpt, w, h)
    local x, y, w, h = tux.layout.nextItem(itemOpt, w, h)

    gridOpt.primaryAxis = gridOpt.primaryAxis or "x"
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

    tux.layout.pushGrid(gridOpt, x, y)
end

function tux.layout.nextItem(itemOpt, w, h, ...)
    itemOpt = itemOpt or {}
    assert (type (itemOpt) == "table", "Provided item options is not a table")

    local test = itemOpt.test or false

    local opt = tux.layoutData.gridStack[#tux.layoutData.gridStack]
    local origOpt = nil

    if test == true then
        opt = copyTable (opt)
    end

    -- Check if the provided width and height values are percentages
    if type (w) == "string" then
        local maxValue = opt.primaryAxis == "x" and opt.maxLineLength or opt.maxLineSize
        assert (maxValue ~= math.huge, "Attempt to use a percentage width value in a grid with no max line length")

        if w:sub(-1) == "%" then
            w = tonumber(w:sub(1, -2)) / 100 * maxValue
        else
            error("Invalid width value: " .. w)
        end
    end
    if type (h) == "string" then
        local maxValue = opt.primaryAxis == "x" and opt.maxLineSize or opt.maxLineLength
        assert (maxValue ~= math.huge, "Attempt to use a percentage height value in a grid with no max line size")

        if h:sub(-1) == "%" then
            h = tonumber(h:sub(1, -2)) / 100 * maxValue
        else
            error("Invalid height value: " .. h)
        end
    end

    local providedMargins = itemOpt.margins or {}
    assert(type(providedMargins) == "table", "Attempt to use a non-table value for margins attribute")

    setDefaults(opt.margins, providedMargins)
    providedMargins = tux.core.processMargins(providedMargins)

    local x, y = opt.x, opt.y
    local compX, compY = x + providedMargins.left, y + providedMargins.top
    local fullW, fullH = w + providedMargins.left + providedMargins.right,
        h + providedMargins.top + providedMargins.bottom

    local horizontal = opt.primaryAxis == "x"

    if horizontal == true then
        if y + fullH - opt.starty > opt.maxOverallSize then
            if tux.debugMode == true then
                print("Warning: No room to add item at (" ..
                    x ..
                    ", " ..
                    y ..
                    ")" ..
                    " to the layout starting at (" ..
                    opt.startx .. ", " .. opt.starty .. ") due to reaching the maximum overall size")
            end
            return 0, 0, 0, 0
        end
    else
        if x + fullW - opt.startx > opt.maxOverallSize then
            if tux.debugMode == true then
                print("Warning: No room to add item at (" ..
                    x ..
                    ", " ..
                    y ..
                    ")" ..
                    " to the layout starting at (" ..
                    opt.startx .. ", " .. opt.starty .. ") due to reaching the maximum overall size")
            end
            return 0, 0, 0, 0
        end
    end

    if horizontal == true then
        local newx = x + fullW

        if newx <= opt.startx + opt.maxLineLength then
            opt.x = newx
            if opt.lineSize < fullH then
                opt.lineSize = math.max(opt.minLineSize, fullH)
            end
        elseif opt.wrap == true and fullW <= opt.maxLineLength then
            tux.layout.nextLine(itemOpt)
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

        if newy <= opt.starty + opt.maxLineLength then
            opt.y = newy
            if opt.lineSize < fullW then
                opt.lineSize = math.max(opt.minLineSize, fullW)
            end
        elseif opt.wrap == true and fullH <= opt.maxLineLength then
            tux.layout.nextLine(itemOpt)
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
                print("Next Item: ", x, y, fullH, fullW)
            end
        else
            if tux.show.debugBox(nil, x, y, opt.lineSize, fullH) == "end" then
                print("Next Item: ", x, y, fullH, fullW)
            end
        end
    end

    local providedPadding = itemOpt.padding or {}
    assert(type(providedPadding) == "table", "Attempt to use a non-table value for padding attribute")

    setDefaults(opt.padding, providedPadding)
    providedPadding = tux.core.processPadding(providedPadding)

    return tux.core.applyPadding (providedPadding, compX, compY, w, h, ...)
end

function tux.layout.nextLine(itemOpt)
    itemOpt = itemOpt or {}

    local test = itemOpt.test or false
    local opt = tux.layoutData.gridStack[#tux.layoutData.gridStack]

    if test == true then
        opt = copyTable (opt)
    end

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

function tux.layout.remainingLength ()
    local opt = tux.layoutData.gridStack[#tux.layoutData.gridStack]

    local primaryUnit = (opt.primaryAxis == "x") and opt.x or opt.y
    local primaryStart = (opt.primaryAxis == "x") and opt.startx or opt.starty

    return primaryStart + opt.maxLineLength - primaryUnit
end

function tux.layout.remainingOverallSize ()
    local opt = tux.layoutData.gridStack[#tux.layoutData.gridStack]

    local secondaryUnit = (opt.primaryAxis == "y") and opt.x or opt.y
    local secondaryStart = (opt.primaryAxis == "y") and opt.startx or opt.starty

    return secondaryStart + opt.maxOverallSize - secondaryUnit
end

-- Precomputes the layout of a grid and returns it as a table that can be used with the other precomp grid functions
function tux.layout.precompGrid(opt, items)

end

function tux.layout.startPrecompGrid(grid, x, y)

end

function tux.layout.nextPrecompItem(grid)

end

function tux.layout.getLineWidth (opt)

end

function tux.layout.getLineHeight (opt)

end
local libPath = (...):match("(.+)%.[^%.]+$") .. "."

local tux = require (libPath .. "tux")
local copyTable = require (libPath .. "helpers.copyTable")

function tux.utils.registerComponent (component)
    if component.id == nil then
        error ("Attempt to register a component without an ID")
    end

    if tux.comp[component.id] == nil or component.override == true then
        -- Copy component attributes to new table
        local newComp = copyTable (component)

        -- Create show function
        function newComp.show (opt, x, y, w, h)
            opt = opt or {}
            assert (type (opt) == "table", "Attempt to use a non-table value for UI item options")

            opt.x, opt.y, opt.w, opt.h = tux.core.applyOrigin (opt, opt.oalign, opt.voalign, x, y, w, h)

            -- Update padding
            opt.padding = tux.core.processPadding (opt.padding)

            -- Initialize new UI item
            local returnVal = newComp.init (tux, opt)

            -- Process tooltip
            if opt.tooltip ~= nil and opt.state ~= "normal" then
                tux.utils.setTooltip (opt.tooltip.text, opt.tooltip.align)
            end

            -- Add new UI item to render queue
            tux.renderQueue[#tux.renderQueue + 1] = {
                opt = opt,
                draw = newComp.draw,
            }

            return returnVal
        end

        tux.comp[component.id] = newComp
    end
end

function tux.utils.registerFont (id, path, defaultSize)
    local status, font = pcall (love.graphics.newFont, path)
    assert (status == true and font ~= nil, "Provided filepath does not correspond to a valid font object")
    assert (tux.fonts[id] == nil, "Attempt to overwrite an existing font")

    tux.fonts[id] = {
        path = path,
        defaultSize = defaultSize or tux.defaultFontSize,
        cache = {},
    }
end

-- Returns true if a UI item was clicked yet in the current frame
-- It's best to use this AFTER all of your UI items have been shown
function tux.utils.itemClicked ()
    local state = tux.cursor.currentState
    return state == "start" or state == "held" or state == "end"
end

-- Returns true if a UI item was hoevered over yet in the current frame
-- It's best to use this AFTER all of your UI items have been shown
function tux.utils.itemHovered ()
    return tux.cursor.currentState == "hover"
end

function tux.utils.removeComponent (id)
    tux.comp[id] = nil
end

function tux.utils.removeAllComponents ()
    tux.comp = {}
end

function tux.utils.removeFont (id)
    assert (id ~= "default", "Attempt to remove default font")
    assert (tux.fonts[id] ~= nil, "Attempt to remove a nonexistent font")
    assert (tux.defaultFont ~= id, "Attempt to remove the current default font")

    local fontCacheSize = 0
    for fsize, fontObj in pairs (tux.fonts[id].cache) do
        fontObj:release ()
        fontCacheSize = fontCacheSize + 1
    end
    
    tux.fonts[id] = nil

    tux.fontCacheSize = tux.fontCacheSize - fontCacheSize
end

function tux.utils.removeAllFonts ()
    tux.fonts = {}

end

function tux.utils.getDefaultColors ()
    return copyTable (tux.defaultColors)
end

function tux.utils.setDefaultColors (colors)
    assert (type (colors) == "table", "Attempt to use a non-table value for default colors")
    assert (colors.normal ~= nil and colors.hover ~= nil and colors.held ~= nil, "Provided colors table does not contain all required color states")

    tux.defaultColors = {
        normal = colors.normal,
        hover = colors.hover,
        held = colors.held,
    }
end

function tux.utils.getDefaultSlices ()
    return copyTable (tux.defaultSlices)
end

function tux.utils.setDefaultSlices (slices)
    assert (type (slices) == "table", "Attempt to use a non-table value for default slices")
    assert (slices.normal ~= nil and slices.hover ~= nil and slices.held ~= nil, "Provided slices table does not contain all required slice states")
    
    tux.defaultSlices = {
        normal = slices.normal,
        hover = slices.hover,
        held = slices.held,
    }
end

function tux.utils.getDefaultFont ()
    return tux.defaultFont
end

function tux.utils.getDefaultFontSize ()
    return tux.defaultFontSize
end

function tux.utils.setDefaultFont (fontid)
    assert (tux.fonts[fontid] ~= nil, "Invalid font ID")

    tux.defaultFont = fontid
end

function tux.utils.setDefaultFontSize (fsize)
    tux.defaultFontSize = fsize
end

function tux.utils.clearCachedFonts ()
    for fontid, fontDef in pairs (tux.fonts) do
        for fsize, fontObj in pairs (fontDef.cache) do
            fontObj:release ()
            fontDef.cache[fsize] = nil
        end
    end

    tux.fontCacheSize = 0
end

function tux.utils.getFontCacheSize ()
    return tux.fontCacheSize
end

function tux.utils.getDefaultSounds ()
    return {
        start = tux.sounds.start,
        ["end"] = tux.sounds["end"]
    }
end

function tux.utils.setDefaultSounds (sounds)
    assert (type (sounds) == "table", "Provided sounds argument is not a table")

    tux.sounds.start = sounds.start
    tux.sounds["end"] = sounds["end"]
end

function tux.utils.getDebugMode ()
    return tux.debugMode
end

function tux.utils.setDebugMode (mode)
    assert (type (mode) == "boolean", "Provided debug mode is not a boolean value")
    tux.debugMode = mode
end

function tux.utils.setDebugLineWidth (value)
    assert(type(value) == "number", "Provided debug line width is not a number value")
    assert(value > 0, "Provided debug line width should be a positive number")
    tux.debugLineWidth = value
end

--- Maps numbers from one scale to another.
--- @param input number The input value to be scaled.
--- @param inMin number The min value of the input value scale.
--- @param inMax number The max value of the input value scale.
--- @param outMin number The min value of the output value scale.
--- @param outMax number The max value of the output value scale.
--- @return number output The scaled output value.
function tux.utils.mapToScale (input, inMin, inMax, outMin, outMax)
    return (input - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
end

function tux.utils.setTooltip (text, align)
    align = align or "auto"

    assert (type (text) == "string", "Provided tooltip is not a string")

    if tux.tooltip.text == "" then
        tux.tooltip.text = text
        tux.tooltip.align = align
        return true
    else
        return false
    end
end

function tux.utils.setTooltipFont (fontid, fsize)
    tux.tooltip.fontid = fontid
    tux.tooltip.fsize = fsize
end

function tux.utils.getTooltipFont ()
    return tux.tooltip.font
end

-- TODO: Refactor this to just use the origin functionality
function tux.utils.setScreenSize (w, h)
    tux.screen.w = w
    tux.screen.h = h

    local baseOrigin = tux.layoutData.originStack[1]
    baseOrigin.w = w
    baseOrigin.h = h
end

function tux.utils.setScreenScale (scale)
    assert(type(scale) == "number", "Provided value is not a number")

    tux.layoutData.originStack[1].scale = scale
end

function tux.utils.setMaxFontsCached (value)
    assert (type (value) == "number", "Provided value is not a number")

    tux.maxFontsCached = value
end

function tux.utils.errorForUnclearedStacks (value)
    assert (type (value) == "boolean", "Provided value is not a boolean")

    tux.errorForUnclearedStacks = value
end

function tux.utils.getLastState ()
    return tux.cursor.lastState
end

function tux.utils.getLastActualState ()
    return tux.cursor.lastActualState
end
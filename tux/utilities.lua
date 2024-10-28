local libPath = (...):match("(.+)%.[^%.]+$") .. "."

local tux = require (libPath .. "tux")
local copyTable = require (libPath .. "helpers.copyTable")

function tux.utils.registerComponent (component, override)
    if component.id == nil then
        error ("Attempt to register a component without an ID")
    end

    if tux.comp[component.id] == nil or override == true then
        -- Copy component attributes to new table
        local newComp = copyTable (component)

        -- Create show function
        function newComp.show (opt, x, y, w, h)
            opt = opt or {}
            assert (type (opt) == "table", "Attempt to use a non-table value for UI item options")

            -- Update position and size
            opt.x, opt.y, opt.w, opt.h = x, y, w, h

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

function tux.utils.registerFont (id, filepath)
    local status, font = pcall (love.graphics.newFont, filepath)
    assert (status == true and font ~= nil, "Provided filepath does not correspond to a valid font object")
    
    tux.fontObjCache[id] = filepath
end

-- Overwrites an entry in the font size cache with a custom font object
-- It does NOT create a new font with the provided size
function tux.utils.overwriteCustomFont (id, size, font)
    if tux.fontSizeCache[id] == nil then
        tux.fontSizeCache[id] = {}
    end

    tux.fontSizeCache[id][size] = font
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
    tux.fontObjCache[id] = nil
end

function tux.utils.removeAllFonts ()
    tux.fontObjCache = {}

end

function tux.utils.getDefaultColors ()
    return copyTable (tux.defaultColors)
end

function tux.utils.setDefaultColors (colors)
    assert (type (colors) == "table", "Attempt to use a non-table value for default colors")

    tux.defaultColors = copyTable (colors)
end

function tux.utils.getDefaultSlices ()
    return copyTable (tux.defaultSlices)
end

function tux.utils.setDefaultSlices (slices)
    assert (type (slices) == "table", "Attempt to use a non-table value for default slices")
    
    tux.defaultSlices = copyTable (slices)
end

function tux.utils.getDefaultFont ()
    return tux.defaultFont
end

function tux.utils.getDefaultFontSize ()
    return tux.defaultFontSize
end

function tux.utils.setDefaultFont (fontid)
    assert (tux.fontObjCache[fontid] ~= nil, "Invalid font ID")

    tux.core.processFont (fontid, tux.defaultFontSize)
    tux.defaultFont = fontid
end

function tux.utils.setDefaultFontSize (fsize)
    tux.defaultFontSize = fsize
end

function tux.utils.clearFontCache ()
    tux.fontSizeCache = {}
end

function tux.utils.getFontCacheSize ()
    local total = 0

    for k, v in pairs (tux.fontSizeCache) do
        total = total + 1
    end

    return total
end

function tux.utils.getDebugMode ()
    return tux.debugMode
end

function tux.utils.setDebugMode (mode)
    assert (type (mode) == "boolean", "Provided debug mode is not a boolean value")
    tux.debugMode = mode
end

function tux.utils.denormalize (value, min, max)
    -- TODO
    error ("Function is not yet implemented")
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
    tux.tooltip.font = tux.core.processFont (fontid, fsize)
end

function tux.utils.getTooltipFont ()
    return tux.tooltip.font
end

function tux.utils.setScreenSize (w, h)
    tux.screen.w = w
    tux.screen.h = h
end
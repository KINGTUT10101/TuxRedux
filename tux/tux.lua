local utf8 = require("utf8")

local tux
local defaultSlice = {}
function defaultSlice:draw (x, y, w, h)
    tux.core.rect ("fill", x, y, w, h)
end

tux = {
    renderQueue = {}, -- Contains UI items that will be rendered in love.draw ()
    layoutData = {
        origin = {}, -- Origin of the current layout
        padding = {}, -- Current layout padding values
        grid = {}, -- Size of each cell in the current layout
        position = {}, -- Position in the grid
    }, -- Contains data used by the layout system
    screen = {
        w = love.graphics.getWidth (),
        h = love.graphics.getHeight (),
    },
    comp = {}, -- Contains the registered UI components
    cursor = {
        x = 0,
        y = 0,
        lockedX = 0,
        lockedY = 0,
        lastX = 0,
        lastY = 0,
        lastLockedX = 0,
        lastLockedY = 0,
        isDown = false,
        wasDown = false,
        currentState = "normal",
        lastState = "normal",
    },
    pressedKey = nil,
    specialPressedKey = nil,
    debugMode = false,
    tooltip = {
        text = "",
        align = "",
        font = nil,
    },

    defaultFont = "default",
    defaultFontSize = 12,
    defaultColors = {
        normal = {
            fg = {1, 1, 1, 1},
            bg = {0.5, 0.5, 0.5, 1},
        },
        hover = {
            fg = {1, 1, 1, 1},
            bg = {0.75, 0.75, 0.75, 1},
        },
        held = {
            fg = {1, 1, 1, 1},
            bg = {0.25, 0.25, 0.25, 1},
        },
    }, -- Default colors for buttons
    defaultSlices = {
        normal = defaultSlice,
        hover = defaultSlice,
        held = defaultSlice,
    }, -- Default slices for buttons
    fontSizeCache = {}, -- Used to save font objects for various font sizes
    fontObjCache = {}, -- Saves the registered fonts

    core = {}, -- Internal functions not meant for outside use
    callbacks = {}, -- Used in LOVE2Ds callbacks to keep tux updated
    show = {}, -- Contains the show functions for the registered UI components
    utils = {}, -- Various utility functions useful to library users
    layout = {}, -- Layout functions for positioning UI items
}

-- Allows users to call the show functions for the components through tux.show
setmetatable (tux.show, {
    __index = function (self, key)
        if tux.comp[key] == nil then
            error ("Component not found: " .. key)

            return
        else
            return tux.comp[key].show
        end
    end,
})

--[[==========
    HELPERS
============]]
local function copyTable (orig)
    local orig_type = type(orig)
    local copy

    if orig_type == 'table' then
        copy = {}

        for orig_key, orig_value in next, orig, nil do
            copy[copyTable(orig_key)] = copyTable(orig_value)
        end
        setmetatable(copy, copyTable(getmetatable(orig)))

    -- Number, string, boolean, etc
    else
        copy = orig
    end

    return copy
end

--[[==========
    CORE
============]]

function tux.core.unpackCoords (tbl)
    return tbl.x, tbl.y, tbl.w, tbl.h
end

function tux.core.unpackPadding (paddingTbl)
    if paddingTbl == nil then
        return 0, 0, 0, 0
    end

    local padAll = paddingTbl.padAll or 0
	local padX, padY = paddingTbl.padX or padAll, paddingTbl.padY or padAll
	local padLeft, padRight = paddingTbl.padLeft or padX, paddingTbl.padRight or padX
	local padTop, padBottom = paddingTbl.padTop or padY, paddingTbl.padBottom or padY

    return padLeft, padRight, padTop, padBottom
end

function tux.core.getCursorPosition ()
    return tux.cursor.x, tux.cursor.y
end

function tux.core.getLastCursorPosition ()
    return tux.cursor.lastX, tux.cursor.lastY
end

function tux.core.getLockedCursorPosition ()
    return tux.cursor.lockedX, tux.cursor.lockedY
end

function tux.core.getLastLockedCursorPosition ()
    return tux.cursor.lastLockedX, tux.cursor.lastLockedY
end

function tux.core.getRelativePosition (x, y, rx, ry)
    return rx - x, ry - y
end

function tux.core.isDown ()
    return tux.cursor.isDown
end

function tux.core.wasDown ()
    return tux.cursor.wasDown
end

function tux.core.registerHitbox (x, y, w, h)
    local newValue = "normal"

    if tux.cursor.currentState == "normal" then
        local mx, my = tux.cursor.lockedX, tux.cursor.lockedY

        -- Check if cursor is in bounds
        if x <= mx and mx <= x + w and y <= my and my <= y + h then
            newValue = "hover"
            
            -- Check if cursor is down
            if tux.cursor.isDown == true then
                newValue = "held"
                
                if tux.cursor.wasDown == false then
                    newValue = "start"
                else
                    newValue = "held"
                end
            else
                if tux.cursor.wasDown == true then
                    newValue = "end"
                else
                    newValue = "hover"
                end
            end
        end

        tux.cursor.currentState = newValue
    end

    return newValue
end

-- Checks if the provided area 
function tux.core.checkLastHitbox (x, y, w, h)
    local mx, my = tux.cursor.lastLockedX, tux.cursor.lastLockedY

    if x <= mx and mx <= x + w and y <= my and my <= y + h then

        return tux.cursor.lastState
    end

    return "normal"
end

function tux.core.getLastState ()
    return tux.cursor.lastState
end

function tux.core.rect (...)
    love.graphics.rectangle (...)
end

function tux.core.slice (slices, colors, state, x, y, w, h)
    state = tux.core.getRenderState (state)
    tux.core.setColorForState (colors, "bg", state)

    -- Provided slices
    if slices ~= nil and slices[state] ~= nil then
        slices[state]:draw (x, y, w, h)
    
    -- Default slices
    else
        tux.defaultSlices[state]:draw (x, y, w, h)
    end

    tux.core.debugBoundary (state, x, y, w, h)
end

--- Renders the tooltip if one has been provided with tux.utils.setTooltip this frame.
-- Tooltips will appear above all UI items
function tux.core.tooltip ()
	if tux.tooltip.text ~= "" then
		local text = tux.tooltip.text
        local align = tux.tooltip.align
		local mx, my = tux.core.getCursorPosition ()

        tux.core.setFont (tux.tooltip.font)
		local font = love.graphics.getFont ()
		local fontH = font:getHeight ()
		local textWidth = font:getWidth (text)

		-- Chooses the alignment that will keep the full text on screen
		-- Defaults to right alignment if there is room
		if align == "auto" then
			local screenWidth = tux.screen.w

			if mx + textWidth > screenWidth then
				align = "center"

				if mx + (textWidth / 2) > screenWidth then
					align = "left"
				end
			else
				align = "right"
			end
		end

		-- Draws the rectangle
		love.graphics.setColor (0, 0, 0, 0.75)
		if align == "left" then
			love.graphics.rectangle ("fill", mx - textWidth, my - fontH, textWidth, fontH)
		elseif align == "right" then
			love.graphics.rectangle ("fill", mx, my - fontH, textWidth, fontH)
		else
			love.graphics.rectangle ("fill", mx - (textWidth / 2), my - fontH, textWidth, fontH)
		end

		-- Draws the text
		love.graphics.setColor (1, 1, 1, 1)
		if align == "left" then
			love.graphics.print (text, mx - textWidth, my - fontH)
		elseif align == "right" then
			love.graphics.print (text, mx, my - fontH)
		else
			love.graphics.print (text, mx - (textWidth / 2), my - fontH)
		end
	end
end

function tux.core.debugBoundary (state, x, y, w, h)
    if tux.debugMode == true then
        if state == "normal" then
            love.graphics.setColor (1, 1, 1, 1)
        elseif state == "hover" then
            love.graphics.setColor (1, 1, 0, 1)
        else
            love.graphics.setColor (1, 0, 0, 1)
        end
        tux.core.rect ("line", x, y, w, h)
    end
end

function tux.core.processFont (fontid, fsize)
    fontid = fontid or tux.defaultFont
    fsize = fsize or tux.defaultFontSize

    -- Check cache for font of this size
    if tux.fontSizeCache[fontid] == nil or tux.fontSizeCache[fontid][fsize] == nil then
        if tux.fontSizeCache[fontid] == nil then
            tux.fontSizeCache[fontid] = {}
        end
        
        -- Generate new font object and add to cache
        if fontid == "default" then
            tux.fontSizeCache[fontid][fsize] = love.graphics.newFont (fsize)
        else
            tux.fontSizeCache[fontid][fsize] = love.graphics.newFont (tux.fontObjCache[fontid], fsize)
        end

        return tux.fontSizeCache[fontid][fsize]
    else
        -- Use font from cache
        return tux.fontSizeCache[fontid][fsize]
    end
end

-- If a font object is provided, it will render it directly and ignore the font size
function tux.core.setFont (font, fsize)
    if type (font) == "userdata" then
        love.graphics.setFont (font)
    else
        love.graphics.setFont (tux.core.processFont (font, fsize))
    end
end

-- TODO: Update the padding system to use the one from the original tux
function tux.core.print (text, align, valign, padding, fontid, fsize, colors, state, x, y, w, h)
    if text ~= nil and text ~= "" then
        align = align or "center"
        valign = valign or "center"
        padding = padding or {}

        tux.core.setFont (fontid, fsize)
        font = love.graphics.getFont ()
        
        local offsetY
        local padLeft, padRight, padTop, padBottom = tux.core.unpackPadding (padding)

        x = x + padLeft
        y = y + padTop
        w = w - (padLeft + padRight)
        h = h - (padTop + padBottom)

        local maxTextWidth, wrappedText = font:getWrap(text, w)
        local fontH = font:getHeight()
        local textH = fontH * #wrappedText

        if textH > h then
            text = ""
            textH = fontH * math.floor (h / fontH)
            for i = 1, math.floor (h / fontH) do
                text = text .. wrappedText[i] .. "\n"
            end
        end

        if valign == "top" then
            offsetY = padTop
        elseif valign == "bottom" then
            offsetY = h - textH - padBottom
        else
            offsetY = (h - textH) / 2
        end
        
        tux.core.setColorForState (colors, "fg", state)
        love.graphics.printf (text, x, y + offsetY, w, align)
    end
end

function tux.core.drawImage (image, iscale, align, valign, padding, x, y, w, h)
	if image ~= nil then
		local offsetX, offsetY
        local padLeft, padRight, padTop, padBottom = tux.core.unpackPadding (padding)
		local iw, ih = image:getDimensions ()
		iw = iw * (iscale or 1)
		ih = ih * (iscale or 1)

		-- Images will render on the opposite side of the text
		if valign == "bottom" then
			offsetY = padTop
		elseif valign == "top" then
			offsetY = h - ih - padBottom
		else
			offsetY = h / 2 - ih / 2
		end

		if align == "right" then
			offsetX = padLeft
		elseif align == "left" then
			offsetX = w - iw - padRight
		else
			offsetX = w / 2 - iw / 2
		end
		
        love.graphics.setColor (1, 1, 1, 1)
		love.graphics.draw (image, x + offsetX, y + offsetY, nil, iscale, iscale)
	end
end

function tux.core.setColorForState (colors, colorType, state)
    state = tux.core.getRenderState (state)
    if colors ~= nil then
        if type (colors[1]) == "number" then
            if colorType == "bg" then
                love.graphics.setColor (colors)
            else
                love.graphics.setColor (tux.defaultColors[state][colorType])
            end
        else
            love.graphics.setColor (colors[state][colorType] or tux.defaultColors[state][colorType])
        end
    else
        love.graphics.setColor (tux.defaultColors[state][colorType])
    end
end

local renderStateLookup = {
    normal = "normal",
    hover = "hover",
    held = "held",
    start = "held",
    ["end"] = "held",
}
function tux.core.getRenderState (state)
    return renderStateLookup[state] or "normal"
end

function tux.core.concatTypedText (text)
    if tux.pressedKey ~= nil then
        return text .. (tux.pressedKey or "")
    else
        local specialKey = tux.specialPressedKey

        if specialKey == "backspace" then
            local byteoffset = utf8.offset(text, -1)

            if byteoffset then
                -- Removes the last UTF-8 character.
                -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
                return string.sub(text, 1, byteoffset - 1)
            end
        end

        return text
    end
end

-- TODO?: change to grab keyboard focus, only allow it to be called once per frame, and reset state after every frame
function tux.core.setKeyboardFocus (state)
    if love.system.getOS () == "Android" or love.system.getOS () == "iOS" then
        love.keyboard.setTextInput (state)
    end
end

--[[==========
    CALLBACKS
============]]

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

--[[==========
    UTILITIES
============]]

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

--[[==========
    LAYOUT
============]]

function tux.layout.pushOrigin (x, y, w, h)
    
end

function tux.layout.popOrigin ()

end

return tux
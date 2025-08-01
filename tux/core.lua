local libPath = (...):match("(.+)%.[^%.]+$") .. "."

local tux = require (libPath .. "tux")
local utf8 = require("utf8")

function tux.core.unpackCoords (tbl, ...)
    return tbl.x, tbl.y, tbl.w, tbl.h, ...
end

function tux.core.unpackPadding (processedPadding, ...)
    return processedPadding.left, processedPadding.right, processedPadding.top, processedPadding.bottom, ...
end

function tux.core.unpackMargins (processedMargins, ...)
    return processedMargins.left, processedMargins.right, processedMargins.top, processedMargins.bottom, ...
end

function tux.core.applyPadding (processedPaddingTbl, x, y, w, h, ...)
    return
        x + processedPaddingTbl.left,
        y + processedPaddingTbl.top,
        w - processedPaddingTbl.left - processedPaddingTbl.right,
        h - processedPaddingTbl.top - processedPaddingTbl.bottom,
        ...
end

function tux.core.processPadding (padding)
    padding = padding or {}

    local padAll = padding.all or 0
	local padX, padY = padding.x or padAll, padding.y or padAll
	local padLeft, padRight = padding.left or padX, padding.right or padX
	local padTop, padBottom = padding.top or padY, padding.bottom or padY

    padding.left = padLeft
    padding.right = padRight
    padding.top = padTop
    padding.bottom = padBottom

    return padding
end

function tux.core.processMargins (margins)
    margins = margins or {}
    local marginAll = margins.all or 0
	local marginX, marginY = margins.x or marginAll, margins.y or marginAll
	local marginLeft, marginRight = margins.left or marginX, margins.right or marginX
	local marginTop, marginBottom = margins.top or marginY, margins.bottom or marginY

    margins.left = marginLeft
    margins.right = marginRight
    margins.top = marginTop
    margins.bottom = marginBottom

    return margins
end

-- Applies the current origin to the provided coordinates
function tux.core.applyOrigin (opt, oalign, voalign, x, y, w, h)
    local origin = tux.layoutData.originStack[#tux.layoutData.originStack]

    oalign = oalign or origin.defaultoalign
    voalign = voalign or origin.defaultvoalign
    opt = opt or {}


    local scale = origin.scale
    x, y, w, h = x * scale, y * scale, w * scale, h * scale

    if oalign == "right" then
        x = origin.x + origin.w + x
    elseif oalign == "center" then
        x = origin.x + origin.w * 0.5 - w * 0.5 + x
    else
        x = origin.x + x
    end

    if voalign == "bottom" then
        y = origin.y + origin.h + y
    elseif voalign == "center" then
        y = origin.y + origin.h * 0.5 - h * 0.5 + y
    else
        y = origin.y + y
    end

    return x, y, w, h
end

function tux.core.applyAlignment ()
    -- TODO
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

function tux.core.determineState (mx, my, x, y, w, h)
    local state = "normal"

    -- Check if cursor is in bounds
    if x <= mx and mx <= x + w and y <= my and my <= y + h then
        state = "hover"
        
        -- Check if cursor is down
        if tux.cursor.isDown == true then
            state = "held"
            
            if tux.cursor.wasDown == false then
                state = "start"
            else
                state = "held"
            end
        else
            if tux.cursor.wasDown == true then
                state = "end"
            else
                state = "hover"
            end
        end
    end

    return state
end

function tux.core.registerHitbox (x, y, w, h, passthru, sounds)
    passthru = passthru or false

    local state = "normal"
    local actualState = "normal"

    if tux.cursor.currentState == "normal" then
        state = tux.core.determineState (tux.cursor.lockedX, tux.cursor.lockedY, x, y, w, h)
        actualState = tux.core.determineState (tux.cursor.x, tux.cursor.y, x, y, w, h)

        if passthru ~= true then
            tux.cursor.currentState = state
            tux.cursor.currentActualState = actualState
        end
    end

    -- Use default sounds
    if type (sounds) == "table" and sounds[state] ~= nil and sounds[state] ~= "none" then
        sounds[state]:play ()
    elseif (type (sounds) ~= "table" or sounds[state] == nil) and tux.sounds[state] ~= nil then
        tux.sounds[state]:play ()
    end

    return state
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

        tux.core.setFont (tux.tooltip.fontid, tux.tooltip.fsize)
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
        local origLineWidth = love.graphics.getLineWidth ()
        love.graphics.setLineWidth(tux.debugLineWidth)

        if state == "normal" then
            love.graphics.setColor (1, 1, 1, 1)
        elseif state == "hover" then
            love.graphics.setColor (1, 1, 0, 1)
        else
            love.graphics.setColor (1, 0, 0, 1)
        end
        tux.core.rect ("line", x, y, w, h)
        love.graphics.setLineWidth (origLineWidth)
    end
end

function tux.core.processFont (fontid, fsize)
    fontid = fontid or tux.defaultFont
    
    if tux.fonts[fontid] ~= nil then
        if tux.fonts[fontid].defaultSize == nil then
            tux.fonts[fontid].defaultSize = tux.defaultFontSize
        end
        fsize = fsize or tux.fonts[fontid].defaultSize
    else
        fsize = fsize or tux.defaultFontSize
    end

    -- Check cache for font of this size
    if tux.fonts[fontid] == nil or tux.fonts[fontid][fsize] == nil then
        if tux.fonts[fontid] == nil then
            tux.fonts[fontid] = {}
        end
        
        -- Generate new font object and add to cache
        if fontid == "default" then
            tux.fonts[fontid][fsize] = love.graphics.newFont (fsize)
        else
            tux.fonts[fontid][fsize] = love.graphics.newFont (tux.fonts[fontid].path, fsize)
        end

        tux.fontCacheSize = tux.fontCacheSize + 1

        return tux.fonts[fontid][fsize]
    else
        -- Use font from cache
        return tux.fonts[fontid][fsize]
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
function tux.core.print (text, align, valign, processedPadding, fontid, fsize, colors, state, x, y, w, h)
    if text ~= nil and text ~= "" then
        align = align or "center"
        valign = valign or "center"
        processedPadding = processedPadding or {}

        tux.core.setFont (fontid, fsize)
        local font = love.graphics.getFont ()
        
        local offsetY
        local padLeft, padRight, padTop, padBottom = tux.core.unpackPadding (processedPadding)

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

-- Creates a scalar for the provided size based on the base size and type.
function tux.core.getScale(size, baseSize, maxSize)
    local scale

    -- Provided size
    if type(size) == "number" then
        scale = size / baseSize

    -- Percentage of max size
    elseif type(size) == "string" and size:match("^%d+%%$") then
        scale = tonumber(size:sub(1, -2)) / 100 * maxSize / baseSize

    -- Provided scale
    elseif type(size) == "string" and size:match("^%d+x$") then
        scale = tonumber(size:sub(1, -2))

    -- Default or no size provided
    else
        scale = 1
    end

    if baseSize * scale > maxSize then
        scale = maxSize / baseSize
    end

    return scale
end

-- Supports images and tables. However, tables must support obj:getDimensions() and obj:draw(...) with the same parameters as the corresponding methods for LOVE Image objects
function tux.core.drawImage (image, align, valign, processedPadding, iw, ih, x, y, w, h)
	if image ~= nil then
		local offsetX, offsetY
		local biw, bih = image:getDimensions ()
        x, y, w, h = tux.core.applyPadding (processedPadding, x, y, w, h)

		local iwscale = tux.core.getScale (iw, biw, w)
		local ihscale = tux.core.getScale (ih, bih, h)

		-- Images will render on the opposite side of the text
		if valign == "bottom" then
			offsetY = 0
		elseif valign == "top" then
			offsetY = h - ih
		else
			offsetY = h / 2 - ih / 2
		end

		if align == "right" then
			offsetX = 0
		elseif align == "left" then
			offsetX = w - iw
		else
			offsetX = w / 2 - iw / 2
		end
		
        love.graphics.setColor (1, 1, 1, 1)
        if image.draw == nil then
            love.graphics.draw (image, x + offsetX, y + offsetY, nil, iwscale, ihscale)
        else
            image:draw (x + offsetX, y + offsetY, nil, iwscale, ihscale)
        end
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
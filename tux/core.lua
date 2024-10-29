local libPath = (...):match("(.+)%.[^%.]+$") .. "."

local tux = require (libPath .. "tux")
local utf8 = require("utf8")

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
    if tux.fonts[fontid] == nil or tux.fonts[fontid][fsize] == nil then
        if tux.fonts[fontid] == nil then
            tux.fonts[fontid] = {}
        end
        
        -- Generate new font object and add to cache
        if fontid == "default" then
            tux.fonts[fontid][fsize] = love.graphics.newFont (fsize)
        else
            tux.fonts[fontid][fsize] = love.graphics.newFont (tux.fontObjCache[fontid], fsize)
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
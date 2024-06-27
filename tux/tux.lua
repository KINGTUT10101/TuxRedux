local defaultSlice = {}
function defaultSlice:draw (x, y, w, h)
    love.graphics.rectangle ("fill", x, y, w, h)
end

local tux = {
    renderQueue = {}, -- Contains UI items that will be rendered in love.draw ()
    layoutData = {
        origin = {}, -- Origin of the current layout
        padding = {}, -- Current layout padding values
        grid = {}, -- Size of each cell in the current layout
        position = {}, -- Position in the grid
    }, -- Contains data used by the layout system
    comp = {}, -- Contains the registered UI components
    cursor = {
        x = 0,
        y = 0,
        isDown = false,
        detectedThisFrame = false
    },

    defaultFont = nil,
    defaultColors = {
        normal = {
            fg = {0, 0, 0, 1},
            bg = {0.5, 0.5, 0.5, 1},
        },
        hover = {
            fg = {0, 0, 0, 1},
            bg = {0.75, 0.75, 0.75, 1},
        },
        hit = {
            fg = {0, 0, 0, 1},
            bg = {0.25, 0.25, 0.25, 1},
        },
    }, -- Default colors for buttons
    defaultSlices = {
        normal = defaultSlice,
        hover = defaultSlice,
        hit = defaultSlice,
    }, -- Default slices for buttons

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

function tux.core.registerHitbox (x, y, w, h)
    if tux.cursor.detectedThisFrame == false then
        local mx, my = tux.cursor.x, tux.cursor.y

        -- Check if cursor is in bounds
        if x <= mx and mx <= x + w and y <= my and my <= y + h then
            tux.cursor.detectedThisFrame = true
            
            -- Check if cursor is down
            if tux.cursor.isDown == true then
                return "hit"
            else
                return "hover"
            end
        end
    end

    return "normal"
end

function tux.core.rect (slices, colors, state, x, y, w, h)
    tux.core.setColorForState (colors, "bg", state)

    -- Provided slices
    if slices ~= nil and slices[state] ~= nil then
        slices[state]:draw (x, y, w, h)
    
    -- Default slices
    else
        tux.defaultSlices[state]:draw (x, y, w, h)
    end
end

function tux.core.setFont (font)
    love.graphics.setFont (font or tux.defaultFont)
end

function tux.core.print (text, align, valign, padding, font, colors, state, x, y, w, h)
    text = text or ""
    padding = padding or {}
    font = font or love.graphics.getFont()
	
    tux.core.setFont (font)
	local offsetY
	local padEdgeX, padEdgeY = padding.edgeX or 0, padding.edgeY or 0

	x = x + padEdgeX
	y = y + padEdgeY
	w = w - (2 * padEdgeX)
	h = h - (2 * padEdgeY)

	local _, wrappedText = font:getWrap(text, w)
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
        offsetY = padEdgeY
    elseif valign == "bottom" then
        offsetY = h - textH - padEdgeY
    else
        offsetY = h / 2 - textH / 2
    end
    
    tux.core.setColorForState (colors, "fg", state)
    love.graphics.printf (text, x, y + offsetY, w, align or "center")
end

function tux.core.drawImage (image, scale, align, valign, padding, x, y, w, h)
	if image ~= nil then
		local offsetX, offsetY
		local padEdgeX, padEdgeY = padding.padEdgeX or 0, padding.padEdgeY or 0
		local iw, ih = image:getDimensions ()
		iw = iw * (scale or 1)
		ih = ih * (scale or 1)

		-- Images will render on the opposite side of the text
		if valign == "bottom" then
			offsetY = padEdgeY
		elseif valign == "top" then
			offsetY = h - ih - padEdgeY
		else
			offsetY = h / 2 - ih / 2
		end

		if align == "right" then
			offsetX = padEdgeX
		elseif align == "left" then
			offsetX = w - iw - padEdgeX
		else
			offsetX = w / 2 - iw / 2
		end
		
		love.graphics.draw (image, x + offsetX, y + offsetY, nil, scale, scale)
	end
end

function tux.core.setColorForState (colors, colorType, state)
    if colors ~= nil then
        if type (colors[1]) == "number" then
            love.graphics.setColor (colors)
        else
            love.graphics.setColor (colors[state][colorType] or tux.defaultColors[state][colorType])
        end
    else
        love.graphics.setColor (tux.defaultColors[state][colorType])
    end
end

--[[==========
    CALLBACKS
============]]

-- This should run BEFORE you show any UI items
function tux.callbacks.update (dt, mx, my, isDown)
    if mx == nil or my == nil then
        tux.cursor.x, tux.cursor.y = love.mouse.getPosition ()
    else
        tux.cursor.x, tux.cursor.y = mx, my
    end
    if isDown == nil then
        tux.cursor.isDown = love.mouse.isDown (1)
    else
        tux.cursor.isDown = isDown
    end
    tux.cursor.detectedThisFrame = false
end

function tux.callbacks.draw ()
    local origFont = love.graphics.getFont ()
    local queue = tux.renderQueue
    for i = #queue, 1, -1 do
        queue[i].draw (tux, queue[i].opt)
        queue[i] = nil
    end
    love.graphics.setFont (origFont)
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
            opt.x, opt.y, opt.w, opt.h = x, y, w, h

            local returnVal = newComp.init (tux, opt)

            tux.renderQueue[#tux.renderQueue + 1] = {
                opt = opt,
                draw = newComp.draw,
            }

            return returnVal
        end

        tux.comp[component.id] = newComp
    end
end

function tux.utils.removeComponent (id)
    tux.comp[id] = nil
end

function tux.utils.removeAllComponents ()
    tux.comp = {}
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

function tux.utils.setDefaultFont (font)
    tux.defaultFont = font
end

function tux.utils.getDefaultFont ()
    return tux.defaultFont
end

--[[==========
    LAYOUT
============]]

function tux.layout.pushOrigin (x, y, w, h)

end

function tux.layout.popOrigin ()

end

return tux
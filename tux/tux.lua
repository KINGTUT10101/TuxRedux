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
    detectedThisFrame = false, -- Tracks if the mouse was over a UI item in the current frame

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

function tux.core.getMouseState ()

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

function tux.callbacks.draw ()
    local origFont = love.graphics.getFont ()
    local queue = tux.renderQueue
    for i = #queue, 1, -1 do
        queue[i].draw (tux, queue[i].opt)
        queue[i] = nil
    end
    love.graphics.setFont (origFont)

    tux.detectedThisFrame = false
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

            opt.state = "normal"

            -- TODO: set mouse position and determine which component was clicked

            -- Run the item's init function
            tux.renderQueue[#tux.renderQueue + 1] = {
                opt = newComp.init (tux, opt),
                draw = newComp.draw,
            }
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

--[[==========
    LAYOUT
============]]

return tux
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


return tux
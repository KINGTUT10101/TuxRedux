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
    }, -- Tracks info about the user's cursor, which is used to determine component states
    pressedKey = nil, -- The last pressed key
    specialPressedKey = nil, -- The last pressed special key (like delete)
    debugMode = false, -- If true, the library will show the special debug view
    tooltip = {
        text = "",
        align = "",
        fontid = "default",
        fsize = 12,
    }, -- Tracks info about the tooltip in the current frame

    defaultFont = "default", -- The font ID of the default font to use
    defaultFontSize = 12, -- The default font size
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

    fonts = {}, -- Contains info about registered fonts and stores cached fonts for each size
    fontCacheSize = 0, -- Tracks how many font objects have been cached
    maxFontsCached = math.huge, -- Maximum limit for the number of cached fonts

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

-- Sets up the font cache for the default font
tux.fonts.default = {
    filepath = "",
    cache = {},
}
setmetatable (tux.fonts.default.cache, {
    __index = function (self, size)
        -- Generate new font from default LOVE2D font
        self[size] = love.graphics.newFont (size)

        return self[size]
    end,
})

return tux
local libPath = (...):match("(.+)%.[^%.]+$") .. "."
local copyTable = require(libPath .. "helpers.copyTable")

local tux = require(libPath .. "tux")

--- Expands a two-color tuple into a full color table.
--- @param fg table<number> The foreground color (table or tuple)
--- @param bg table<number> The background color (table or tuple)
--- @return table<string, table<number>> colors A table containing the expanded color values
function tux.style.expandColor (fg, bg)
    local state = {
        fg = copyTable (fg),
        bg = copyTable (bg),
    }
    return {
        normal  = state,
        hover = state,
        held  = state,
    }
end
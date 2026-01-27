local libPath = (...):match("(.+)%.[^%.]+$"):match("(.+)%.[^%.]+$") .. "."
local tux = require (libPath .. "tux")

local component = {
    id = "label",
    override = false,
}

-- Handles initialization logic after a state has been determined
-- This is where the bulk of your logic should happen
function component.init (opt)
    return opt.state -- The state will be returned by tux.show
end

-- Renders the UI item within love.draw()
function component.draw (opt)
    
end

return component
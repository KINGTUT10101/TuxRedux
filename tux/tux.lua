local tux = {
    renderQueue = {}, -- Contains UI items that will be rendered in love.draw ()
    layoutData = {
        origin = {}, -- Origin of the current layout
        padding = {}, -- Current layout padding values
        grid = {}, -- Size of each cell in the current layout
        position = {}, -- Position in the grid
    }, -- Contains data used by the layout system
    clickedItemID = nil, -- Tracks the ID of the first-clicked item from the current frame
    comp = {}, -- Contains the registered UI components

    core = {}, -- Internal functions not meant for outside use
    callbacks = {}, -- Used in LOVE2Ds callbacks to keep tux updated
    show = {}, -- Contains the show functions for the registered UI components
    utils = {}, -- Various utility functions useful to library users
    layout = {}, -- Layout functions for positioning UI items
}

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
 
function tux.callbacks.draw ()
    local queue = tux.renderQueue
    for i = 1, #queue do
        queue[i].draw (queue[i].data)
        queue[i] = nil
    end
end

function tux.utils.registerComponent (component, override)
    if component.id == nil then
        error ("Attempt to register a component without an ID")
    end

    if tux.comp[component.id] == nil or override == true then
        -- Copy component attributes to new table
        local newComp = {
            id = component.id,
            init = component.init,
            draw = component.draw,
        }

        -- Create show function
        function newComp.show (opt, x, y, w, h)
            opt.x, opt.y, opt.w, opt.h = x, y, w, h

            -- Run the item's init function
            tux.renderQueue[#tux.renderQueue + 1] = {
                data = newComp.init (opt),
                draw = newComp.draw,
            }
        end

        tux.comp[component.id] = newComp
    end
end

function tux.utils.removeComponent (id)
    tux.comp[id] = nil
end

return tux
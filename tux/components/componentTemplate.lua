local component = {
    id = "label",
}

-- Handles initialization logic before a state is determined
-- Show your other UI components here if you're making a compound component
function component.preInit (tux, opt)
    

    return opt
end

-- Handles initialization logic after a state has been determined
-- This is where the bulk of your logic should happen
function component.init (tux, opt)
    return opt.state -- The state will be returned by tux.show
end

-- Renders the UI item within love.draw()
function component.draw (tux, opt)
    
end

return component
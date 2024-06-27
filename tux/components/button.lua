local component = {
    id = "button",
}

function component.init (tux, opt)
    opt.state = tux.core.registerHitbox (tux.core.unpackCoords (opt))

    return opt.state
end

function component.draw (tux, opt)
    -- Code for rendering the button goes here
    tux.core.rect (opt.slices, opt.colors, opt.state, tux.core.unpackCoords (opt))
end

return component
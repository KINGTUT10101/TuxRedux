local component = {
    id = "slider",
}

function component.init (tux, opt)
    assert (opt.data ~= nil, "Persistent UI item was not provided with a data table")

    opt.hh = math.min (opt.w / 2, opt.h)
    opt.hw = opt.hh / 4
    opt.state = tux.core.registerHitbox (tux.core.unpackCoords (opt))

    -- Update data value
    local edgePadding = opt.hw / 2
    local startX = opt.x + edgePadding
    local endX = opt.x + opt.w - edgePadding
    if opt.state == "held" then
        local mx, my = tux.core.getCursorPosition ()
        local rmx = mx - startX

        opt.data.value = math.max (math.min (rmx / (endX - startX), 1), 0)
    end
    opt.hx = opt.data.value * (endX - startX) + opt.x

    return opt.state
end

function component.draw (tux, opt)
    tux.core.debugBoundary (opt.state, tux.core.unpackCoords (opt))
    
    -- Slider bar
    local edgePadding = opt.hw / 2
    local barW = opt.w - edgePadding * 2
    local barH = opt.h / 6
    tux.core.setColorForState (opt.colors, "fg", opt.state)
    tux.core.rect ("fill", opt.x + edgePadding, opt.y + opt.h*0.5 - barH*0.5, barW, barH)

    -- Slider handle
    if opt.style == "round" then
        tux.core.rect ("fill", opt.hx, opt.y + opt.h*0.5 - opt.hh*0.5, opt.hw, opt.hh, opt.hw * 0.25, opt.hh / 4)
    else
        tux.core.rect ("fill", opt.hx, opt.y + opt.h*0.5 - opt.hh*0.5, opt.hw, opt.hh)
    end
end

return component
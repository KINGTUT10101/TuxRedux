local component = {
    id = "slider",
}
local edgePadding = 0.05

function component.init (tux, opt)
    assert (opt.data ~= nil, "Persistent UI item was not provided with a data table")

    opt.hh = math.min (opt.w / 2, opt.h)
    opt.hw = opt.hh / 4
    opt.state = tux.core.registerHitbox (tux.core.unpackCoords (opt))

    -- Update data value
    if opt.state == "held" then
        local startX = opt.x + opt.hw*0.5
        local endX = startX + opt.w - opt.hw
        local mx, my = tux.core.getCursorPosition ()
        local rmx = mx - startX

        opt.value = rmx / (endX - startX)
    end

    return opt.state
end

function component.draw (tux, opt)
    tux.core.debugBoundary (opt.state, tux.core.unpackCoords (opt))
    
    -- Slider bar
    local barW = opt.w * (1 - edgePadding*2)
    local barH = opt.h / 6
    tux.core.setColorForState (opt.colors, "fg", opt.state)
    love.graphics.rectangle ("fill", opt.x + opt.w*edgePadding, opt.y + opt.h*0.5 - barH*0.5, barW, barH)

    -- Slider handle
    love.graphics.rectangle ("fill", opt.x, opt.y + opt.h*0.5 - opt.hh*0.5, opt.hw, opt.hh)
end

return component
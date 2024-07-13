local component = {
    id = "toggle",
}
local edgePadding = 0.05

function component.init (tux, opt)
    assert (opt.data ~= nil, "Persistent UI item was not provided with a data table")

    opt.state = tux.core.registerHitbox (tux.core.unpackCoords (opt))

    opt.size = math.min (opt.w / 2, opt.h)

    if opt.state == "end" then
        opt.data.checked = not opt.data.checked
    end

    return opt.state
end

function component.draw (tux, opt)
    tux.core.debugBoundary (opt.state, tux.core.unpackCoords (opt))

    -- Toggle bar
    local barW = opt.w * (1 - edgePadding*2)
    local barH = opt.size / 2
    if opt.checkColor ~= nil then
        love.graphics.setColor (opt.checkColor[(opt.data.checked) and "on" or "off"])
    else
        tux.core.setColorForState (opt.colors, "fg", opt.state)
    end
    if opt.style == "round" then
        tux.core.rect ("fill", opt.x + opt.w*edgePadding, opt.y + opt.h*0.5 - barH*0.5, barW, barH, barW*0.15, barH*0.5)
    else
        tux.core.rect ("fill", opt.x + opt.w*edgePadding, opt.y + opt.h*0.5 - barH*0.5, barW, barH)
    end

    -- Toggle ball
    tux.core.setColorForState (opt.colors, "fg", opt.state)
    if opt.style == "round" then
        local radius = opt.size / 2
        local ballX = (opt.data.checked) and opt.x + opt.w - radius or opt.x + radius
        love.graphics.circle ("fill", ballX, opt.y + opt.h*0.5, radius)
    else
        local rectX = (opt.data.checked) and opt.x + opt.w - opt.size or opt.x
        love.graphics.rectangle ("fill", rectX, opt.y + opt.h * 0.5 - opt.size * 0.5, opt.size, opt.size)
    end
end

return component
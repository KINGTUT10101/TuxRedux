local component = {
    id = "checkbox",
}

function component.init (tux, opt)
    assert (opt.data ~= nil, "Persistent UI item was not provided with a data table")

    opt.size = math.min (opt.w, opt.h)
    opt.cx = opt.x + (opt.w / 2) - (opt.size / 2)
    opt.cy = opt.y + (opt.h / 2) - (opt.size / 2)

    opt.state = tux.core.registerHitbox (tux.core.unpackCoords (opt))

    if opt.state == "end" then
        opt.data.checked = not opt.data.checked
    end

    return opt.state
end

function component.draw (tux, opt)
    tux.core.slice (opt.slices, opt.colors, opt.state, tux.core.unpackCoords (opt))

    if opt.data.checked == true then
        local origStyle = love.graphics.getLineStyle ()
        local origWidth = love.graphics.getLineWidth ()
        local origJoin = love.graphics.getLineJoin ()
        love.graphics.setLineStyle('smooth')
        love.graphics.setLineWidth(opt.size * 3 / 25)
        love.graphics.setLineJoin("bevel")
        
        tux.core.setColorForState (opt.colors, "fg", "normal")

        -- Use an X to mark the check
        if opt.mark == "cross" then
            love.graphics.line (opt.cx+opt.size*.2, opt.cy+opt.size*.2, opt.cx+opt.size*.8, opt.cy+opt.size*.8)
            love.graphics.line (opt.cx+opt.size*.8, opt.cy+opt.size*.2, opt.cx+opt.size*.2, opt.cy+opt.size*.8)
        -- Use a checkmark to mark the check
        else
            love.graphics.line(opt.cx+opt.size*.2, opt.cy+opt.size*.55, opt.cx+opt.size*.45, opt.cy+opt.size*.75, opt.cx+opt.size*.8, opt.cy+opt.size*.2)
        end

        love.graphics.setLineStyle(origStyle)
		love.graphics.setLineWidth(origWidth)
		love.graphics.setLineJoin(origJoin)
    end
end

return component
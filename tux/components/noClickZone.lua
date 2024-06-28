local component = {
    id = "noClickZone",
}

function component.init (tux, opt)
    opt.state = tux.core.registerHitbox (tux.core.unpackCoords (opt))

    return opt.state
end

function component.draw (tux, opt)
    if tux.utils.getDebugMode () == true then
        love.graphics.setColor (0.25, 0.25, 0.25, 0.5)
        love.graphics.rectangle ("fill", tux.core.unpackCoords (opt))

        if opt.state == "normal" then
            love.graphics.setColor (1, 1, 1, 1)
        elseif opt.state == "hover" then
            love.graphics.setColor (1, 1, 0, 1)
        else
            love.graphics.setColor (1, 0, 0, 1)
        end
        love.graphics.rectangle ("line", tux.core.unpackCoords (opt))
    end
end

return component
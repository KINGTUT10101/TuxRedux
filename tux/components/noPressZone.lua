local component = {
    id = "noPressZone",
}

function component.init (tux, opt)
    opt.state = tux.core.registerHitbox (tux.core.unpackCoords (opt, opt.passthru))

    return opt.state
end

function component.draw (tux, opt)
    if tux.utils.getDebugMode () == true then
        love.graphics.setColor (0.25, 0.25, 0.25, 0.5)
        tux.core.rect ("fill", tux.core.unpackCoords (opt))

        tux.core.print(opt.text, opt.align, opt.valign, opt.padding, opt.font, opt.fsize, {1, 1, 1, 1}, "normal", tux.core.unpackCoords(opt))

        tux.core.debugBoundary (opt.state, tux.core.unpackCoords (opt))

        tux.core.drawImage(opt.image, opt.iscale, opt.align, opt.valign, opt.padding, tux.core.unpackCoords(opt))
    end
end

return component
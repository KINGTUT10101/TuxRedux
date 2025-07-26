local component = {
    id = "debugBox",
    override = false,
}

function component.init(tux, opt)
    opt.state = tux.core.registerHitbox(tux.core.unpackCoords(opt, true, opt.sounds))

    return tux.utils.getDebugMode() and opt.state or "normal"
end

function component.draw(tux, opt)
    if tux.utils.getDebugMode() then
        tux.core.print(opt.text, opt.align, opt.valign, opt.padding, opt.font, opt.fsize, {1, 1, 1, 1}, "normal", tux.core.unpackCoords(opt))
        tux.core.drawImage(opt.image, opt.align, opt.valign, opt.padding, opt.iw, opt.ih, tux.core.unpackCoords(opt))
    end

    tux.core.debugBoundary(opt.state, tux.core.unpackCoords(opt))
end

return component

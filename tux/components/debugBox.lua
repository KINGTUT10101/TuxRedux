local component = {
    id = "debugBox",
}

function component.init (tux, opt)
    opt.state = tux.core.registerHitbox (tux.core.unpackCoords (opt, true))

    return opt.state
end

function component.draw (tux, opt)
    tux.core.print (opt.text, opt.align, opt.valign, opt.padding, opt.font, opt.fsize, opt.colors, "normal", tux.core.unpackCoords (opt))

    tux.core.debugBoundary (opt.state, tux.core.unpackCoords (opt))
end

return component
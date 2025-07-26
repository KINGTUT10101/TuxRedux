local component = {
    id = "label",
    override = false,
}

function component.init (tux, opt)
    opt.state = tux.core.registerHitbox (tux.core.unpackCoords (opt, opt.passthru, opt.sounds))

    return opt.state
end

function component.draw (tux, opt)
    tux.core.slice (opt.slices, opt.colors, "normal", tux.core.unpackCoords (opt))
    tux.core.drawImage (opt.image, opt.align, opt.valign, opt.padding, opt.iw, opt.ih, tux.core.unpackCoords (opt))
    tux.core.print (opt.text, opt.align, opt.valign, opt.padding, opt.font, opt.fsize, opt.colors, "normal", tux.core.unpackCoords (opt))

    tux.core.debugBoundary (opt.state, tux.core.unpackCoords (opt))
end

return component
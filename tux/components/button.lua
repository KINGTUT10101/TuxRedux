local component = {
    id = "button",
}

function component.init (tux, opt)
    opt.state = tux.core.registerHitbox (tux.core.unpackCoords (opt, opt.passthru))

    -- local origin = tux.layoutData.originStack[#tux.layoutData.originStack]
    -- print("Origin stack size: ", #tux.layoutData.originStack)
    -- print("Raw comp coords: ", tux.core.unpackCoords(opt))
    -- print("Btn origin coords: ", tux.core.unpackCoords(origin, origin.scale))
    -- print ("------------")

    return opt.state
end

function component.draw (tux, opt)
    tux.core.slice (opt.slices, opt.colors, opt.state, tux.core.unpackCoords (opt))
    tux.core.drawImage (opt.image, opt.iscale, opt.align, opt.valign, opt.padding, tux.core.unpackCoords (opt))
    tux.core.print (opt.text, opt.align, opt.valign, opt.padding, opt.font, opt.fsize, opt.colors, "normal", tux.core.unpackCoords (opt))

    -- print (tux.core.unpackCoords (opt))
end

return component
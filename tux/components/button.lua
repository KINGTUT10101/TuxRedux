local libPath = (...):match("(.+)%.[^%.]+$"):match("(.+)%.[^%.]+$") .. "."
local tux = require (libPath .. "tux")

local component = {
    id = "button",
    override = false,
}

function component.init (opt)
    opt.state = tux.core.registerHitbox (tux.core.unpackCoords (opt, opt.passthru, opt.sounds))

    return opt.state
end

function component.draw (opt)
    tux.core.slice (opt.slices, opt.colors, opt.state, tux.core.unpackCoords (opt))
    tux.core.drawImage (opt.image, opt.align, opt.valign, opt.padding, opt.iw, opt.ih, tux.core.unpackCoords (opt))
    tux.core.print (opt.text, opt.align, opt.valign, opt.padding, opt.font, opt.fsize, opt.colors, "normal", tux.core.unpackCoords (opt))
end

return component
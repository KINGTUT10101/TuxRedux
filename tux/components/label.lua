local component = {
    id = "label",
}

function component.init (tux, opt)
    -- Modify and initialize the options table here as needed

    return opt
end

function component.draw (tux, opt)
    tux.core.rect (opt.slices, opt.colors, "normal", tux.core.unpackCoords (opt))
end

return component
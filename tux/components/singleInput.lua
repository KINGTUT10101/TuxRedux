local component = {
    id = "singleInput",
}

function component.init (tux, opt)
    assert (opt.data ~= nil, "Persistent UI item was not provided with a data table")
    
    opt.state = tux.core.registerHitbox (tux.core.unpackCoords (opt))

    return opt.state -- The state will be returned by tux.show
end

function component.draw (tux, opt)
    
end

return component
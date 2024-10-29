local component = {
    id = "singleInput",
}

function component.init (tux, opt)
    assert (opt.data ~= nil, "Persistent UI item was not provided with a data table")
    
    opt.defaultText = opt.defaultText or ""
    if opt.clearButton == true then
        opt.clearButtonSize = math.min (opt.w, opt.h) / 2

        if tux.core.registerHitbox (opt.x + opt.w - (opt.clearButtonSize * 1.25), opt.y, opt.clearButtonSize * 1.25, opt.h) == "end" then
            opt.data.text = opt.defaultText
        end
    end

    opt.highlight = opt.highlight or "fill" -- Options are none, fill, and line
    opt.state = tux.core.registerHitbox (tux.core.unpackCoords (opt))

    -- Check if input should be in focus
    if opt.state == "start" then
        opt.data.inFocus = true

    elseif opt.data.inFocus == true then
        if tux.core.wasDown () and tux.core.checkLastHitbox (tux.core.unpackCoords (opt)) == "normal" then
            opt.data.inFocus = false
        end
    else
        opt.data.inFocus = false
    end

    -- Update text
    if opt.data.inFocus == true then
        opt.data.text = tux.core.concatTypedText (opt.data.text)
    end

    tux.core.setKeyboardFocus (opt.data.inFocus)

    return opt.state -- The state will be returned by tux.show
end

function component.draw (tux, opt)
    local textToShow

    -- Background
    tux.core.slice (opt.slices, opt.colors, opt.state, tux.core.unpackCoords (opt))

    -- Highlight
    if opt.highlight ~= "none" and opt.data.inFocus == true then
        love.graphics.setColor (1, 1, 1, (opt.highlight == "fill") and 0.35 or 1)
        tux.core.rect (opt.highlight, tux.core.unpackCoords (opt))
    end

    -- Text
    if opt.data.text == nil or opt.data.text == "" then
        textToShow = opt.blankText or ""
    else
        textToShow = opt.data.text
    end
    tux.core.print (textToShow, "left", "center", opt.padding, opt.font, opt.fsize, opt.colors, "normal", tux.core.unpackCoords (opt))

    -- Clear button
    if opt.clearButton == true and textToShow ~= opt.defaultText then
        local size = opt.clearButtonSize
        local x, y = opt.x + opt.w - (size * 1.25), opt.y + size / 2

        local origStyle = love.graphics.getLineStyle ()
        local origWidth = love.graphics.getLineWidth ()
        local origJoin = love.graphics.getLineJoin ()
        love.graphics.setLineStyle('smooth')
        love.graphics.setLineWidth(size * 2 / 25)
        love.graphics.setLineJoin("bevel")

        tux.core.setColorForState (opt.colors, "fg", "normal")
        love.graphics.line (x+size*.2, y+size*.2, x+size*.8, y+size*.8)
        love.graphics.line (x+size*.8, y+size*.2, x+size*.2, y+size*.8)

        love.graphics.setLineStyle(origStyle)
		love.graphics.setLineWidth(origWidth)
		love.graphics.setLineJoin(origJoin)
    end
end

return component
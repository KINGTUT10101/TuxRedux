tux.layout.pushGrid ({
    primaryAxis = "y"
}, 600, 375)

tux.show.button ({
    text = "1",
}, tux.layout.nextItem (nil, 25, 25))

tux.show.button ({
    text = "2",
}, tux.layout.nextItem (nil, 25, 25))

tux.show.button ({
    text = "3",
}, tux.layout.nextItem (nil, 25, 25))

tux.layout.nextLine ()

tux.show.button ({
    text = "4",
}, tux.layout.nextItem ({margins = {top = 25, left = 0}}, 25, 50))

tux.show.button ({
    text = "5",
}, tux.layout.nextItem (nil, 25, 25))

tux.layout.popGrid ()
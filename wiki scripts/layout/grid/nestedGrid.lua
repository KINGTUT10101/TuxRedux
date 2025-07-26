tux.layout.pushGrid ({}, 600, 375) -- Push grid #1

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
tux.layout.pushNestedGrid ({}, {}, 50, 50) -- Push grid #2

tux.show.button ({
    text = "4a",
}, tux.layout.nextItem ({}, 25, 25))

tux.show.button({
    text = "4b",
}, tux.layout.nextItem({}, 25, 25))

tux.layout.nextLine ()

tux.show.button({
    text = "4c",
}, tux.layout.nextItem({}, 25, 25))

tux.show.button({
    text = "4d",
}, tux.layout.nextItem({}, 25, 25))

tux.layout.popGrid () -- Pop grid #2

tux.show.button ({
    text = "5",
}, tux.layout.nextItem (nil, 25, 25))

tux.layout.popGrid () -- Pop grid #1
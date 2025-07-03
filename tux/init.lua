local libPath = (...) .. "." -- The path leading up to the location of the tux library

-- Load tux itself
require (libPath .. "core")
require (libPath .. "callbacks")
require (libPath .. "utilities")
require (libPath .. "layout")
require (libPath .. "style")
local tux = require (libPath .. "tux")

-- Load and register the default UI components
tux.utils.registerComponent (require (libPath .. "components.button"))
tux.utils.registerComponent (require (libPath .. "components.label"))
tux.utils.registerComponent (require (libPath .. "components.noPressZone"))
tux.utils.registerComponent (require (libPath .. "components.checkbox"))
tux.utils.registerComponent (require (libPath .. "components.toggle"))
tux.utils.registerComponent (require (libPath .. "components.slider"))
tux.utils.registerComponent (require (libPath .. "components.singleInput"))
tux.utils.registerComponent (require (libPath .. "components.debugBox"))

return tux
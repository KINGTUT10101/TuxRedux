local libPath = (...) .. "." -- The path leading up to the location of the tux library

-- Load tux itself
local tux = require (libPath .. "tux")

-- Load and register the default UI components
tux.utils.registerComponent (require (libPath .. "components.button"), false)
tux.utils.registerComponent (require (libPath .. "components.label"), false)
tux.utils.registerComponent (require (libPath .. "components.noPressZone"), false)
tux.utils.registerComponent (require (libPath .. "components.checkbox"), false)
tux.utils.registerComponent (require (libPath .. "components.toggle"), false)
tux.utils.registerComponent (require (libPath .. "components.slider"), false)
tux.utils.registerComponent (require (libPath .. "components.singleInput"), false)

return tux
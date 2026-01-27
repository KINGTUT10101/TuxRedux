local libPath = (...) .. "." -- The path leading up to the location of the tux library

-- Load tux itself
require (libPath .. "core")
require (libPath .. "callbacks")
require (libPath .. "utilities")
require (libPath .. "layout")
require (libPath .. "style")
local tux = require (libPath .. "tux")

return tux
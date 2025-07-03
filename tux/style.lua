local libPath = (...):match("(.+)%.[^%.]+$") .. "."
local copyTable = require(libPath .. "helpers.copyTable")

local tux = require(libPath .. "tux")

local libPath = (...):match("(.+)%.[^%.]+$") .. "."
local copyTable = require (libPath .. "copyTable")

local function defaultCallback (newValue)
    return newValue == nil
end

-- Sets default values for an object based on the provided keys/values in the default object
-- You can provide a callback to the function to determine what values are reset to default
local function setDefaults (defaultObj, newObj, callback)
    callback = callback or defaultCallback

    for key, value in pairs (defaultObj) do
        if defaultCallback (newObj[key]) then
            newObj[key] = copyTable (value)
        end
    end
end

return setDefaults
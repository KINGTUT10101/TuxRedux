--- Recursively copies a table, including nested tables.
--- Handles nested tables and avoids copying keys listed in a blacklist.
--- @param input any The table to copy
--- @param blacklist table<any, boolean|table>? A table containing keys to exclude from copying. Keys can map to:
--- - `boolean`: Exclude the key entirely when set to true.
--- - `table`: Sub-blacklist for recursive filtering.
--- @return table A deep copy of the input table
local function copyTable(input, blacklist)
    blacklist = blacklist or {}
    
    -- If input is not a table, return it as is
    if type(input) ~= "table" then
        return input
    end
    
    local result = {}
    
    -- Iterate through the input table
    for key, value in pairs(input) do
        -- Skip keys that are explicitly blacklisted
        if blacklist[key] ~= true then
            if type(value) == "table" then
                -- Recursively copy nested tables
                result[key] = copyTable(value, (type(blacklist[key]) == "table") and blacklist[key] or {})
            else
                -- Copy primitive values directly
                result[key] = value
            end
        end
    end
    
    return result
end

return copyTable
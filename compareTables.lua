local function compareTables(key, value, compValue, ignoreRefs, blacklist)
    key = key or "Base"
    blacklist = blacklist or {}
    ignoreRefs = ignoreRefs or false

    -- Ensure the passed argument is always a valid table
    if blacklist[key] ~= true then
        if type(value) == "table" then
            if value ~= compValue and ignoreRefs == false then
                print(type(value), key, value, compValue)
            end
            for childKey, childValue in pairs(value) do
                compareTables(childKey, childValue, compValue[childKey], (type(blacklist[key]) == "table") and blacklist[key] or {})
            end
        elseif value ~= compValue and (type(value) ~= "function" or ignoreRefs == false) then
            print(type(value), key, value, compValue)
        end
    end
end

return compareTables

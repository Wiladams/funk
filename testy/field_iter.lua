--[[
field_iter

Consume an iterator of bytes, produce an iteration 
of lua strings.

This is a pure functional iterator, which means it does 
not cause side effects on the data source, and is thus
suitable for things like splits, chains, cycles, and the like

    This iterator will return blank strings instead of terminate
    with a null when the string length is 0
--]]

local ffi = require("ffi")
local cctype = require("wordplay.cctype")
local isspace = cctype.isspace

local function field_iter_gen(param, state)

    -- check if end of data
    if state >= param.size then
        if state > param.size then
            return nil;
        end

        -- there is a special state where there is a delimeter
        -- in the last possible position before end of data
        --  in this one case we want to return a blank string
        -- rather than nothing
        if param.data[param.size-1] == param.delimeter then
            return state+1, ""
        end

        -- we're definitely done, so stop
        return nil;
    end

    -- mark the beginning and start consuming until we hit the delimeter
    local starting = state
    local startPtr = param.data + state

    -- while we haven't hit the end of data
    while state < param.size do
        if param.delimeter == param.data[state] then
            break;
        end

        state = state + 1
    end

    -- figure out how long the string is
    local len = state - starting

    local value
    if len < 1 then
        value = ""
    else
        value = ffi.string(startPtr, len)
    end

    return state+1, value
end

local function field_iter(delim, bs)
    return field_iter_gen, {data=bs.data, size=bs.size, delimeter=delim or string.byte(',')}, bs.cursor
end

return field_iter

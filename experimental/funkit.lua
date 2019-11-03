--[[
    Functional programming toolkit

    Inspired by luafun, but using coroutine iterator model, just for kicks

    The fundamental structure is a producer/consumer thing.
]]

local exports = {}

function exports.receive (prod)
    --print("receive, pulling")
    local results = {coroutine.resume(prod)}
    local status = results[1]
    --print("receive, status: ", status)
    if not status then return nil end
    
    table.remove(results, 1)
    
    return status, unpack(results)
end
  
function exports.send (...)
    coroutine.yield(...)
end


--[[
    Simple iterators
]]
local function string_iter(str)
    return coroutine.create(function()
        for idx=1,#str do
            send(string.sub(str, idx, idx))
        end
    end)
end

function table_iter(tbl)
    return coroutine.create(function ()
        for i, value in ipairs(tbl) do
            send(value)
        end
    end)
end


--[[
    REDUCING
]]
-- return true if all items from producer
-- match the predicate
function exports.all(predicate, prod)
    local iter = prod
    if type(prod) == "string" then
        iter = string_iter(prod)
    elseif type(prod) == "table" then
        iter = table_iter(prod)
    end

    while coroutine.status(iter) ~= "dead" do
        local results = {receive(iter)}
        if not #results == 0 then break end

        if not predicate(unpack(results)) then
            return false
        end
    end

    return true;
end
exports.every = exports.all

function exports.any(predicate, prod)
    local iter = prod
    if type(prod) == "string" then
        iter = string_iter(prod)
    elseif type(prod) == "table" then
        iter = table_iter(prod)
    end

    while coroutine.status(iter) ~= "dead" do
        if predicate(receive(iter)) then
            return true
        end
    end

    return false;
end

-- return a count of elements in iterator
function exports.length(prod)
    local counter = 0;
    while(receive(prod)) do
        counter = counter + 1;
    end
    
    return counter;
end

function exports.maximum(prod)
    local iter = prod
    if type(prod) == "string" then
        iter = string_iter(prod)
    elseif type(prod) == "table" then
        iter = table_iter(prod)
    end

    local maxval = nil
    while coroutine.status(iter) ~= "dead" do
        local value = receive(iter)
        if not maxval then maxval = value end
        if value > maxval then maxval = value end
    end

    return maxval
end

function exports.minimum(prod)
    local iter = prod
    if type(prod) == "string" then
        iter = string_iter(prod)
    elseif type(prod) == "table" then
        iter = table_iter(prod)
    end

    local retval = nil
    while coroutine.status(iter) ~= "dead" do
        local value = receive(iter)
        if not retval then retval = value end
        if value < retval then retval = value end
    end

    return retval
end



function exports.totable(prod)
    local tbl = {}

    local iter = prod
    if type(prod) == "string" then
        iter = string_iter(prod)
    elseif type(prod) == "table" then
        iter = table_iter(prod)
    end

    while coroutine.status(iter) ~= "dead" do
        table.insert(tbl, receive(iter))
    end

    return tbl
end

--[[
    SLICING
]]

-- return the 'nth' iterated value
-- Consumer, Produce single value
function exports.nth(n, prod)
    return coroutine.create(function()
        local counter = 0
        while coroutine.status(prod) ~= "dead" do
            counter = counter + 1
            if counter == n then
                send(receive(prod))
                break
            else
                receive(prod)
            end
        end
    end)
end

function exports.head(source)
    return exports.nth(1, source)
end

exports.car = exports.head


--[[
    FILTERING
]]

function exports.grep(predicate, source)
    local fun = predicate
    if type(predicate) == "string" then
        fun = function(str) return string.find(str, predicate) ~= nil end
    end 

    return exports.filter(fun, source)
end

return exports

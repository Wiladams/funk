--[[
    Query operators in the style of LINQ

    Paired with funk.lua, you've got funk and finq, which
    rhymes with linq!
]]

local namespace = require("wordplay.namespace")
local finqns = namespace()
local funk = require("wordplay.funk")
-- add it to our local namespace
funk(finqns)

local exports = {}
local methods = {}

--[[
Data Sources
    from
]]
local function from(obj, param, state)
    return iter(obj, param, state)
end

--[[
Filtering Operators
    where
    OfType
--]]
exports.where = funk.filter


--[[
Join Operators
    Join
    GroupJoin
--]]

--[[
Projection
    Select
    SelectMany
--]]

--[[
Sorting
    OrderBy
    OrderByDescending
    ThenBy
    ThenByDescending
    Reverse

Grouping
    GroupBy
    ToLookup

Conversions
    AsEnumerable
    AsQueryable
    Cast
    OfType
    ToArray
    ToDictionary
    ToList
    ToLookup
--]]
local function ofType(kind, gen, param, state)
    return filter(function(x) return type(x) == kind end, gen, param, state)
end
exports.ofType = export1(ofType)
methods.ofType = method1(ofType)

--[[
Concatenation
    Concat

Aggregation
    Aggregate
    Average
    Count
    LonCount
    Max
    Min
    Sum

Quantifier
    All
    Any
    Contains

Partition
    Skip
    SkipWhile
    Take
    TakeWhile

Generation
    DefaultEmpty
    Empty
    Range
    Repeat
--]]

--[[
Set Operations
    Distinct
    Except
    Intersect
    Union
--]]
--[[
    distinct

    A reducer that takes the parameters, assumes they
    are values, and returns a table of only those unique values.

    This should work whenever the values of the generator
    can serve as keys in a lua table.

    This is similar to totable(), except it only returns the 
    unique values.
]]
local function unique(gen, param, state)
    local tab = {} 
    local val

    while true do
        state, val = gen(param, state)
        if state == nil then
            break;
        end
        if not tab[val] then
            tab[val] = 1
        else
            tab[val] = tab[val] + 1
        end
    end

    return tab
end
exports.distinct = export0(distinct)
methods.distinct = method0(distinct)

--[[
EQuality
    SequenceEqual
--]]

--[[
Element Operators
    ElementAt
    ElementAtOrDefault
    First
    FirstOrDefault
    Last
    LastOrDefault
    Single
    SingleOrDefault
    DefaultIfEmpty
    
--]]
exports.First = funk.head;
exports.Last = funk.tail;

-- Prepping for export
setmetatable(exports, {
    __call = function(self, tbl)
        tbl = tbl or _G

        for k,v in pairs(exports) do
            rawset(tbl, k, v)
        end

        return self
    end;

    __index = {
        _VERSION     = {1,0};
        _URL         = 'http://github.com/wiladams/wordplay';
        _LICENSE     = 'MIT';
        _DESCRIPTION = 'function integrated query in lua';
    }
})

return exports
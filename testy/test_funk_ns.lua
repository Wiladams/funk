--[[
    Test putting funk into a local namespace
]]
package.path = "../?.lua;"..package.path

local namespace = require("namespace")
local funk = require("wordplay.funk")

local localNS = namespace()
funk(localNS)

each(print,range(5))

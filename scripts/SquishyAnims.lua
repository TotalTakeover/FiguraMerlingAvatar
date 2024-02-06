-- Required scripts
local parts  = require("lib.GroupIndex")(models)
local squapi = require("lib.SquAPI")

squapi.ear(parts.LeftEar, parts.RightEar, false, _, 0.35, true, 1, 0.05, 0.05)
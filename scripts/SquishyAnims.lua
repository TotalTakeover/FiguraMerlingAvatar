-- Required scripts
local model  = require("scripts.ModelParts")
local squapi = require("lib.SquAPI")

squapi.ear(model.ears.LeftEar, model.ears.RightEar, false, _, 0.35, true, 1, 0.05, 0.05)
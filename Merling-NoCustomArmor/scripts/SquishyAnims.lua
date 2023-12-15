-- Model setup
local model     = models.Merling
local modelRoot = model.Player

-- Squishy API animations
local squapi = require("lib.SquAPI")

-- Ear animations
local ears = modelRoot.Head.Ears
squapi.ear(ears.LeftEar, ears.RightEar, false, _, 0.35, _, 1, 0.05, 0.05)
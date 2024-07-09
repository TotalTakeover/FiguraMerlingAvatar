-- Required scripts
local merlingParts = require("lib.GroupIndex")(models.models.Merling)
local squapi       = require("lib.SquAPI")
local average      = require("lib.Average")

-- Squishy ears
local ears = squapi.ear:new(
	merlingParts.LeftEar,
	merlingParts.RightEar,
	0.35,  -- Range Multiplier (0.35)
	true,  -- Horizontal (true)
	1,     -- Bend Strength (1)
	false, -- Do Flick (false)
	400,   -- Flick Chance (400)
	0.1,   -- Stiffness (0.1)
	0.9    -- Bounce (0.9)
)

-- Tails table
local tailParts = {
	
	merlingParts.Tail1,
	merlingParts.Tail2,
	merlingParts.Tail3,
	merlingParts.Tail4,
	merlingParts.Fluke
	
}

-- Squishy tail
local tail = squapi.tail:new(
	tailParts,
	0,     -- Intensity X (0)
	0,     -- Intensity Y (0)
	0,     -- Speed X (0)
	0,     -- Speed Y (0)
	2,     -- Bend (2)
	1,     -- Velocity Push (1)
	0,     -- Initial Offset (0)
	0,     -- Seg Offset (0)
	0.015, -- Stiffness (0.015)
	0.95,  -- Bounce (0.95)
	60,    -- Fly Offset (60)
	-15,   -- Down Limit (-15)
	25     -- Up Limit (25)
)

local bend = tail.bendStrength
function events.TICK()
	
	-- Control the intensity of the tail function based on its scale
	local scale = (-math.abs(average(merlingParts.Tail1:getScale():unpack()) - 0.5) + 0.5) * 2
	tail.bendStrength  = scale * bend
	
end
-- Required scripts
local merlingParts = require("lib.GroupIndex")(models.models.Merling)
local squapi       = require("lib.SquAPI")
local average      = require("lib.Average")

-- Squishy ears
squapi.ear(
	merlingParts.LeftEar,
	merlingParts.RightEar,
	false, -- Do Flick (False)
	400,   -- Flick Chance (400)
	0.35,  -- Range Multiplier (0.35)
	true,  -- Horizontal Ears (True)
	1,     -- Bend Strength (1)
	0.05,  -- Stiffness (0.05)
	0.05   -- Bounce (0.05)
)

-- Tails table
local tail = {
	
	merlingParts.Tail1,
	merlingParts.Tail2,
	merlingParts.Tail3,
	merlingParts.Tail4,
	merlingParts.Fluke
	
}

-- Squishy tail
squapi.tails(
	tail,
	2.5,   -- Intensity (2.5)
	0,     -- Intensity Y (0)
	0,     -- Intensity X (0)
	0,     -- Speed Y (0)
	0,     -- Speed X (0)
	0.25,  -- Tail Vel Bend (0.25)
	0,     -- Initial Tail Offset (0)
	0.5,   -- Seg Offset Multiplier (0.5)
	0.01,  -- Stiffness (0.01)
	0.025, -- Bounce (0.025)
	60,    -- Fly Offset (60)
	4,     -- Down Limit (4)
	6      -- Up Limit (6)
)    

function events.RENDER(delta, context)
	
	-- Control the intensity of the tail function based on its scale
	local scale = (-math.abs(average(merlingParts.Tail1:getScale():unpack()) - 0.5) + 0.5) * 2
	for _, part in ipairs(tail) do
		part:offsetRot(part:getOffsetRot() * scale)
	end
	
end
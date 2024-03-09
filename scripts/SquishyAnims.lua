-- Required scripts
local merlingParts = require("lib.GroupIndex")(models.models.Merling)
local squapi       = require("lib.SquAPI")
local average      = require("lib.Average")

-- Ear function
squapi.ear(merlingParts.LeftEar, merlingParts.RightEar, false, _, 0.35, true, 1, 0.05, 0.05)

-- Tails table
local tail = {
	
	merlingParts.Tail1,
	merlingParts.Tail2,
	merlingParts.Tail3,
	merlingParts.Tail4,
	merlingParts.Fluke
	
}

-- Tail function
squapi.tails(tail,
	2.5,   --intensity
	0,     --tailintensityY
	0,     --tailintensityX
	0,     --tailYSpeed
	0,     --tailXSpeed
	0.25,  --tailVelBend
	nil,   --initialTailOffset
	0.5,   --segOffsetMultiplier
	0.01,  --tailStiff
	0.025, --tailBounce
	60,    --tailFlyOffset
	4,     --downlimit
	6      --uplimit
)

function events.RENDER(delta, context)
	
	-- Control the intensity of the tail function based on its scale
	local scale = (-math.abs(average(merlingParts.Tail1:getScale():unpack()) - 0.5) + 0.5) * 2
	for _, part in ipairs(tail) do
		part:offsetRot(part:getOffsetRot() * scale)
	end
	
end
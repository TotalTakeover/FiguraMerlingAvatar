-- Required scripts
local parts  = require("lib.GroupIndex")(models)
local squapi = require("lib.SquAPI")

-- Get the average of a vector
local function average(vec)
	
	local sum = 0
	for _, v in ipairs{vec:unpack()} do
		sum = sum + v
	end
	return sum / #vec
	
end

-- Ear function
squapi.ear(parts.LeftEar, parts.RightEar, false, _, 0.35, true, 1, 0.05, 0.05)

-- Tails table
local tail = {
	parts.Tail1,
	parts.Tail2,
	parts.Tail3,
	parts.Tail4,
	parts.Fluke
}

-- Tail function
squapi.tails(tail,
	nil,   --intensity
	5,     --tailintensityY
	25,    --tailintensityX
	1,     --tailYSpeed
	0.5,   --tailXSpeed
	nil,   --tailVelBend
	nil,   --initialTailOffset
	0.5,   --segOffsetMultiplier
	0.01,  --tailStiff
	0.025, --tailBounce
	60,    --tailFlyOffset
	5,     --downlimit
	7.5    --uplimit
)

function events.RENDER(delta, context)
	
	-- Control the intensity of the tail function based on its scale
	local scale = (-math.abs(average(parts.Tail1:getScale()) - 0.5) + 0.5) * 2
	for _, part in ipairs(tail) do
		part:offsetRot(part:getOffsetRot() * scale)
	end
	
end
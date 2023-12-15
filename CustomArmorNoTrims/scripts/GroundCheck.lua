-- Setup table
local t  = {}
t.ground = true

-- Synced variables setup
local sV = require("scripts.SyncedVariables")

function events.TICK()
	-- Variable setup
	local pos    = player:getPos() - vec(0, 0.2, 0)
	local hitbox = math.max(player:getBoundingBox().x / 2, 0)
	local blocks = world.getBlocks(pos - vec(hitbox, 0, hitbox), pos + vec(hitbox, 0, hitbox))
	
	-- Check if ANY blocks have collision
	for _, block in ipairs(blocks) do
		if block:hasCollision() and block:getID() ~= "minecraft:light" and not sV.cF then
			t.ground = true
			break
		else
			t.ground = false
		end
	end
end

-- Return table
return t
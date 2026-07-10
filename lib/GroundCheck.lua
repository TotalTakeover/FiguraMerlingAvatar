-- Check for overlap
local function overlaps(box1Min, box1Max, box2Min, box2Max)
	return not (box1Max.x <= box2Min.x or box2Max.x <= box1Min.x or
				box1Max.y <= box2Min.y or box2Max.y <= box1Min.y or
				box1Max.z <= box2Min.z or box2Max.z <= box1Min.z)
end

-- How much beyond the hitbox it should check
local clearance = 0.2

-- Check if the player's hitbox is on the ground, and therefore the player is on the ground
local function onGround()
	
	-- Saves instructions should the game already make the detection.
	if player:isOnGround() then
		return true
	end
	
	-- Variables
	local pos = player:getPos()
	local hitbox = player:getBoundingBox()
	
	-- Calc min and max positions
	local min = pos - hitbox.x_z / 2 - vec(0, clearance, 0)
	local max = pos + hitbox.x_z / 2
	local searchMin = min:copy():floor()
	local searchMax = max:copy():floor()
	
	-- Check through blocks to see if any positions are colliding
	for x = searchMin.x, searchMax.x do
		for y = searchMin.y, searchMax.y do
			for z = searchMin.z, searchMax.z do
				
				-- Get block
				local blockPos = vec(x,y,z)
				local block = world.getBlockState(blockPos)
				local boxes = block:getCollisionShape()
				
				-- If box has any collisions, check for overlap
				for i = 1, #boxes do
					local box = boxes[i]
					if overlaps(min, max, blockPos + box[1], blockPos + box[2]) then
						return true
					end
				end
				
			end
		end
	end
	
	-- If theres no collisions, return false
	return false
	
end

-- Return function
return onGround
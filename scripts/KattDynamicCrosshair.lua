--================================================--
--   _  ___ _    ____      _    ___   __  ____    --
--  | |/ (_) |_ / ___|__ _| |_ / _ \ / /_|___ \   --
--  | ' /| | __| |   / _` | __| (_) | '_ \ __) |  --
--  | . \| | |_| |__| (_| | |_ \__, | (_) / __/   --
--  |_|\_\_|\__|\____\__,_|\__|  /_/ \___/_____|  --
--                                                --
--================================================--

--v2.3 (HEAVILY MODIFIED BY TOTAL)
local pos = vectors.vec3()

local function validBlock(block)
	
	return block and not block:isAir()
	
end

function events.ENTITY_INIT()
	
	pos:set(player:getPos())
	
end

function events.RENDER(delta, context)
	if context == "FIRST_PERSON" then
		
		local entity, entityPos = player:getTargetedEntity(host:getReachDistance())
		local block, blockPos = player:getTargetedBlock(true, host:getReachDistance())
		local deltaDeltaPos = player:getPos(delta) - player:getPos()
		
		pos:set(entity and entityPos:add(deltaDeltaPos) or
			validBlock(block) and blockPos:add(deltaDeltaPos) or
			player:getPos(delta):add(0, player:getEyeHeight())
				:add(player:getLookDir() * host:getReachDistance())
				:add(renderer:getEyeOffset())
		)
		
		local screenSpace = vectors.worldToScreenSpace(pos)
		local coords = screenSpace.xy:add(0, 0):mul(client:getScaledWindowSize()):div(2, 2)
		
		renderer:crosshairOffset(coords)
		
	end
end
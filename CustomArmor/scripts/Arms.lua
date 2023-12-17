-- Model setup
local model     = models.Merling
local modelRoot = model.Player

-- Arm setup
local leftArm  = modelRoot.LeftArm
local rightArm = modelRoot.RightArm

-- Config setup
config:name("Merling")
local armMove = config:load("AvatarArmMove") or false

-- Variables setup
local pose  = require("scripts.Posing")
local ticks = require("scripts.WaterTicks")
local leftArmCurrent,  leftArmNextTick,  leftArmTarget,  leftArmCurrentPos  = 0, 0, 0, 0
local rightArmCurrent, rightArmNextTick, rightArmTarget, rightArmCurrentPos = 0, 0, 0, 0

-- Gradual value
function events.TICK()
	leftArmCurrent,  rightArmCurrent  = leftArmNextTick, rightArmNextTick
	leftArmNextTick, rightArmNextTick = math.lerp(leftArmNextTick, leftArmTarget, 0.5), math.lerp(rightArmNextTick, rightArmTarget, 0.5)
end

function events.RENDER(delta, context)
	-- Idle setup
	local idleTimer   = world.getTime(delta)
	local idleRot     = vec(math.deg(math.sin(idleTimer * 0.067) * 0.05), 0, math.deg(math.cos(idleTimer * 0.09) * 0.05 + 0.05))
	
	-- Arm variables
	local handedness  = player:isLeftHanded()
	local activeness  = player:getActiveHand()
	local leftActive  = not handedness and "OFF_HAND" or "MAIN_HAND"
	local rightActive = handedness and "OFF_HAND" or "MAIN_HAND"
	local leftSwing   = player:getSwingArm() == leftActive
	local rightSwing  = player:getSwingArm() == rightActive
	local leftItem    = player:getHeldItem(not handedness)
	local rightItem   = player:getHeldItem(handedness)
	local using       = player:isUsingItem()
	local usingL      = activeness == leftActive and leftItem:getUseAction() or "NONE"
	local usingR      = activeness == rightActive and rightItem:getUseAction() or "NONE"
	local crossL      = leftItem.tag and leftItem.tag["Charged"] == 1
	local crossR      = rightItem.tag and rightItem.tag["Charged"] == 1
	
	-- Movement context
	local shouldMove  = ticks.under >= 20 or animations.Merling.crawl:isPlaying()
	
	-- Offsets
	local bodyOffset  = vanilla_model.BODY:getOriginRot() * 0.75
	
	-- Arm multiplier lerps
	leftArmTarget     = (armMove or shouldMove or leftSwing or ((crossL or crossR) or (using and usingL ~= "NONE"))) and 0 or 1
	rightArmTarget    = (armMove or shouldMove or rightSwing or ((crossL or crossR) or (using and usingR ~= "NONE"))) and 0 or 1
	leftArmCurrentPos, rightArmCurrentPos = math.lerp(leftArmCurrent, leftArmNextTick, delta), math.lerp(rightArmCurrent, rightArmNextTick, delta)
	
	local firstPerson = context == "FIRST_PERSON"
	
	-- Left arm
	leftArm:rot(firstPerson and 0 or (-vanilla_model.LEFT_ARM:getOriginRot() + -idleRot + bodyOffset) * leftArmCurrentPos)
	
	-- Right arm
	rightArm:rot(firstPerson and 0 or (-vanilla_model.RIGHT_ARM:getOriginRot() + idleRot + bodyOffset) * rightArmCurrentPos)
end

-- Arm Movement toggler
local function setArmMove(boolean)
	armMove = boolean
	config:save("AvatarArmMove", armMove)
end

-- Sync variable
local function syncArms(a)
	armMove = a
end

-- Ping setup
pings.setAvatarArmMove = setArmMove
pings.syncArms         = syncArms

-- Sync on tick
if host:isHost() then
	function events.TICK()
		if world.getTime() % 200 == 0 then
			pings.syncArms(armMove)
		end
	end
end

-- Activate action
setArmMove(armMove)

-- Return action wheel page
return action_wheel:newAction("ArmMovement")
	:title("§9§lArm Movement Toggle\n\n§bToggles the movement swing movement of the arms.\nActions are not effected.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("minecraft:red_dye")
	:toggleItem("minecraft:rabbit_foot")
	:onToggle(pings.setAvatarArmMove)
	:toggled(armMove)
-- Required scripts
local merlingParts = require("lib.GroupIndex")(models.models.Merling)
local average      = require("lib.Average")
local waterTicks   = require("scripts.WaterTicks")
local effects      = require("scripts.SyncedVariables")

-- Config setup
config:name("Merling")
local armMove = config:load("AvatarArmMove") or false

-- Left arm lerp table
local leftArm = {
	current    = 0,
	nextTick   = 0,
	target     = 0,
	currentPos = 0
}

-- Right arm lerp table
local rightArm = {
	current    = 0,
	nextTick   = 0,
	target     = 0,
	currentPos = 0
}

-- Set lerp start on init
function events.ENTITY_INIT()
	
	local apply = armMove and 1 or 0
	for k, v in pairs(leftArm) do
		leftArm[k] = apply
	end
	for k, v in pairs(rightArm) do
		rightArm[k] = apply
	end
	
end

function events.TICK()
	
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
	local bow         = using and (usingL == "BOW" or usingR == "BOW")
	local crossL      = leftItem.tag and leftItem.tag["Charged"] == 1
	local crossR      = rightItem.tag and rightItem.tag["Charged"] == 1
	
	-- Movement overrides
	local shouldMove = (waterTicks.under >= 20 and not effects.cF) or average(merlingParts.Tail1:getScale():unpack()) <= 0.6 or animations["models.Merling"].crawl:isPlaying()
	
	-- Targets
	leftArm.target  = (armMove or shouldMove or leftSwing  or bow or ((crossL or crossR) or (using and usingL ~= "NONE"))) and 0 or 1
	rightArm.target = (armMove or shouldMove or rightSwing or bow or ((crossL or crossR) or (using and usingR ~= "NONE"))) and 0 or 1
	
	-- Tick lerps
	leftArm.current   = leftArm.nextTick
	rightArm.current  = rightArm.nextTick
	leftArm.nextTick  = math.lerp(leftArm.nextTick,  leftArm.target,  0.5)
	rightArm.nextTick = math.lerp(rightArm.nextTick, rightArm.target, 0.5)
	
end

function events.RENDER(delta, context)
	
	-- Override arm movements
	local idleTimer  = world.getTime(delta)
	local idleRot    = vec(math.deg(math.sin(idleTimer * 0.067) * 0.05), 0, math.deg(math.cos(idleTimer * 0.09) * 0.05 + 0.05))
	local bodyOffset = (vanilla_model.BODY:getOriginRot() * 0.75) + merlingParts.Body:getTrueRot()
	
	-- Render lerp
	leftArm.currentPos  = math.lerp(leftArm.current,  leftArm.nextTick,  delta)
	rightArm.currentPos = math.lerp(rightArm.current, rightArm.nextTick, delta)
	
	-- First person check
	local firstPerson = context == "FIRST_PERSON"
	
	-- Apply
	merlingParts.LeftArm:rot((-((vanilla_model.LEFT_ARM:getOriginRot() + 180) % 360 - 180) + -idleRot + bodyOffset) * leftArm.currentPos)
		:visible(not firstPerson)
	
	merlingParts.LeftArmFP:visible(firstPerson)
	
	merlingParts.RightArm:rot((-((vanilla_model.RIGHT_ARM:getOriginRot() + 180) % 360 - 180) + idleRot + bodyOffset) * rightArm.currentPos)
		:visible(not firstPerson)
	
	merlingParts.RightArmFP:visible(firstPerson)
	
end

-- Arm movement toggle
function pings.setAvatarArmMove(boolean)
	
	armMove = boolean
	config:save("AvatarArmMove", armMove)
	
end

-- Sync variable
function pings.syncArms(a)
	
	armMove = a
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local color     = require("scripts.ColorProperties")

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncArms(armMove)
	end
	
end

-- Table setup
local t = {}

-- Action
t.movePage = action_wheel:newAction()
	:item(itemCheck("red_dye"))
	:toggleItem(itemCheck("rabbit_foot"))
	:onToggle(pings.setAvatarArmMove)
	:toggled(armMove)

-- Update action
function events.TICK()
	
	if action_wheel:isEnabled() then
		t.movePage
			:title(toJson
				{"",
				{text = "Arm Movement Toggle\n\n", bold = true, color = color.primary},
				{text = "Toggles the movement swing movement of the arms.\nActions are not effected.", color = color.secondary}}
			)
		
		for _, page in pairs(t) do
			page:hoverColor(color.hover):toggleColor(color.active)
		end
		
	end
	
end

-- Return action
return t
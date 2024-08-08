-- Required scripts
local parts   = require("lib.PartsAPI")
local lerp    = require("lib.LerpAPI")
local ground  = require("lib.GroundCheck")
local effects = require("scripts.SyncedVariables")

-- Config setup
config:name("Merling")
local waterType = config:load("TailWater") or 4
local small     = config:load("TailSmall")
local ears      = config:load("TailEars")
local dryTimer  = config:load("TailDryTimer") or 400
local fallSound = config:load("TailFallSound")
if small     == nil then small = true end
if ears      == nil then ears = true end
if fallSound == nil then fallSound = true end

-- Variables setup
local legsForm = 0.75
local timer = 0
local wasInAir = false

-- Lerp variables
local scale      = lerp:new(0.2, waterType == 5 and 1 or 0)
local legsScale  = lerp:new(0.2, waterType ~= 5 and 1 or 0)
local smallScale = lerp:new(0.2, small and 1 or 0)
local earsScale  = lerp:new(0.2, ears and 1 or 0)

-- Data sent to other scripts
local tailData = {
	scale = scale.currPos * math.map(smallScale.currPos, 0, 1, 1, 0.5) + smallScale.currPos * 0.5,
	large = scale.currPos,
	small = smallScale.currPos,
	legs  = legsScale.currPos,
	dry   = dryTimer,
	swap  = legsForm
}

-- Check if a splash potion is broken near the player
local splash = false
function events.ON_PLAY_SOUND(id, pos, vol, pitch, loop, category, path)
	
	if player:isLoaded() then
		local atPos      = pos < player:getPos() + 2 and pos > player:getPos() - 2
		local splashID   = id == "minecraft:entity.splash_potion.break" or id == "minecraft:entity.lingering_potion.break"
		splash = atPos and splashID and path
	end
	
end

function events.TICK()
	
	-- Arm variables
	local handedness  = player:isLeftHanded()
	local activeness  = player:getActiveHand()
	local leftActive  = not handedness and "OFF_HAND" or "MAIN_HAND"
	local rightActive = handedness and "OFF_HAND" or "MAIN_HAND"
	local leftItem    = player:getHeldItem(not handedness)
	local rightItem   = player:getHeldItem(handedness)
	local using       = player:isUsingItem()
	local drinkingL   = activeness == leftActive and using and leftItem:getUseAction() == "DRINK"
	local drinkingR   = activeness == rightActive and using and rightItem:getUseAction() == "DRINK"
	
	-- Check for if player has gone underwater
	local under = player:isUnderwater() or player:isInLava()
	
	-- Check for if player is in liquid
	local water = under or player:isInWater()
	
	-- Check for if player touches any liquid
	local wet = water or player:isWet() or ((drinkingL or drinkingR) and player:getActiveItemTime() > 20) or splash
	if wet then
		splash = false
	end
	
	-- Water state table
	local waterState = {
		false,
		under,
		water,
		wet,
		true
	}
	
	-- Adjust timer based on state
	if waterState[waterType] then
		timer = dryTimer
	else
		timer = math.max(timer - 1, 0)
	end
	
	-- Timer should not exceed the max default timer
	if timer > dryTimer then
		timer = dryTimer
	end
	
	-- Target
	scale.target      = timer / dryTimer
	legsScale.target  = timer / dryTimer <= legsForm and 1 or 0
	smallScale.target = small and 1 or 0
	earsScale.target  = ears and 1 or 0
	
	-- Play sound if conditions are met
	if fallSound and wasInAir and ground() and scale.currPos >= legsForm and not player:getVehicle() and not player:isInWater() and not effects.cF then
		local vel    = math.abs(-player:getVelocity().y + 1)
		local dry    = scale.currPos
		local volume = math.clamp((vel * dry) / 2, 0, 1)
		
		if volume ~= 0 then
			sounds:playSound("entity.puffer_fish.flop", player:getPos(), volume, math.map(volume, 1, 0, 0.45, 0.65))
		end
	end
	wasInAir = not ground()
	
end

function events.RENDER(delta, context)
	
	-- Variables
	local tailScale = scale.currPos * math.map(smallScale.currPos, 0, 1, 1, 0.5) + smallScale.currPos * 0.5
	local legScale  = legsScale.currPos
	local earScale  = earsScale.currPos
	
	-- Apply tail
	parts.group.Tail1:scale(tailScale)
	
	-- Apply legs
	parts.group.LeftLeg:scale(legScale)
	parts.group.RightLeg:scale(legScale)
	
	-- Apply ears
	parts.group.LeftEar:scale(earScale)
	parts.group.RightEar:scale(earScale)
	parts.group.LeftEarSkull:scale(earScale)
	parts.group.RightEarSkull:scale(earScale)
	
	-- Update tail data
	tailData.scale = tailScale
	tailData.large = scale.currPos
	tailData.small = smallScale.currPos
	tailData.legs  = legsScale.currPos
	tailData.dry   = dryTimer
	
end

-- Water sensitivity
function pings.setTailWater(i)
	
	waterType = waterType + i
	if waterType > 5 then waterType = 1 end
	if waterType < 1 then waterType = 5 end
	if player:isLoaded() and host:isHost() and i ~= 0 then
		sounds:playSound("ambient.underwater.enter", player:getPos(), 0.35)
	end
	config:save("TailWater", waterType)
	
end

-- Small toggle
function pings.setTailSmall(boolean)
	
	small = boolean
	config:save("TailSmall", small)
	
end

-- Ears toggle
function pings.setTailEars(boolean)
	
	ears = boolean
	config:save("TailEars", ears)
	
end

-- Set timer
local function setDryTimer(x)
	
	dryTimer = math.clamp(dryTimer + (x * 20), 20, 72000)
	config:save("TailDryTimer", dryTimer)
	
end

-- Sound toggle
function pings.setTailFallSound(boolean)

	fallSound = boolean
	config:save("TailFallSound", fallSound)
	if host:isHost() and player:isLoaded() and fallSound then
		sounds:playSound("entity.puffer_fish.flop", player:getPos(), 0.35, 0.6)
	end
	
end

-- Sync variables
function pings.syncTail(a, b, c, d, e)
	
	waterType = a
	small     = b
	ears      = c
	dryTimer  = d
	fallSound = e
	
end

-- Host only instructions, return tail data
if not host:isHost() then return tailData end

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local color     = require("scripts.ColorProperties")

-- Tail Keybind
local waterBind   = config:load("TailWaterKeybind") or "key.keyboard.keypad.1"
local setWaterKey = keybinds:newKeybind("Merling Water Type"):onPress(function() pings.setTailWater(1) end):key(waterBind)

-- Small tail keybind
local smallBind   = config:load("TailSmallKeybind") or "key.keyboard.keypad.2"
local setSmallKey = keybinds:newKeybind("Small Tail Toggle"):onPress(function() pings.setTailSmall(not small) end):key(smallBind)

-- Ears keybind
local earsBind   = config:load("TailEarsKeybind") or "key.keyboard.keypad.3"
local setEarsKey = keybinds:newKeybind("Ears Toggle"):onPress(function() pings.setTailEars(not ears) end):key(earsBind)

-- Keybind updaters
function events.TICK()
	
	local waterKey = setWaterKey:getKey()
	local smallKey = setSmallKey:getKey()
	local earsKey  = setEarsKey:getKey()
	if waterKey ~= waterBind then
		waterBind = waterKey
		config:save("TailWaterKeybind", waterKey)
	end
	if smallKey ~= smallBind then
		smallBind = smallKey
		config:save("TailSmallKeybind", smallKey)
	end
	if earsKey ~= earsBind then
		earsBind = earsKey
		config:save("TailEarsKeybind", earsKey)
	end
	
end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncTail(waterType, small, ears, dryTimer, fallSound)
	end
	
end

-- Table setup
local t = {}

-- Actions
t.waterPage = action_wheel:newAction()
	:onLeftClick(function() pings.setTailWater(1)end)
	:onRightClick(function() pings.setTailWater(-1) end)
	:onScroll(pings.setTailWater)

t.earsPage = action_wheel:newAction()
	:item(itemCheck("prismarine_crystals"))
	:toggleItem(itemCheck("prismarine_shard"))
	:onToggle(pings.setTailEars)

t.smallPage = action_wheel:newAction()
	:item(itemCheck("kelp"))
	:toggleItem(itemCheck("scute"))
	:onToggle(pings.setTailSmall)

t.dryPage = action_wheel:newAction()
	:item(itemCheck("water_bucket"))
	:onScroll(setDryTimer)
	:onLeftClick(function() dryTimer = 400 config:save("TailDryTimer", dryTimer) end)

t.soundPage = action_wheel:newAction()
	:item(itemCheck("sponge"))
	:toggleItem(itemCheck("wet_sponge"))
	:onToggle(pings.setTailFallSound)
	:toggled(fallSound)

-- Water context info table
local waterInfo = {
	{
		title = {label = {text = "None", color = "red"}, text = "Tail cannot form."},
		item  = "glass_bottle",
		color = "FF5555"
	},
	{
		title = {label = {text = "Low", color = "yellow"}, text = "Reactive to being underwater."},
		item  = "potion",
		color = "FFFF55"
	},
	{
		title = {label = {text = "Medium", color = "green"}, text = "Reactive to being in water."},
		item  = "splash_potion",
		color = "55FF55"
	},
	{
		title = {label = {text = "High", color = "aqua"}, text = "Reactive to any form of water."},
		item  = "lingering_potion",
		color = "55FFFF"
	},
	{
		title = {label = {text = "Max", color = "blue"}, text = "Tail is always active."},
		item  = "dragon_breath",
		color = "5555FF"
	}
}

-- Creates a clock string
local function timeStr(seconds)

	local min = seconds >= 60
		and ("%d Minute%s"):format(seconds / 60, seconds >= 120 and "s" or "")
		or nil
	
	local sec = ("%d Second%s"):format(seconds % 60, seconds % 60 == 1 and "" or "s")
	
	return min and (min.." "..sec) or sec
	
end

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		t.waterPage
			:title(toJson
				{"",
				{text = "Water Sensitivity\n\n", bold = true, color = color.primary},
				{text = "Determines how your tail should form in contact with water.\n\n", color = color.secondary},
				{text = "Current configuration: ", bold = true, color = color.secondary},
				{text = waterInfo[waterType].title.label.text, color = waterInfo[waterType].title.label.color},
				{text = " | "},
				{text = waterInfo[waterType].title.text, color = color.secondary}}
			)
			:color(vectors.hexToRGB(waterInfo[waterType].color))
			:item(itemCheck(waterInfo[waterType].item.."{'CustomPotionColor':" .. tostring(0x0094FF) .. "}"))
		
		t.earsPage
			:title(toJson
				{"",
				{text = "Toggle Ears\n\n", bold = true, color = color.primary},
				{text = "Toggles the appearence of your ears.", color = color.secondary}}
			)
			:toggled(ears)
		
		t.smallPage
			:title(toJson
				{"",
				{text = "Toggle Small Tail\n\n", bold = true, color = color.primary},
				{text = "Toggles the appearence of the tail into a smaller tail, only if the tail cannot form.", color = color.secondary}}
			)
			:toggled(small)
		
		-- Timers
		local setTimer  = timeStr(dryTimer / 20)
		local legsTimer = timeStr(math.max(math.ceil((timer - (dryTimer * legsForm)) / 20), 0))
		local fullTimer = timeStr(math.ceil(timer / 20))
		
		t.dryPage
			:title(toJson
				{"",
				{text = "Set Drying Timer\n\n", bold = true, color = color.primary},
				{text = "Scroll to adjust how long it takes for you to dry.\nLeft click resets timer to 20 seconds.\n\n", color = color.secondary},
				{text = "Drying timer:\n", bold = true, color = color.secondary},
				{text = setTimer.."\n\n"},
				{text = "Time left until legs:\n", bold = true, color = color.secondary},
				{text = legsTimer.."\n\n"},
				{text = "Time left until fully dry:\n", bold = true, color = color.secondary},
				{text = fullTimer}}
			)
		
		t.soundPage
			:title(toJson
				{"",
				{text = "Toggle Flop Sound\n\n", bold = true, color = color.primary},
				{text = "Toggles flopping sound effects when landing on the ground.\nIf tail can dry, volume will gradually decrease over time until dry.", color = color.secondary}}
			)
		
		for _, page in pairs(t) do
			page:hoverColor(color.hover):toggleColor(color.active)
		end
		
	end
	
end

-- Return tail data and actions
return tailData, t
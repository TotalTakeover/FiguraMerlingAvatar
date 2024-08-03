-- Required scripts
local parts      = require("lib.PartsAPI")
local ground     = require("lib.GroundCheck")
local waterTicks = require("scripts.WaterTicks")
local effects    = require("scripts.SyncedVariables")

-- Config setup
config:name("Merling")
local water     = config:load("TailWater") or 4
local small     = config:load("TailSmall")
local ears      = config:load("TailEars")
local canDry    = config:load("TailDry")
local dryTimer  = config:load("TailDryTimer") or 400
local fallSound = config:load("TailFallSound")
if small     == nil then small = true end
if ears      == nil then ears = true end
if canDry    == nil then canDry = true end
if fallSound == nil then fallSound = true end

-- Variables setup
local wasInAir = false

-- Lerp scale table
local scale = {
	current    = 0,
	nextTick   = 0,
	target     = 0,
	currentPos = 0
}

-- Lerp small table
local smallScale = {
	current    = 0,
	nextTick   = 0,
	target     = 0,
	currentPos = 0
}

-- Lerp ears table
local earsScale = {
	current    = 0,
	nextTick   = 0,
	target     = 0,
	currentPos = 0
}

-- Data sent to other scripts
local tailData = {
	large = scale.currentPos,
	small = smallScale.currentPos,
}

-- Set lerp start on init
function events.ENTITY_INIT()
	
	local apply = water == 5 and 1 or 0
	for k in pairs(scale) do
		scale[k] = apply
	end
	
	local apply = small and 1 or 0
	for k in pairs(smallScale) do
		smallScale[k] = apply
	end
	
	local apply = ears and 1 or 0
	for k in pairs(earsScale) do
		earsScale[k] = apply
	end
	
end

function events.TICK()
	
	-- Water state table
	local waterState = {
		dryTimer + 1,
		waterTicks.under,
		waterTicks.water,
		waterTicks.wet,
		0
	}
	
	-- Target
	scale.target      = waterState[water] <= (canDry and dryTimer or 20) and 1 or 0
	smallScale.target = small and 1 or 0
	earsScale.target  = ears and 1 or 0
	
	-- Tick lerp
	scale.current       = scale.nextTick
	smallScale.current  = smallScale.nextTick
	earsScale.current   = earsScale.nextTick
	scale.nextTick      = math.lerp(scale.nextTick,      scale.target,      0.2)
	smallScale.nextTick = math.lerp(smallScale.nextTick, smallScale.target, 0.2)
	earsScale.nextTick  = math.lerp(earsScale.nextTick,  earsScale.target,  0.2)
	
	-- Play sound if conditions are met
	if fallSound and wasInAir and ground() and scale.currentPos >= 0.75 and not player:getVehicle() and not player:isInWater() and not effects.cF then
		local vel    = math.abs(-player:getVelocity().y + 1)
		local dry    = canDry and (dryTimer - waterState[water]) / dryTimer or 1
		local volume = math.clamp((vel * dry) / 2, 0, 1)
		
		if volume ~= 0 then
			sounds:playSound("entity.puffer_fish.flop", player:getPos(), volume, math.map(volume, 1, 0, 0.45, 0.65))
		end
	end
	wasInAir = not ground()
	
	-- Update tail data
	tailData.large = scale.currentPos
	tailData.small = smallScale.currentPos
	
end

function events.RENDER(delta, context)
	
	-- Render lerp
	scale.currentPos      = math.lerp(scale.current,      scale.nextTick,      delta)
	smallScale.currentPos = math.lerp(smallScale.current, smallScale.nextTick, delta)
	earsScale.currentPos  = math.lerp(earsScale.current,  earsScale.nextTick,  delta)
	
	-- Variables
	local tailScale = (scale.currentPos * math.map(smallScale.currentPos, 0, 1, 1, 0.5)) + (smallScale.currentPos * 0.5)
	local legScale  = math.map(scale.currentPos, 1, 0, 0, 1)
	local earScale  = earsScale.currentPos
	
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
	
end

-- Water sensitivity
function pings.setTailWater(i)
	
	water = water + i
	if water > 5 then water = 1 end
	if water < 1 then water = 5 end
	if player:isLoaded() and host:isHost() and i ~= 0 then
		sounds:playSound("ambient.underwater.enter", player:getPos(), 0.35)
	end
	config:save("TailWater", water)
	
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

-- Dry toggle
function pings.setTailDry(boolean)
	
	canDry = boolean
	config:save("TailDry", canDry)
	
end

-- Set timer
local function setDryTimer(x)
	
	dryTimer = math.clamp(dryTimer + (x * 20), 100, 6000)
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
function pings.syncTail(a, b, c, d, e, f)
	
	water     = a
	small     = b
	ears      = c
	canDry    = d
	dryTimer  = e
	fallSound = f
	
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
		pings.syncTail(water, small, ears, canDry, dryTimer, fallSound)
	end
	
end

-- Table setup
local t = {}

-- Actions
t.waterPage = action_wheel:newAction()
	:onLeftClick(function() pings.setTailWater(1)end)
	:onRightClick(function() pings.setTailWater(-1) end)

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
	:toggleItem(itemCheck("leather"))
	:onToggle(pings.setTailDry)
	:onScroll(setDryTimer)
	:onRightClick(function() dryTimer = 400 config:save("TailDryTimer", dryTimer) end)
	:toggled(canDry)

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

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		t.waterPage
			:title(toJson
				{"",
				{text = "Water Sensitivity\n\n", bold = true, color = color.primary},
				{text = "Determines how your tail should form in contact with water.\n\n", color = color.secondary},
				{text = "Current configuration: ", bold = true, color = color.secondary},
				{text = waterInfo[water].title.label.text, color = waterInfo[water].title.label.color},
				{text = " | "},
				{text = waterInfo[water].title.text, color = color.secondary}}
			)
			:color(vectors.hexToRGB(waterInfo[water].color))
			:item(itemCheck(waterInfo[water].item.."{'CustomPotionColor':" .. tostring(0x0094FF) .. "}"))
		
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
		
		t.dryPage
			:title(toJson
				{"",
				{text = "Toggle Drying/Timer\n\n", bold = true, color = color.primary},
				{text = "Toggles the gradual drying of your tail until your legs form again.\n\n", color = color.secondary},
				{text = "Current drying timer: ", bold = true, color = color.secondary},
				{text = (canDry and ((dryTimer / 20).." Seconds") or "None").."\n\n"},
				{text = "Scroll to adjust the timer.\nRight click resets timer to 20 seconds.", color = color.secondary}}
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
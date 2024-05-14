-- Required scripts
local merlingParts = require("lib.GroupIndex")(models.models.Merling)
local ground       = require("lib.GroundCheck")
local itemCheck    = require("lib.ItemCheck")
local waterTicks   = require("scripts.WaterTicks")
local effects      = require("scripts.SyncedVariables")
local color        = require("scripts.ColorProperties")

-- Config setup
config:name("Merling")
local active    = config:load("TailActive")
local water     = config:load("TailWater") or 3
local small     = config:load("TailSmall")
local ears      = config:load("TailEars")
local canDry    = config:load("TailDry")
local dryTimer  = config:load("TailDryTimer") or 400
local fallSound = config:load("TailFallSound")
if active    == nil then active = true end
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

-- Set lerp start on init
function events.ENTITY_INIT()
	
	local apply = active and 1 or 0
	for k, v in pairs(scale) do
		scale[k] = apply
	end
	
	local apply = ears and 1 or 0
	for k, v in pairs(earsScale) do
		earsScale[k] = apply
	end
	
end

function events.TICK()
	
	-- Water state table
	local waterState = {
		waterTicks.under,
		waterTicks.water,
		waterTicks.wet,
		0
	}
	
	-- Target
	scale.target      = active and waterState[water] <= (canDry and dryTimer or 20) and 1 or 0
	smallScale.target = active and small and 1 or 0
	earsScale.target  = active and ears and 1 or 0
	
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
	merlingParts.Tail1:scale(tailScale)
	
	-- Apply legs
	merlingParts.LeftLeg:scale(legScale)
	merlingParts.RightLeg:scale(legScale)
	
	-- Apply Ears
	merlingParts.LeftEar:scale(earScale)
	merlingParts.RightEar:scale(earScale)
	merlingParts.LeftEarSkull:scale(earScale)
	merlingParts.RightEarSkull:scale(earScale)
	
end

-- Active toggle
local function setActive(boolean)
	
	active = boolean
	config:save("TailActive", active)
	
end

-- Water sensitivity
local function setWater(i)
	
	water = water + i
	if water > 4 then water = 1 end
	if water < 1 then water = 4 end
	if player:isLoaded() and host:isHost() and i ~= 0 then
		sounds:playSound("ambient.underwater.enter", player:getPos(), 0.35)
	end
	config:save("TailWater", water)
	
end

-- Small toggle
local function setSmall(boolean)
	
	small = boolean
	config:save("TailSmall", small)
	
end

-- Ears toggle
local function setEars(boolean)
	
	ears = boolean
	config:save("TailEars", ears)
	
end

-- Dry toggle
local function setDry(boolean)
	
	canDry = boolean
	config:save("TailDry", canDry)
	
end

-- Set timer
local function setDryTimer(x)
	
	dryTimer = math.clamp(dryTimer + (x * 20), 100, 6000)
	config:save("TailDryTimer", dryTimer)
	
end

-- Sound toggle
local function setFallSound(boolean)

	fallSound = boolean
	config:save("TailFallSound", fallSound)
	if host:isHost() and player:isLoaded() and fallSound then
		sounds:playSound("entity.puffer_fish.flop", player:getPos(), 0.35, 0.6)
	end
	
end

-- Sync variables
local function syncTail(a, b, c, d, e, x, f)
	
	active    = a
	water     = b
	small     = c
	ears      = d
	canDry    = e
	dryTimer  = x
	fallSound = f
	
end

-- Pings setup
pings.setTailActive    = setActive
pings.setTailWater     = setWater
pings.setTailSmall     = setSmall
pings.setTailEars      = setEars
pings.setTailDry       = setDry
pings.setTailFallSound = setFallSound
pings.syncTail         = syncTail

-- Tail Keybind
local tailBind   = config:load("TailActiveKeybind") or "key.keyboard.keypad.1"
local setTailKey = keybinds:newKeybind("Merling Toggle"):onPress(function() pings.setTailActive(not active) end):key(tailBind)

-- Small Tail keybind
local smallBind   = config:load("TailSmallKeybind") or "key.keyboard.keypad.2"
local setSmallKey = keybinds:newKeybind("Small Tail Toggle"):onPress(function() pings.setTailSmall(not small) end):key(smallBind)

-- Ears keybind
local earsBind   = config:load("TailEarsKeybind") or "key.keyboard.keypad.3"
local setEarsKey = keybinds:newKeybind("Ears Toggle"):onPress(function() pings.setTailEars(not ears) end):key(earsBind)

-- Keybind updaters
function events.TICK()
	
	local tailKey  = setTailKey:getKey()
	local smallKey = setSmallKey:getKey()
	local earsKey  = setEarsKey:getKey()
	if tailKey ~= tailBind then
		tailBind = tailKey
		config:save("TailActiveKeybind", tailKey)
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
if host:isHost() then
	function events.TICK()
		
		if world.getTime() % 200 == 0 then
			pings.syncTail(active, water, small, ears, canDry, dryTimer, fallSound)
		end
		
	end
end

-- Activate actions
setActive(active)
setWater(0)
setSmall(small)
setEars(ears)
setDry(canDry)
setFallSound(fallSound)

-- Table setup
local t = {}

-- Action wheel pages
t.activePage = action_wheel:newAction()
	:item(itemCheck("rabbit_foot"))
	:toggleItem(itemCheck("tropical_fish"))
	:onToggle(pings.setTailActive)

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
		title = {label = {text = "Low", color = "red"}, text = "Reactive to being underwater."},
		item  = "glass_bottle",
		color = "FF5555"
	},
	{
		title = {label = {text = "Medium", color = "yellow"}, text = "Reactive to being in water."},
		item  = "potion",
		color = "FFFF55"
	},
	{
		title = {label = {text = "High", color = "green"}, text = "Reactive to any form of water."},
		item  = "splash_potion",
		color = "55FF55"
	},
	{
		title = {label = {text = "Max", color = "blue"}, text = "Always active."},
		item  = "lingering_potion",
		color = "5555FF"
	}
}

-- Update action page info
function events.TICK()
	
	t.activePage
		:title(toJson
			{"",
			{text = "Toggle Merling Functionality\n\n", bold = true, color = color.primary},
			{text = "Toggles the ability for Merling attributes to appear.", color = color.secondary}}
		)
		:hoverColor(color.hover)
		:toggleColor(color.active)
		:toggled(active)
	
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
		:hoverColor(color.hover)
		:item(itemCheck(waterInfo[water].item.."{'CustomPotionColor':" .. tostring(0x0094FF) .. "}"))
	
	t.earsPage
		:title(toJson
			{"",
			{text = "Toggle Ears\n\n", bold = true, color = color.primary},
			{text = "Toggles the appearence of your ears.", color = color.secondary}}
		)
		:hoverColor(color.hover)
		:toggleColor(color.active)
		:toggled(ears)
	
	t.smallPage
		:title(toJson
			{"",
			{text = "Toggle Small Tail\n\n", bold = true, color = color.primary},
			{text = "When outside water, toggles the appearence of the tail into a smaller tail.", color = color.secondary}}
		)
		:hoverColor(color.hover)
		:toggleColor(color.active)
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
		:hoverColor(color.hover)
		:toggleColor(color.active)
	
	t.soundPage
		:title(toJson
			{"",
			{text = "Toggle Flop Sound\n\n", bold = true, color = color.primary},
			{text = "Toggles flopping sound effects when landing on the ground.\nIf tail can dry, volume will gradually decrease over time until dry.", color = color.secondary}}
		)
		:hoverColor(color.hover)
		:toggleColor(color.active)
	
end

-- Return action wheel pages
return t
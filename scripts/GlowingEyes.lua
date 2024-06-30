-- Required scripts
local merlingParts = require("lib.GroupIndex")(models.models.Merling)
local origins      = require("lib.OriginsAPI")
local effects      = require("scripts.SyncedVariables")

-- Config setup
config:name("Merling")
local toggle      = config:load("EyesToggle") or false
local power       = config:load("EyesPower") or false
local nightVision = config:load("EyesNightVision") or false
local water       = config:load("EyesWater") or false

-- Lerp eyes table
local eyes = {
	current    = 0,
	nextTick   = 0,
	target     = 0,
	currentPos = 0
}

-- Set lerp start on init
function events.ENTITY_INIT()
	
	local apply = toggle and 1 or 0
	for k, v in pairs(eyes) do
		eyes[k] = apply
	end
	
end

function events.TICK()
	
	-- Set eyes target
	-- Toggle check
	if toggle then
		
		eyes.target = 1
		
		-- Origins check
		if power then
			eyes.target = origins.getPowerData(player, "origins:water_vision") == 1 and eyes.target or 0
		end
		
		-- Night Vision check
		if nightVision then
			eyes.target = effects.nV and 1 or eyes.target
			if effects.nV then goto skip end
		end
		
		-- Water check
		if water then
			eyes.target = not (water and not player:isUnderwater()) and eyes.target or 0
		end
		
		-- Skips water check if night vision confirmed
		::skip::
		
	else
		
		eyes.target = 0
		
	end
	
	-- Tick lerp
	eyes.current = eyes.nextTick
	eyes.nextTick = math.lerp(eyes.nextTick, eyes.target, 0.2)
	
end

function events.RENDER(delta, context)
	
	-- Render lerp
	eyes.currentPos = math.lerp(eyes.current, eyes.nextTick, delta)
	
	-- Apply
	merlingParts.Head.Eyes
		:secondaryColor(eyes.currentPos)
		:secondaryRenderType(context == "RENDER" and "EMISSIVE" or "EYES")
	
end

-- Glowing eyes toggler
function pings.setEyesToggle(boolean)
	
	toggle = boolean
	config:save("EyesToggle", toggle)
	if player:isLoaded() and toggle then
		sounds:playSound("entity.glow_squid.ambient", player:getPos(), 0.75)
	end
	
end

-- Glowing eyes power toggler
function pings.setEyesPower(boolean)
	
	power = boolean
	config:save("EyesPower", power)
	if host:isHost() and player:isLoaded() and power then
		sounds:playSound("entity.puffer_fish.flop", player:getPos(), 0.35)
	end
	
end

-- Glowing eyes night vision toggler
function pings.setEyesNightVision(boolean)
	
	nightVision = boolean
	config:save("EyesNightVision", nightVision)
	if host:isHost() and player:isLoaded() and nightVision then
		sounds:playSound("entity.generic.drink", player:getPos(), 0.35)
	end
	
end

-- Glowing eyes water toggler
function pings.setEyesWater(boolean)
	
	water = boolean
	config:save("EyesWater", water)
	if host:isHost() and player:isLoaded() and water then
		sounds:playSound("ambient.underwater.enter", player:getPos(), 0.35)
	end
	
end

-- Sync variables
function pings.syncEyes(a, b, c, d)
	
	toggle      = a
	power       = b
	nightVision = c
	water       = d
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local color     = require("scripts.ColorProperties")

-- Keybind
local toggleBind   = config:load("EyesToggleKeybind") or "key.keyboard.keypad.5"
local setToggleKey = keybinds:newKeybind("Glowing Eyes Toggle"):onPress(function() pings.setEyesToggle(not toggle) end):key(toggleBind)

-- Keybind updater
function events.TICK()
	
	local key = setToggleKey:getKey()
	if key ~= toggleBind then
		toggleBind = key
		config:save("EyesToggleKeybind", key)
	end
	
end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncEyes(toggle, power, nightVision, water)
	end
	
end

-- Table setup
local t = {}

-- Action wheels
t.togglePage = action_wheel:newAction()
	:item(itemCheck("ender_pearl"))
	:toggleItem(itemCheck("ender_eye"))
	:onToggle(pings.setEyesToggle)

t.powerPage = action_wheel:newAction()
	:item(itemCheck("cod"))
	:toggleItem(itemCheck("tropical_fish"))
	:onToggle(pings.setEyesPower)
	:toggled(power)

t.nightVisionPage = action_wheel:newAction()
	:item(itemCheck("glass_bottle"))
	:toggleItem(itemCheck("potion{'CustomPotionColor':" .. tostring(0x96C54F) .. "}"))
	:onToggle(pings.setEyesNightVision)
	:toggled(nightVision)

t.waterPage = action_wheel:newAction()
	:item(itemCheck("bucket"))
	:toggleItem(itemCheck("water_bucket"))
	:onToggle(pings.setEyesWater)
	:toggled(water)

-- Update action page info
function events.TICK()
	
	if action_wheel:isEnabled() then
		t.togglePage
			:title(toJson
				{"",
				{text = "Toggle Glowing Eyes\n\n", bold = true, color = color.primary},
				{text = "Toggles the glowing of the eyes.\n\n", color = color.secondary},
				{text = "WARNING: ", bold = true, color = "dark_red"},
				{text = "This feature has a tendency to not work correctly.\nDue to the rendering properties of emissives, the eyes may not glow.\nIf it does not work, please reload the avatar. Rinse and Repeat.\nThis is the only fix, I have tried everything.\n\n- Total", color = "red"}}
			)
			:toggled(toggle)
		
		t.powerPage
			:title(toJson
				{"",
				{text = "Origins Power Toggle\n\n", bold = true, color = color.primary},
				{text = "Toggles the glowing based on Origin's underwater sight power.\nThe eyes will only glow when this power is active.", color = color.secondary}}
			)
		
		t.nightVisionPage
			:title(toJson
				{"",
				{text = "Night Vision Toggle\n\n", bold = true, color = color.primary},
				{text = "Toggles the glowing based on having the Night Vision effect.\nThis setting will ", color = color.secondary},
				{text = "OVERRIDE ", bold = true, color = color.secondary},
				{text = "the other subsettings.", color = color.secondary}}
			)
		
		t.waterPage
			:title(toJson
				{"",
				{text = "Water Sensitivity Toggle\n\n", bold = true, color = color.primary},
				{text = "Toggles the glowing sensitivity to water.\nThe eyes will only glow when underwater.", color = color.secondary}}
			)
		
		for _, page in pairs(t) do
			page:hoverColor(color.hover):toggleColor(color.active)
		end
		
	end
	
end

-- Return action wheel pages
return t
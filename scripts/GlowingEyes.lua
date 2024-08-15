-- Required scripts
local parts   = require("lib.PartsAPI")
local lerp    = require("lib.LerpAPI")
local origins = require("lib.OriginsAPI")
local effects = require("scripts.SyncedVariables")

-- Config setup
config:name("Merling")
local toggle      = config:load("EyesToggle") or false
local power       = config:load("EyesPower") or false
local nightVision = config:load("EyesNightVision") or false
local water       = config:load("EyesWater") or false

-- Glowing parts
local glowingParts = parts:createTable(function(part) return part:getName():find("_EyeGlow") end)

-- Lerp eyes table
local eyes = lerp:new(0.2, toggle and 1 or 0)

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
	
end

function events.RENDER(delta, context)
	
	-- Apply
	local renderType = context == "RENDER" and "EMISSIVE" or "EYES"
	for _, part in ipairs(glowingParts) do
		part
			:secondaryColor(eyes.currPos)
			:secondaryRenderType(renderType)
	end
	
end

-- Glowing eyes toggle
function pings.setEyesToggle(boolean)
	
	toggle = boolean
	config:save("EyesToggle", toggle)
	if player:isLoaded() and toggle then
		sounds:playSound("entity.glow_squid.ambient", player:getPos(), 0.75)
	end
	
end

-- Power toggle
function pings.setEyesPower(boolean)
	
	power = boolean
	config:save("EyesPower", power)
	if host:isHost() and player:isLoaded() and power then
		sounds:playSound("entity.puffer_fish.flop", player:getPos(), 0.35)
	end
	
end

-- Night vision toggle
function pings.setEyesNightVision(boolean)
	
	nightVision = boolean
	config:save("EyesNightVision", nightVision)
	if host:isHost() and player:isLoaded() and nightVision then
		sounds:playSound("entity.generic.drink", player:getPos(), 0.35)
	end
	
end

-- Water toggle
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

-- Glow eyes keybind
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

-- Actions
t.toggleAct = action_wheel:newAction()
	:item(itemCheck("ender_pearl"))
	:toggleItem(itemCheck("ender_eye"))
	:onToggle(pings.setEyesToggle)

t.powerAct = action_wheel:newAction()
	:item(itemCheck("cod"))
	:toggleItem(itemCheck("tropical_fish"))
	:onToggle(pings.setEyesPower)
	:toggled(power)

t.nightVisionAct = action_wheel:newAction()
	:item(itemCheck("glass_bottle"))
	:toggleItem(itemCheck("potion{CustomPotionColor:" .. tostring(0x96C54F) .. "}"))
	:onToggle(pings.setEyesNightVision)
	:toggled(nightVision)

t.waterAct = action_wheel:newAction()
	:item(itemCheck("bucket"))
	:toggleItem(itemCheck("water_bucket"))
	:onToggle(pings.setEyesWater)
	:toggled(water)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		t.toggleAct
			:title(toJson
				{"",
				{text = "Toggle Glowing Eyes\n\n", bold = true, color = color.primary},
				{text = "Toggles the glowing of the eyes.\n\n", color = color.secondary},
				{text = "WARNING: ", bold = true, color = "dark_red"},
				{text = "This feature has a tendency to not work correctly.\nDue to the rendering properties of emissives, the eyes may not glow.\nIf it does not work, please reload the avatar. Rinse and Repeat.\nThis is the only fix, I have tried everything.\n\n- Total", color = "red"}}
			)
			:toggled(toggle)
		
		t.powerAct
			:title(toJson
				{"",
				{text = "Origins Power Toggle\n\n", bold = true, color = color.primary},
				{text = "Toggles the glowing based on Origin\'s underwater sight power.\nThe eyes will only glow when this power is active.", color = color.secondary}}
			)
		
		t.nightVisionAct
			:title(toJson
				{"",
				{text = "Night Vision Toggle\n\n", bold = true, color = color.primary},
				{text = "Toggles the glowing based on having the Night Vision effect.\nThis setting will ", color = color.secondary},
				{text = "OVERRIDE ", bold = true, color = color.secondary},
				{text = "the other subsettings.", color = color.secondary}}
			)
		
		t.waterAct
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

-- Return actions
return t
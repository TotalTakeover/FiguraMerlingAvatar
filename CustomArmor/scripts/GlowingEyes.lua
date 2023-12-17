-- Model setup
local model     = models.Merling
local modelEyes = model.Player.Head.Eyes

-- Config setup
config:name("Merling")
local toggle  = config:load("EyesToggle") or false
local origins = config:load("EyesOrigins") or false
local effect  = config:load("EyesEffect") or false
local water   = config:load("EyesWater") or false

-- Eye glow renderer
function events.RENDER(delta, context)
	if context == "RENDER" or context == "FIRST_PERSON" or (not client.isHudEnabled() and context ~= "MINECRAFT_GUI") then
		local glow = glow 
		if toggle then -- Toggle check
			glow = true
			if origins then -- Origins check
				local power = require("lib.OriginsAPI").getPowerData(player, "origins:water_vision")
				glow = glow and power == 1
			end
			if water then -- Water check
				glow = glow and not (water and not player:isUnderwater())
			end
			if effect then -- Night Vision check
				local nV = require("scripts.SyncedVariables").nV
				glow = glow or nV
			end
		else
			glow = false
		end
		modelEyes:secondaryRenderType(glow and "EMISSIVE" or "TRANSLUCENT")
	end
end

-- Glowing eyes toggler
local function setToggle(boolean)
	toggle = boolean
	config:save("EyesToggle", toggle)
	if host:isHost() and player:isLoaded() and toggle then
		sounds:playSound("entity.glow_squid.ambient", player:getPos(), 0.75)
	end
end

-- Glowing eyes origins toggler
local function setOrigins(boolean)
	origins = boolean
	config:save("EyesOrigins", origins)
	if host:isHost() and player:isLoaded() and origins then
		sounds:playSound("minecraft:entity.puffer_fish.flop", player:getPos(), 0.35)
	end
end

-- Glowing eyes night vision toggler
local function setEffect(boolean)
	effect = boolean
	config:save("EyesEffect", effect)
	if host:isHost() and player:isLoaded() and effect then
		sounds:playSound("entity.generic.drink", player:getPos(), 0.35)
	end
end

-- Glowing eyes water toggler
local function setWater(boolean)
	water = boolean
	config:save("EyesWater", water)
	if host:isHost() and player:isLoaded() and water then
		sounds:playSound("minecraft:ambient.underwater.enter", player:getPos(), 0.35)
	end
end

-- Sync variables
local function syncEyes(a, b, c, d)
	toggle  = a
	origins = b
	effect  = c
	water   = d
end

-- Pings setup
pings.setEyesToggle  = setToggle
pings.setEyesOrigins = setOrigins
pings.setEyesEffect  = setEffect
pings.setEyesWater   = setWater
pings.syncEyes       = syncEyes

local eyesBind   = config:load("EyesToggleKeybind") or "key.keyboard.keypad.3"
local setEyesKey = keybinds:newKeybind("Glowing Eyes Toggle"):onPress(function() pings.setEyesToggle(not toggle) end):key(eyesBind)

-- Keybind updater
function events.TICK()
	local key = setEyesKey:getKey()
	if key ~= eyesBind then
		eyesBind = key
		config:save("EyesToggleKeybind", key)
	end
end

-- Sync on tick
if host:isHost() then
	function events.TICK()
		if world.getTime() % 200 == 0 then
			pings.syncEyes(toggle, origins, effect, water)
		end
	end
end

-- Activate actions
setToggle(toggle)
setOrigins(origins)
setEffect(effect)
setWater(water)

-- Table setup
local t = {}

-- Action wheels
t.togglePage = action_wheel:newAction("GlowingEyes")
	:title("§9§lToggle Glowing Eyes\n\n§bToggles the glowing of the eyes.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("minecraft:ender_pearl")
	:toggleItem("minecraft:ender_eye")
	:onToggle(pings.setEyesToggle)
	:toggled(toggle)

-- Update toggle page info
function events.TICK()
	t.togglePage
		:toggled(toggle)
end

t.originsPage = action_wheel:newAction("GlowingEyesOrigins")
	:title("§9§lOrigins Power Toggle\n\n§bToggles the glowing based on Origin's underwater sight power.\nThe eyes will only glow when this power is active.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("minecraft:cod")
	:toggleItem("minecraft:tropical_fish")
	:onToggle(pings.setEyesOrigins)
	:toggled(origins)

t.effectPage = action_wheel:newAction("GlowingEyesNightVision")
	:title("§9§lNight Vision Toggle\n\n§bToggles the glowing based on having the Night Vision effect.\nThis setting will §b§lOVERRIDE §bthe other subsettings.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("minecraft:glass_bottle")
	:toggleItem("minecraft:potion{\"CustomPotionColor\":" .. tostring(0x96C54F) .. "}")
	:onToggle(pings.setEyesEffect)
	:toggled(effect)

t.waterPage = action_wheel:newAction("GlowingEyesWater")
	:title("§9§lWater Sensitivity Toggle\n\n§bToggles the glowing sensitivity to water.\nThe eyes will only glow when underwater.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("minecraft:bucket")
	:toggleItem("minecraft:water_bucket")
	:onToggle(pings.setEyesWater)
	:toggled(water)

-- Return action wheel pages
return t
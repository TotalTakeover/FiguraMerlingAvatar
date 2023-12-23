-- Model setup
local model     = models.Merling
local modelRoot = model.Player

-- Config setup
config:name("Merling")
local glow    = config:load("GlowToggle")
if glow == nil then glow = true end
local dynamic = config:load("GlowDynamic") or false
local water   = config:load("GlowWater") or false

-- Variables setup
local glowParts = {
	modelRoot.Head.Ears.LeftEar.Ear,
	modelRoot.Head.Ears.RightEar.Ear,
	
	model.Skull.skullEars.skullLeftEar.Ear,
	model.Skull.skullEars.skullRightEar.Ear,
	
	modelRoot.Body.Tail1.Segment,
	modelRoot.Body.Tail1.Tail2.Segment,
	modelRoot.Body.Tail1.Tail2.Tail2RightFin,
	modelRoot.Body.Tail1.Tail2.Tail2LeftFin,
	modelRoot.Body.Tail1.Tail2.Tail3.Segment,
	modelRoot.Body.Tail1.Tail2.Tail3.Tail4.Segment,
	modelRoot.Body.Tail1.Tail2.Tail3.Tail4.Fluke,
}

local ticks = require("scripts.WaterTicks")
local glowStart = glow and 1 or 0
local glowCurrent, glowNextTick, glowTarget, glowCurrentPos = glowStart, glowStart, glowStart, glowStart

-- Gradual values
function events.TICK()
	
	-- Glowing color calculation
	local active = glow    and 1 or 0
	local light  = dynamic and math.map(world.getLightLevel(player:getPos(delta)), 0, 15, 1, 0) or 1
	local hydro  = water   and (ticks.wet < 20 and 1 or 0) or 1
	
	-- Target
	glowTarget = active * light * hydro
	
	-- Tick lerp
	glowCurrent = glowNextTick
	glowNextTick = math.lerp(glowNextTick, glowTarget, 0.05)
	
end

function events.RENDER(delta, context)
	
	-- Render lerp
	glowCurrentPos = math.lerp(glowCurrent, glowNextTick, delta)
	
	-- Apply
	for _, part in ipairs(glowParts) do
		part:secondaryColor(glowCurrentPos)
		part:secondaryRenderType(context == "RENDER" and "EMISSIVE" or "EYES")
	end
	
end

-- Glow toggle
local function setGlow(boolean)
	glow = boolean
	config:save("GlowToggle", glow)
	if player:isLoaded() and glow then
		sounds:playSound("entity.glow_squid.ambient", player:getPos(), 0.75)
	end
end

-- Dynamic toggle
local function setDynamic(boolean)
	dynamic = boolean
	config:save("GlowDynamic", dynamic)
	if host:isHost() and player:isLoaded() and dynamic then
		sounds:playSound("entity.generic.drink", player:getPos(), 0.35)
	end
end

-- Water toggle
local function setWater(boolean)
	water = boolean
	config:save("GlowWater", water)
	if host:isHost() and player:isLoaded() and water then
		sounds:playSound("minecraft:ambient.underwater.enter", player:getPos(), 0.35)
	end
end

-- Sync variables
local function syncGlow(a, b, c)
	glow    = a
	dynamic = b
	water   = c
end

-- Pings setup
pings.setGlowToggle  = setGlow
pings.setGlowDynamic = setDynamic
pings.setGlowWater   = setWater
pings.syncGlow       = syncGlow

local glowBind   = config:load("GlowToggleKeybind") or "key.keyboard.keypad.2"
local setGlowKey = keybinds:newKeybind("Glow Toggle"):onPress(function() pings.setGlowToggle(not glow) end):key(glowBind)

-- Keybind updater
function events.TICK()
	local key = setGlowKey:getKey()
	if key ~= glowBind then
		glowBind = key
		config:save("GlowToggleKeybind", key)
	end
end

-- Sync on tick
if host:isHost() then
	function events.TICK()
		if world.getTime() % 200 == 0 then
			pings.syncGlow(glow, dynamic, water)
		end
	end
end

-- Activate actions
setGlow(glow)
setDynamic(dynamic)
setWater(water)

-- Setup table
local t = {}

-- Action wheel pages
t.glowPage = action_wheel:newAction("GlowToggle")
	:title("§9§lToggle Glowing\n\n§bToggles glowing for the tail, and misc parts.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("minecraft:ink_sac")
	:toggleItem("minecraft:glow_ink_sac")
	:onToggle(pings.setGlowToggle)

-- Update glow page info
function events.TICK()
	t.glowPage
		:toggled(glow)
end

t.dynamicPage = action_wheel:newAction("GlowDynamic")
	:title("§9§lToggle Dynamic Glowing\n\n§bToggles glowing based on lightlevel. The darker the location, the brighter your tail glows.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("minecraft:light")
	:onToggle(pings.setGlowDynamic)
	:toggled(dynamic)

-- Update dynamic page info
function events.TICK()
	t.dynamicPage
		:toggleItem("minecraft:light{BlockStateTag:{level:"..world.getLightLevel(player:getPos()).."}}")
end

t.waterPage = action_wheel:newAction("GlowWater")
	:title("§9§lToggle Water Glowing\n\n§bToggles the glowing sensitivity to water.\nAny water will cause your tail to glow.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("minecraft:bucket")
	:toggleItem("minecraft:water_bucket")
	:onToggle(pings.setGlowWater)
	:toggled(water)

-- Return table
return t
-- Required scripts
local parts      = require("lib.GroupIndex")(models)
local itemCheck  = require("lib.ItemCheck")
local waterTicks = require("scripts.WaterTicks")
local color      = require("scripts.ColorProperties")

-- Config setup
config:name("Merling")
local toggle  = config:load("GlowToggle")
local dynamic = config:load("GlowDynamic") or false
local water   = config:load("GlowWater") or false
if toggle == nil then toggle = true end

-- All glowing parts
local glowingParts = {
	
	parts.LeftEar.Ear,
	parts.RightEar.Ear,
	
	parts.LeftEarSkull.Ear,
	parts.RightEarSkull.Ear,
	
	parts.Tail1.Segment,
	parts.Tail2.Segment,
	parts.Tail2LeftFin.Fin,
	parts.Tail2RightFin.Fin,
	parts.Tail3.Segment,
	parts.Tail4.Segment,
	parts.Fluke
	
}

-- Lerp glow table
local glow = {
	current    = 0,
	nextTick   = 0,
	target     = 0,
	currentPos = 0
}

-- Set lerp start on init
function events.ENTITY_INIT()
	
	local apply = toggle and 1 or 0
	for k, v in pairs(glow) do
		glow[k] = apply
	end
	
end

-- Gradual values
function events.TICK()
	
	-- Set glow target
	-- Toggle check
	if toggle then
		
		glow.target = 1
		
		-- Light level check
		if dynamic then
			glow.target = glow.target * math.map(world.getLightLevel(player:getPos(delta)), 0, 15, 1, 0)
		end
		
		-- Water check
		if water then
			glow.target = glow.target * math.map(math.clamp(waterTicks.wet, 0, 100), 0, 100, 1, 0)
		end
		
	else
		
		glow.target = 0
		
	end
	
	-- Tick lerp
	glow.current = glow.nextTick
	glow.nextTick = math.lerp(glow.nextTick, glow.target, 0.05)
	
end

function events.RENDER(delta, context)
	
	-- Render lerp
	glow.currentPos = math.lerp(glow.current, glow.nextTick, delta)
	
	-- Apply
	local renderType = context == "RENDER" and "EMISSIVE" or "EYES"
	for _, part in ipairs(glowingParts) do
		part
			:secondaryColor(glow.currentPos)
			:secondaryRenderType(renderType)
	end
	
end

-- Glow toggle
local function setToggle(boolean)
	
	toggle = boolean
	config:save("GlowToggle", toggle)
	if player:isLoaded() and toggle then
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
		sounds:playSound("ambient.underwater.enter", player:getPos(), 0.35)
	end
	
end

-- Sync variables
local function syncGlow(a, b, c)
	
	toggle  = a
	dynamic = b
	water   = c
	
end

-- Pings setup
pings.setGlowToggle  = setToggle
pings.setGlowDynamic = setDynamic
pings.setGlowWater   = setWater
pings.syncGlow       = syncGlow

-- Keybind
local toggleBind   = config:load("GlowToggleKeybind") or "key.keyboard.keypad.4"
local setToggleKey = keybinds:newKeybind("Glow Toggle"):onPress(function() pings.setGlowToggle(not toggle) end):key(toggleBind)

-- Keybind updater
function events.TICK()
	
	local key = setToggleKey:getKey()
	if key ~= toggleBind then
		toggleBind = key
		config:save("GlowToggleKeybind", key)
	end
	
end

-- Sync on tick
if host:isHost() then
	function events.TICK()
		
		if world.getTime() % 200 == 0 then
			pings.syncGlow(toggle, dynamic, water)
		end
		
	end
end

-- Activate actions
setToggle(toggle)
setDynamic(dynamic)
setWater(water)

-- Setup table
local t = {}

-- Action wheel pages
t.togglePage = action_wheel:newAction()
	:title(color.primary.."Toggle Glowing\n\n"..color.secondary.."Toggles glowing for the tail, and misc parts.")
	:hoverColor(color.hover)
	:toggleColor(color.active)
	:item(itemCheck("ink_sac"))
	:toggleItem(itemCheck("glow_ink_sac"))
	:onToggle(pings.setGlowToggle)

t.dynamicPage = action_wheel:newAction()
	:title(color.primary.."Toggle Dynamic Glowing\n\n"..color.secondary.."Toggles glowing based on lightlevel. The darker the location, the brighter your tail glows.")
	:hoverColor(color.hover)
	:toggleColor(color.active)
	:item(itemCheck("light"))
	:onToggle(pings.setGlowDynamic)
	:toggled(dynamic)

t.waterPage = action_wheel:newAction()
	:title(color.primary.."Toggle Water Glowing\n\n"..color.secondary.."Toggles the glowing sensitivity to water.\nAny water will cause your tail to glow.")
	:hoverColor(color.hover)
	:toggleColor(color.active)
	:item(itemCheck("bucket"))
	:toggleItem(itemCheck("water_bucket"))
	:onToggle(pings.setGlowWater)
	:toggled(water)

-- Update action page info
function events.TICK()
	
	t.togglePage
		:toggled(toggle)
	
	t.dynamicPage
		:toggleItem(itemCheck("light{BlockStateTag:{level:"..world.getLightLevel(player:getPos()).."}}"))
	
end

-- Return action wheel pages
return t
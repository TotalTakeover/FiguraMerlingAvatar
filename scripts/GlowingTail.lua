-- Required scripts
local merlingParts = require("lib.GroupIndex")(models.models.Merling)
local waterTicks   = require("scripts.WaterTicks")

-- Config setup
config:name("Merling")
local toggle  = config:load("GlowToggle")
local dynamic = config:load("GlowDynamic") or false
local water   = config:load("GlowWater") or false
if toggle == nil then toggle = true end

-- Glowing parts
local glowingParts = {
	
	merlingParts.LeftEar.Ear,
	merlingParts.RightEar.Ear,
	
	merlingParts.LeftEarSkull.Ear,
	merlingParts.RightEarSkull.Ear,
	
	merlingParts.Tail1.Segment,
	merlingParts.Tail2.Segment,
	merlingParts.Tail2LeftFin.Fin,
	merlingParts.Tail2RightFin.Fin,
	merlingParts.Tail3.Segment,
	merlingParts.Tail4.Segment,
	merlingParts.Fluke
	
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
	for k in pairs(glow) do
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
function pings.setGlowToggle(boolean)
	
	toggle = boolean
	config:save("GlowToggle", toggle)
	if player:isLoaded() and toggle then
		sounds:playSound("entity.glow_squid.ambient", player:getPos(), 0.75)
	end
	
end

-- Dynamic toggle
function pings.setGlowDynamic(boolean)
	
	dynamic = boolean
	config:save("GlowDynamic", dynamic)
	if host:isHost() and player:isLoaded() and dynamic then
		sounds:playSound("entity.generic.drink", player:getPos(), 0.35)
	end
	
end

-- Water toggle
function pings.setGlowWater(boolean)
	
	water = boolean
	config:save("GlowWater", water)
	if host:isHost() and player:isLoaded() and water then
		sounds:playSound("ambient.underwater.enter", player:getPos(), 0.35)
	end
	
end

-- Sync variables
function pings.syncGlow(a, b, c)
	
	toggle  = a
	dynamic = b
	water   = c
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local color     = require("scripts.ColorProperties")

-- Glow keybind
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
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncGlow(toggle, dynamic, water)
	end
	
end

-- Table setup
local t = {}

-- Actions
t.togglePage = action_wheel:newAction()
	:item(itemCheck("ink_sac"))
	:toggleItem(itemCheck("glow_ink_sac"))
	:onToggle(pings.setGlowToggle)

t.dynamicPage = action_wheel:newAction()
	:item(itemCheck("light"))
	:onToggle(pings.setGlowDynamic)
	:toggled(dynamic)

t.waterPage = action_wheel:newAction()
	:item(itemCheck("bucket"))
	:toggleItem(itemCheck("water_bucket"))
	:onToggle(pings.setGlowWater)
	:toggled(water)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		t.togglePage
			:title(toJson
				{"",
				{text = "Toggle Glowing\n\n", bold = true, color = color.primary},
				{text = "Toggles glowing for the tail, and misc parts.\n\n", color = color.secondary},
				{text = "WARNING: ", bold = true, color = "dark_red"},
				{text = "This feature has a tendency to not work correctly.\nDue to the rendering properties of emissives, the tail may not glow.\nIf it does not work, please reload the avatar. Rinse and Repeat.\nThis is the only fix, I have tried everything.\n\n- Total", color = "red"}}
			)
			:toggled(toggle)
		
		t.dynamicPage
			:title(toJson
				{"",
				{text = "Toggle Dynamic Glowing\n\n", bold = true, color = color.primary},
				{text = "Toggles glowing based on lightlevel.\nThe darker the location, the brighter your tail glows.", color = color.secondary}}
			)
			:toggleItem(itemCheck("light{BlockStateTag:{level:"..world.getLightLevel(player:getPos()).."}}"))
		
		t.waterPage
			:title(toJson
				{"",
				{text = "Toggle Water Glowing\n\n", bold = true, color = color.primary},
				{text = "Toggles the glowing sensitivity to water.\nAny water will cause your tail to glow.", color = color.secondary}}
			)
		
		for _, page in pairs(t) do
			page:hoverColor(color.hover):toggleColor(color.active)
		end
		
	end
	
end

-- Return actions
return t
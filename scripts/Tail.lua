-- Required scripts
local parts      = require("lib.GroupIndex")(models)
local waterTicks = require("scripts.WaterTicks")
local ground     = require("lib.GroundCheck")

-- Config setup
config:name("Merling")
local tailActive = config:load("TailActive")
local water      = config:load("TailWater") or 3
local canDry     = config:load("TailDry")
local dryTimer   = config:load("TailDryTimer") or 400
local fallSound  = config:load("TailFallSound")
if tailActive == nil then tailActive = true end
if canDry     == nil then canDry = true end
if fallSound  == nil then fallSound = true end

-- Variables setup
local wasInAir = false

-- Lerp scale table
local scale = {
	current    = 0,
	nextTick   = 0,
	target     = 0,
	currentPos = 0
}

-- Set lerp start on init
function events.ENTITY_INIT()
	
	local apply = tailActive and 1 or 0
	for k, v in pairs(scale) do
		scale[k] = apply
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
	scale.target = tailActive and waterState[water] <= (canDry and dryTimer or 20) and 1 or 0
	
	-- Tick lerp
	scale.current  = scale.nextTick
	scale.nextTick = math.lerp(scale.nextTick, scale.target, 0.2)
	
	-- Play sound if conditions are met
	if fallSound and wasInAir and ground() and scale.currentPos >= 0.5 and not player:getVehicle() and not player:isInWater() then
		local vel    = math.abs(-player:getVelocity().y + 1)
		local dry    = canDry and (dryTimer - waterState[water]) / dryTimer or 1
		local volume = math.clamp((vel * dry) / 2, 0, 1)
		
		if volume ~= 0 then
			sounds:playSound("minecraft:entity.puffer_fish.flop", player:getPos(), volume, math.map(volume, 1, 0, 0.45, 0.65))
		end
	end
	wasInAir = not ground()
	
end

function events.RENDER(delta, context)
	
	-- Render lerp
	scale.currentPos = math.lerp(scale.current, scale.nextTick, delta)
	
	-- Apply tail
	parts.Tail1:scale(scale.currentPos)
	
	-- Apply legs
	local legScale = math.map(scale.currentPos, 1, 0, 0, 1)
	parts.LeftLeg:scale(legScale)
	parts.RightLeg:scale(legScale)
	
end

-- Tail toggle
local function setTail(boolean)
	
	tailActive = boolean
	config:save("TailActive", tailActive)
	
end

-- Water sensitivity
local function setWater(i)
	
	water = water + i
	if water > 4 then water = 1 end
	if water < 1 then water = 4 end
	if player:isLoaded() and host:isHost() and i ~= 0 then
		sounds:playSound("minecraft:ambient.underwater.enter", player:getPos(), 0.35)
	end
	config:save("TailWater", water)
	
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
		sounds:playSound("minecraft:entity.puffer_fish.flop", player:getPos(), 0.35, 0.6)
	end
	
end

-- Sync variables
local function syncTail(a, b, c, x, d)
	
	tailActive = a
	water      = b
	canDry     = c
	dryTimer   = x
	fallSound  = d
	
end

-- Pings setup
pings.setTailActive    = setTail
pings.setTailWater     = setWater
pings.setTailDry       = setDry
pings.setTailFallSound = setFallSound
pings.syncTail         = syncTail

-- Keybind
local tailBind   = config:load("TailToggleKeybind") or "key.keyboard.keypad.1"
local setTailKey = keybinds:newKeybind("Tail Toggle"):onPress(function() pings.setTailActive(not tailActive) end):key(tailBind)

-- Keybind updater
function events.TICK()
	
	local key = setTailKey:getKey()
	if key ~= tailBind then
		tailBind = key
		config:save("TailToggleKeybind", key)
	end
	
end

-- Sync on tick
if host:isHost() then
	function events.TICK()
		
		if world.getTime() % 200 == 0 then
			pings.syncTail(tailActive, water, canDry, dryTimer, fallSound)
		end
		
	end
end

-- Activate actions
setTail(tailActive)
setWater(0)
setDry(canDry)
setFallSound(fallSound)

-- Table setup
local t = {}

-- Action wheel pages
t.tailPage = action_wheel:newAction("TailActive")
	:title("§9§lToggle Tail Functionality\n\n§bToggles the ability for your tail to appear in place of your legs.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("minecraft:rabbit_foot")
	:toggleItem("minecraft:tropical_fish")
	:onToggle(pings.setTailActive)

t.waterPage = action_wheel:newAction("TailWater")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:onLeftClick(function() pings.setTailWater(1)end)
	:onRightClick(function() pings.setTailWater(-1) end)

t.dryPage = action_wheel:newAction("TailDrying")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("minecraft:water_bucket")
	:toggleItem("minecraft:leather")
	:onToggle(pings.setTailDry)
	:onScroll(setDryTimer)
	:onRightClick(function() dryTimer = 400 config:save("TailDryTimer", dryTimer) end)
	:toggled(canDry)

t.soundPage = action_wheel:newAction("TailFallSound")
	:title("§9§lToggle Flop Sound\n\n§bToggles flopping sound effects when landing on the ground.\nIf tail can dry, volume will gradually decrease over time until dry. (Acts like a timer!)")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("minecraft:sponge")
	:toggleItem("minecraft:wet_sponge")
	:onToggle(pings.setTailFallSound)
	:toggled(fallSound)

-- Water context info table
local waterInfo = {
	{
		title  = "§c§lLow §r| §bReactive to being underwater.",
		item   = "minecraft:glass_bottle",
		color  = "FF5555"
	},
	{
		title  = "§e§lMedium §r| §bReactive to being in water.",
		item   = "minecraft:potion{\"CustomPotionColor\":" .. tostring(0x0094FF) .. "}",
		color  = "FFFF55"
	},
	{
		title  = "§a§lHigh §r| §bReactive to any form of water.",
		item   = "minecraft:splash_potion{\"CustomPotionColor\":" .. tostring(0x0094FF) .. "}",
		color  = "55FF55"
	},
	{
		title  = "§9§lMax §r| §bAlways active.",
		item   = "minecraft:lingering_potion{\"CustomPotionColor\":" .. tostring(0x0094FF) .. "}",
		color  = "5555FF"
	},
}

-- Updates action page info
function events.TICK()
	
	t.tailPage:toggled(tailActive)
	t.waterPage
		:title("§9§lWater Sensitivity\n\n§3Current configuration: "..waterInfo[water].title.."\n\n§bDetermines how your tail should form in contact with water.")
		:item(waterInfo[water].item)
		:color(vectors.hexToRGB(waterInfo[water].color))
	t.dryPage:title("§9§lToggle Drying/Timer\n\n§3Current drying timer: "..
		(canDry and ("§b§l"..(dryTimer / 20).." §3Seconds") or "§bNone")..
		"\n\n§bToggles the gradual drying of your tail until your legs form again.\n\nScrolling up adds time, Scrolling down subtracts time.\nRight click resets timer to 20 seconds.")
	
end

-- Return action wheel pages
return t
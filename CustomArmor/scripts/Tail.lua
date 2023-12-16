-- Model setup
local model     = models.Merling
local modelRoot = model.Player
local tail      = modelRoot.Body.Tail1
local legs      = {
	modelRoot.LeftLeg,
	modelRoot.RightLeg,
}

-- Config setup
config:name("Merling")
local tailActive = config:load("TailActive")
if tailActive == nil then tailActive = true end
local water = config:load("TailWater") or 3
local canDry = config:load("TailDry")
if canDry == nil then canDry = true end
local dryTimer = config:load("TailDryTimer") or 400
local fallSound = config:load("TailFallSound")
if fallSound == nil then fallSound = true end

-- Variables setup
local ticks    = require("scripts.WaterTicks")
local ground   = require("lib.GroundCheck")
local formTail = tailActive
local wasInAir = false

-- Lerping variables
local scaleStart = formTail and 1 or 0
local scaleCurrent, scaleNextTick, scaleTarget, scaleCurrentPos = scaleStart, scaleStart, scaleStart, scaleStart

function events.TICK()
	
	-- Update water state table
	local waterState = {
		ticks.under,
		ticks.water,
		ticks.wet,
		0
	}
	
	-- Should tail form
	formTail = tailActive and waterState[water] <= (canDry and dryTimer or 20)
	
	-- Play sound if conditions are met
	if fallSound and wasInAir and ground() and scaleCurrentPos >= 0.5 and not player:getVehicle() and not player:isInWater() then
		local vel    = math.abs(-player:getVelocity().y + 1)
		local dry    = canDry and (dryTimer - waterState[water]) / dryTimer or 1
		local volume = math.clamp((vel * dry) / 2, 0, 1)
		
		if volume ~= 0 then
			sounds:playSound("minecraft:entity.puffer_fish.flop", player:getPos(), volume, math.map(volume, 1, 0, 0.45, 0.65))
		end
	end
	
	-- Update ground variable
	wasInAir = not ground()
	
	-- Scaling lerp
	scaleCurrent  = scaleNextTick
	scaleNextTick = math.lerp(scaleNextTick, scaleTarget, 0.2)
end

function events.RENDER(delta, context)
	if context == "RENDER" or context == "FIRST_PERSON" or (not client.isHudEnabled() and context ~= "MINECRAFT_GUI") then
		
		-- Scaling target and lerp
		scaleTarget     = formTail and 1 or 0
		scaleCurrentPos = math.lerp(scaleCurrent, scaleNextTick, delta)
		
		-- Scale tail
		tail:scale(scaleCurrentPos)
		
		-- Scale leg parts
		for _, part in ipairs(legs) do
			part:scale(math.map(scaleCurrentPos, 1, 0, 0, 1))
		end
		
	end
end

-- Tail toggler
local function setTail(boolean)
	tailActive = boolean
	config:save("TailActive", tailActive)
end

-- Water context changer
local function setWater(i)
	water = water + i
	if water > 4 then water = 1 end
	if water < 1 then water = 4 end
	if player:isLoaded() and host:isHost() and i ~= 0 then
		sounds:playSound("minecraft:ambient.underwater.enter", player:getPos(), 0.35)
	end
	config:save("TailWater", water)
end

-- Dry toggler
local function setDry(boolean)
	canDry = boolean
	config:save("TailDry", canDry)
end

-- Set timer function
local function setDryTimer(x)
	dryTimer = math.clamp(dryTimer + (x * 20), 100, 6000)
	config:save("TailDryTimer", dryTimer)
end

-- Sound toggler
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
	:toggled(tailActive)

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

-- Update page info
function events.TICK()
	t.waterTitle = "§9§lWater Sensitivity\n\n§3Current configuration: "..waterInfo[water].title.."\n\n§bDetermines how your tail should form in contact with water."
	t.waterItem  = waterInfo[water].item
	t.waterColor = waterInfo[water].color
end

t.waterPage = action_wheel:newAction("TailWater")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:onLeftClick(function() pings.setTailWater(1)end)
	:onRightClick(function() pings.setTailWater(-1) end)

-- Update page title
function events.TICK()
	local current = "§3Current drying timer: "..(canDry and ("§b§l"..(dryTimer / 20).." §3Seconds") or "§bNone")
	t.dryTitle = "§9§lToggle Drying/Timer\n\n"..current.."\n\n§bToggles the gradual drying of your tail until your legs form again.\n\nScrolling up adds time, Scrolling down subtracts time.\nRight click resets timer to 20 seconds."
end

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

-- Return table
return t
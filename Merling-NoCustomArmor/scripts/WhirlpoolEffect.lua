-- Config setup
config:name("Merling")
local bubbles = config:load("WhirlpoolBubbles")
if bubbles == nil then bubbles = true end
local effect  = config:load("WhirlpoolEffect") or false

-- Bubble spawner
local numBubbles = 8
function events.TICK()
	local dG = require("scripts.SyncedVariables").dG
	if effect and not dG then return end
	if player:getPose() == "SWIMMING" and bubbles and player:isInWater() then
		local worldMatrix = models:partToWorldMatrix()
		for i = 1, numBubbles do
			particles:newParticle("minecraft:bubble",
				(worldMatrix * matrices.rotation4(0, world.getTime() * 10 - 360/numBubbles * i)):apply(15, 15)
			)
		end
	end
end

-- Bubbles toggle
local function setBubbles(boolean)
	bubbles = boolean
	config:save("WhirlpoolBubbles", bubbles)
	if host:isHost() and player:isLoaded() and bubbles then
		sounds:playSound("minecraft:block.bubble_column.upwards_inside", player:getPos(), 0.35)
	end
end

-- Dolphins Grace toggle
local function setEffect(boolean)
	effect = boolean
	config:save("WhirlpoolEffect", effect)
	if host:isHost() and player:isLoaded() and effect then
		sounds:playSound("minecraft:entity.dolphin.ambient", player:getPos(), 0.35)
	end
end

-- Sync variables
local function syncWhirlpool(a, b)
	bubbles = a
	effect  = b
end

-- Pings setup
pings.setWhirlpoolBubbles = setBubbles
pings.setWhirlpoolEffect  = setEffect
pings.syncWhirlpool       = syncWhirlpool

-- Sync on tick
if host:isHost() then
	function events.TICK()
		if world.getTime() % 200 == 0 then
			pings.syncWhirlpool(bubbles, effect)
		end
	end
end

-- Activate actions
setBubbles(bubbles)
setEffect(effect)

-- Table setip
local t = {}

-- Action wheel pages
t.bubblePage = action_wheel:newAction("Whirlpool")
	:title("§9§lWhirlpool Effect Toggle\n\n§bToggles the whirlpool created while swimming.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("minecraft:soul_sand")
	:toggleItem("magma_block")
	:onToggle(pings.setWhirlpoolBubbles)
	:toggled(bubbles)

t.effectPage = action_wheel:newAction("WhirlpoolDolphinsGrace")
	:title("§9§lDolphin's Grace Toggle\n\n§bToggles the whirlpool based on having the Dolphin's Grace Effect.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("minecraft:egg")
	:toggleItem("minecraft:dolphin_spawn_egg")
	:onToggle(pings.setWhirlpoolEffect)
	:toggled(effect)

-- Returns table
return t
-- Required scripts
local effects = require("scripts.SyncedVariables")
local pose    = require("scripts.Posing")

-- Config setup
config:name("Merling")
local bubbles       = config:load("WhirlpoolBubbles")
local dolphinsGrace = config:load("WhirlpoolDolphinsGrace") or false
if bubbles == nil then bubbles = true end

-- Bubble spawner
local numBubbles = 8
function events.TICK()
	
	if dolphinsGrace and not effects.dG then return end
	if pose.swim and bubbles and player:isInWater() then
		local worldMatrix = models:partToWorldMatrix()
		for i = 1, numBubbles do
			particles:newParticle("bubble",
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
		sounds:playSound("block.bubble_column.upwards_inside", player:getPos(), 0.35)
	end
	
end

-- Dolphins Grace toggle
local function setDolphinsGrace(boolean)
	
	dolphinsGrace = boolean
	config:save("WhirlpoolDolphinsGrace", dolphinsGrace)
	if host:isHost() and player:isLoaded() and dolphinsGrace then
		sounds:playSound("entity.dolphin.ambient", player:getPos(), 0.35)
	end
	
end

-- Sync variables
local function syncWhirlpool(a, b)
	
	bubbles        = a
	dolphinsGrace  = b
	
end

-- Pings setup
pings.setWhirlpoolBubbles       = setBubbles
pings.setWhirlpoolDolphinsGrace = setDolphinsGrace
pings.syncWhirlpool             = syncWhirlpool

-- Sync on tick
if host:isHost() then
	function events.TICK()
		
		if world.getTime() % 200 == 0 then
			pings.syncWhirlpool(bubbles, dolphinsGrace)
		end
		
	end
end

-- Activate actions
setBubbles(bubbles)
setDolphinsGrace(dolphinsGrace)

-- Table setup
local t = {}

-- Action wheel pages
t.bubblePage = action_wheel:newAction()
	:title("§9§lWhirlpool Effect Toggle\n\n§bToggles the whirlpool created while swimming.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("soul_sand")
	:toggleItem("magma_block")
	:onToggle(pings.setWhirlpoolBubbles)
	:toggled(bubbles)

t.dolphinsGracePage = action_wheel:newAction()
	:title("§9§lDolphin's Grace Toggle\n\n§bToggles the whirlpool based on having the Dolphin's Grace Effect.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("egg")
	:toggleItem("dolphin_spawn_egg")
	:onToggle(pings.setWhirlpoolDolphinsGrace)
	:toggled(dolphinsGrace)

-- Return action wheel pages
return t
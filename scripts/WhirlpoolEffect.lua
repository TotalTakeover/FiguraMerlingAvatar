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
function pings.setWhirlpoolBubbles(boolean)
	
	bubbles = boolean
	config:save("WhirlpoolBubbles", bubbles)
	if host:isHost() and player:isLoaded() and bubbles then
		sounds:playSound("block.bubble_column.upwards_inside", player:getPos(), 0.35)
	end
	
end

-- Dolphins Grace toggle
function pings.setWhirlpoolDolphinsGrace(boolean)
	
	dolphinsGrace = boolean
	config:save("WhirlpoolDolphinsGrace", dolphinsGrace)
	if host:isHost() and player:isLoaded() and dolphinsGrace then
		sounds:playSound("entity.dolphin.ambient", player:getPos(), 0.35)
	end
	
end

-- Sync variables
function pings.syncWhirlpool(a, b)
	
	bubbles        = a
	dolphinsGrace  = b
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local s, c = pcall(require, "scripts.ColorProperties")
if not s then c = {} end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncWhirlpool(bubbles, dolphinsGrace)
	end
	
end

-- Table setup
local t = {}

-- Actions
t.bubbleAct = action_wheel:newAction()
	:item(itemCheck("soul_sand"))
	:toggleItem(itemCheck("magma_block"))
	:onToggle(pings.setWhirlpoolBubbles)
	:toggled(bubbles)

t.dolphinsGraceAct = action_wheel:newAction()
	:item(itemCheck("egg"))
	:toggleItem(itemCheck("dolphin_spawn_egg"))
	:onToggle(pings.setWhirlpoolDolphinsGrace)
	:toggled(dolphinsGrace)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		t.bubbleAct
			:title(toJson(
				{
					"",
					{text = "Whirlpool Effect Toggle\n\n", bold = true, color = c.primary},
					{text = "Toggles the whirlpool created while swimming.", color = c.secondary}
				}
			))
		
		t.dolphinsGraceAct
			:title(toJson(
				{
					"",
					{text = "Dolphin\'s Grace Toggle\n\n", bold = true, color = c.primary},
					{text = "Toggles the whirlpool based on having the Dolphin\'s Grace Effect.", color = c.secondary}
				}
			))
		
		for _, act in pairs(t) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end

-- Return actions
return t
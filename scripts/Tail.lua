-- Required scripts
local parts   = require("lib.PartsAPI")
local lerp    = require("lib.LerpAPI")
local ground  = require("lib.GroundCheck")
local effects = require("scripts.SyncedVariables")

-- Config setup
config:name("Merling")
local tailType  = config:load("TailType") or 4
local earsType  = config:load("TailEarsType") or tailType
local small     = config:load("TailSmall")
local smallSize = config:load("TailSmallSize") or 0.5
local dryTimer  = config:load("TailDryTimer") or 400
local legsForm  = config:load("TailLegsForm") or 0.75
local gradual   = config:load("TailGradual")
local fallSound = config:load("TailFallSound")
if small     == nil then small = true end
if gradual   == nil then gradual = true end
if fallSound == nil then fallSound = true end

-- Variables setup
local tailTimer = 0
local earsTimer = 0
local wasInAir  = false

-- Lerp variables
local smallLerp = lerp:new(0.2, smallSize)
local scale = {
	tail  = lerp:new(0.2, tailType == 5 and 1 or 0),
	legs  = lerp:new(0.2, tailType ~= 5 and 1 or 0),
	ears  = lerp:new(0.2, earsType == 5 and 1 or 0),
	small = lerp:new(0.2, small and 1 or 0)
}

-- Data sent to other scripts
local tailData = {
	scale     = math.lerp(smallLerp.currPos * scale.small.currPos, 1, scale.tail.currPos),
	isLarge   = scale.tail.currPos >= legsForm,
	isSmall   = scale.small.currPos >= legsForm and scale.tail.currPos <= legsForm,
	legs      = scale.legs.currPos,
	height    = math.max(math.lerp(smallLerp.currPos * scale.small.currPos, 1, scale.tail.currPos), scale.legs.currPos),
	smallSize = smallLerp.currPos,
	dry       = dryTimer
}

-- Check if a splash potion is broken near the player
local splash = false
function events.ON_PLAY_SOUND(id, pos, vol, pitch, loop, category, path)
	
	if player:isLoaded() then
		local atPos    = pos < player:getPos() + 2 and pos > player:getPos() - 2
		local splashID = id == "minecraft:entity.splash_potion.break" or id == "minecraft:entity.lingering_potion.break"
		splash = atPos and splashID and path
	end
	
end

function events.TICK()
	
	-- Arm variables
	local handedness  = player:isLeftHanded()
	local activeness  = player:getActiveHand()
	local leftActive  = not handedness and "OFF_HAND" or "MAIN_HAND"
	local rightActive = handedness and "OFF_HAND" or "MAIN_HAND"
	local leftItem    = player:getHeldItem(not handedness)
	local rightItem   = player:getHeldItem(handedness)
	local using       = player:isUsingItem()
	local drinkingL   = activeness == leftActive and using and leftItem:getUseAction() == "DRINK"
	local drinkingR   = activeness == rightActive and using and rightItem:getUseAction() == "DRINK"
	
	-- Check for if player has gone underwater
	local under = player:isUnderwater() or player:isInLava()
	
	-- Check for if player is in liquid
	local water = under or player:isInWater()
	
	-- Check for if player touches any liquid
	local wet = water or player:isWet() or ((drinkingL or drinkingR) and player:getActiveItemTime() > 20) or splash
	if wet then
		splash = false
	end
	
	-- Water state table
	local waterState = {
		false,
		under,
		water,
		wet,
		true
	}
	
	-- Control how fast drying occurs
	local dryRate = player:getItem(1).id == "minecraft:sponge" and 10 or 1
	
	-- Zero check
	local modDryTimer = math.max(dryTimer, 1)
	
	-- Adjust tail timer based on state
	if waterState[tailType] then
		tailTimer = modDryTimer
	elseif tailType == 1 then
		tailTimer = 0
	else
		tailTimer = math.clamp(tailTimer - 1 * dryRate, 0, modDryTimer)
	end
	
	-- Adjust ears timer based on state
	if waterState[earsType] then
		earsTimer = modDryTimer
	elseif earsType == 1 then
		earsTimer = 0
	else
		earsTimer = math.clamp(earsTimer - 1 * dryRate, 0, modDryTimer)
	end
	
	-- Targets
	smallLerp.target = smallSize
	if gradual then
		
		-- Gradual lerp
		scale.tail.target  = tailTimer / modDryTimer
		scale.legs.target  = tailTimer / modDryTimer <= legsForm and 1 or 0
		scale.ears.target  = earsTimer / modDryTimer
		scale.small.target = small and 1 or 0
		
	else
		
		-- Instant lerp
		scale.tail.target  = tailTimer ~= 0 and 1 or 0
		scale.legs.target  = tailTimer == 0 and 1 or 0
		scale.ears.target  = earsTimer ~= 0 and 1 or 0
		scale.small.target = small and 1 or 0
		
	end
	
	-- Play sound if conditions are met
	if fallSound and wasInAir and ground() and scale.legs.target ~= 1 and not player:getVehicle() and not player:isInWater() and not effects.cF then
		local vel    = math.abs(-player:getVelocity().y + 1)
		local dry    = scale.tail.currPos
		local volume = math.clamp((vel * dry) / 2, 0, 1)
		
		if volume ~= 0 then
			sounds:playSound("entity.puffer_fish.flop", player:getPos(), volume, math.map(volume, 1, 0, 0.45, 0.65))
		end
	end
	wasInAir = not ground()
	
end

function events.RENDER(delta, context)

	-- Force Current Positions to be targets
	if not gradual then
		smallLerp.currPos = smallLerp.target
		for _, lerp in pairs(scale) do
			lerp.currPos = lerp.target
		end
	end
	
	-- Variables
	local tailApply = math.lerp(smallLerp.currPos * scale.small.currPos, 1, scale.tail.currPos)
	local legsApply = scale.legs.currPos
	local earsApply = scale.ears.currPos
	
	-- Apply tail
	parts.group.Tail1:scale(tailApply)
	
	-- Apply legs
	parts.group.LeftLeg:scale(legsApply)
	parts.group.RightLeg:scale(legsApply)
	
	-- Apply ears
	parts.group.LeftEar:scale(earsApply)
	parts.group.RightEar:scale(earsApply)
	parts.group.LeftEarSkull:scale(earsApply)
	parts.group.RightEarSkull:scale(earsApply)
	
	-- Update tail data
	tailData.scale     = tailApply
	tailData.isLarge   = scale.tail.currPos >= legsForm
	tailData.isSmall   = scale.small.currPos >= legsForm and scale.tail.currPos <= legsForm
	tailData.legs      = scale.legs.currPos
	tailData.height    = math.max(tailApply, scale.legs.currPos)
	tailData.smallSize = smallLerp.currPos
	tailData.dry       = dryTimer
	
end

-- Set sensitivity
local function setSensitivity(sen, i)
	
	sen = ((sen + i - 1) % 5) + 1
	if player:isLoaded() and host:isHost() then
		sounds:playSound("ambient.underwater.enter", player:getPos(), 0.35)
	end
	
	return sen
	
end

-- Tail sensitivity
function pings.setTailType(i)
	
	tailType = setSensitivity(tailType, i)
	config:save("TailType", tailType)
	
end

-- Ears sensitivity
function pings.setTailEarsType(i)
	
	earsType = setSensitivity(earsType, i)
	config:save("TailEarsType", earsType)
	
end

-- Small toggle
function pings.setTailSmall(boolean)
	
	small = boolean
	config:save("TailSmall", small)
	
end

-- Set small size
local function setSmallSize(x)
	
	smallSize = math.clamp(smallSize + (x * 0.05), 0.25, 1)
	config:save("TailSmallSize", smallSize)
	
end

-- Set small size
local function setLegsForm(x)
	
	legsForm = math.clamp(legsForm + (x * 0.05), 0.25, 0.9)
	config:save("TailLegsForm", legsForm)
	
end

-- Set timer
local function setDryTimer(x)
	
	dryTimer = math.clamp(dryTimer + (x * 20), 0, 72000)
	config:save("TailDryTimer", dryTimer)
	
end

-- Gradual toggle
function pings.setTailGradual(boolean)
	
	gradual = boolean
	config:save("TailGradual", gradual)
	
end

-- Sound toggle
function pings.setTailFallSound(boolean)

	fallSound = boolean
	config:save("TailFallSound", fallSound)
	if host:isHost() and player:isLoaded() and fallSound then
		sounds:playSound("entity.puffer_fish.flop", player:getPos(), 0.35, 0.6)
	end
	
end

-- Sync variables
function pings.syncTail(a, b, c, d, e, f, g, h)
	
	tailType  = a
	earsType  = b
	small     = c
	smallSize = d
	dryTimer  = e
	legsForm  = f
	gradual   = g
	fallSound = h
	
end

-- Host only instructions, return tail data
if not host:isHost() then return tailData end

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local s, c = pcall(require, "scripts.ColorProperties")
if not s then c = {} end

-- Tail Keybind
local tailBind   = config:load("TailTypeKeybind") or "key.keyboard.keypad.1"
local setTailKey = keybinds:newKeybind("Tail Sensitivity Type"):onPress(function() pings.setTailType(1) end):key(tailBind)

-- Ears keybind
local earsBind   = config:load("TailEarsTypeKeybind") or "key.keyboard.keypad.2"
local setEarsKey = keybinds:newKeybind("Ears Sensitivity Type"):onPress(function() pings.setTailEarsType(1) end):key(earsBind)

-- Small tail keybind
local smallBind   = config:load("TailSmallKeybind") or "key.keyboard.keypad.3"
local setSmallKey = keybinds:newKeybind("Small Tail Toggle"):onPress(function() pings.setTailSmall(not small) end):key(smallBind)

-- Keybind updaters
function events.TICK()
	
	local tailKey  = setTailKey:getKey()
	local earsKey  = setEarsKey:getKey()
	local smallKey = setSmallKey:getKey()
	if tailKey ~= tailBind then
		tailBind = tailKey
		config:save("TailTypeKeybind", tailKey)
	end
	if earsKey ~= earsBind then
		earsBind = earsKey
		config:save("TailEarsTypeKeybind", earsKey)
	end
	if smallKey ~= smallBind then
		smallBind = smallKey
		config:save("TailSmallKeybind", smallKey)
	end
	
end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncTail(tailType, earsType, small, smallSize, dryTimer, legsForm, gradual, fallSound)
	end
	
end

-- Table setup
local t = {}

-- Actions
t.tailAct = action_wheel:newAction()
	:onLeftClick(function() pings.setTailType(1) end)
	:onRightClick(function() pings.setTailType(-1) end)
	:onScroll(pings.setTailType)

t.earsAct = action_wheel:newAction()
	:onLeftClick(function() pings.setTailEarsType(1) end)
	:onRightClick(function() pings.setTailEarsType(-1) end)
	:onScroll(pings.setTailEarsType)

t.smallAct = action_wheel:newAction()
	:item(itemCheck("small_amethyst_bud"))
	:onToggle(pings.setTailSmall)
	:onScroll(setSmallSize)

t.dryAct = action_wheel:newAction()
	:onScroll(setDryTimer)
	:onLeftClick(function() dryTimer = 400 config:save("TailDryTimer", dryTimer) end)

t.legsAct = action_wheel:newAction()
	:item(itemCheck("rabbit_foot"))
	:onScroll(setLegsForm)

t.gradualAct = action_wheel:newAction()
	:item(itemCheck("sugar"))
	:toggleItem(itemCheck("fermented_spider_eye"))
	:onToggle(pings.setTailGradual)

t.soundAct = action_wheel:newAction()
	:item(itemCheck("bucket"))
	:toggleItem(itemCheck("water_bucket"))
	:onToggle(pings.setTailFallSound)
	:toggled(fallSound)

-- Water context info table
local waterInfo = {
	{
		title = {label = {text = "None", color = "red"}, text = "Cannot form."},
		item  = "glass_bottle",
		color = "FF5555"
	},
	{
		title = {label = {text = "Low", color = "yellow"}, text = "Reactive to being underwater."},
		item  = "potion",
		color = "FFFF55"
	},
	{
		title = {label = {text = "Medium", color = "green"}, text = "Reactive to being in water."},
		item  = "splash_potion",
		color = "55FF55"
	},
	{
		title = {label = {text = "High", color = "aqua"}, text = "Reactive to any form of water."},
		item  = "lingering_potion",
		color = "55FFFF"
	},
	{
		title = {label = {text = "Max", color = "blue"}, text = "Always active."},
		item  = "dragon_breath",
		color = "5555FF"
	}
}

-- Creates a clock string
local function timeStr(s)

	local min = s >= 60
		and ("%d Minute%s"):format(s / 60, s >= 120 and "s" or "")
		or nil
	
	local sec = ("%d Second%s"):format(s % 60, s % 60 == 1 and "" or "s")
	
	return min and (min.." "..sec) or sec
	
end

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		local actionSetup = waterInfo[tailType]
		t.tailAct
			:title(toJson(
				{
					"",
					{text = "Tail Water Sensitivity\n\n", bold = true, color = c.primary},
					{text = "Determines how your tail should form in contact with water.\n\n", color = c.secondary},
					{text = "Current configuration: ", bold = true, color = c.secondary},
					{text = actionSetup.title.label.text, color = actionSetup.title.label.color},
					{text = " | "},
					{text = actionSetup.title.text, color = c.secondary}
				}
			))
			:color(vectors.hexToRGB(actionSetup.color))
			:item(itemCheck(actionSetup.item.."{CustomPotionColor:"..tostring(0x0094FF).."}"))
		
		local actionSetup = waterInfo[earsType]
		t.earsAct
			:title(toJson(
				{
					"",
					{text = "Ears Water Sensitivity\n\n", bold = true, color = c.primary},
					{text = "Determines how your ears should form in contact with water.\n\n", color = c.secondary},
					{text = "Current configuration: ", bold = true, color = c.secondary},
					{text = actionSetup.title.label.text, color = actionSetup.title.label.color},
					{text = " | "},
					{text = actionSetup.title.text, color = c.secondary}
				}
			))
			:color(vectors.hexToRGB(actionSetup.color))
			:item(itemCheck(actionSetup.item.."{CustomPotionColor:"..tostring(0x0094FF).."}"))
		
		t.smallAct
			:title(toJson(
				{
					"",
					{text = "Toggle Small Tail\n\n", bold = true, color = c.primary},
					{text = "Toggles the appearence of the tail into a smaller tail, only if the tail cannot form.\nScroll to control the size of the small tail.\n\n", color = c.secondary},
					{text = "Small tail size:\n", bold = true, color = c.secondary},
					{text = math.round(smallSize * 100).."% Size"}
				}
			))
			:toggleItem(
				itemCheck(
					smallSize > 0.75 and "amethyst_cluster" or
					smallSize > 0.5 and "large_amethyst_bud" or
					"medium_amethyst_bud"
				)
			)
			:toggled(small)
		
		-- Timers
		local timers = {
			set  = dryTimer / 20,
			legs = gradual and math.max(math.ceil((tailTimer - (dryTimer * legsForm)) / 20), 0) or nil,
			tail = math.ceil(tailTimer / 20),
			ears = math.ceil(earsTimer / 20)
		}
		
		-- Countdowns
		local cD = {}
		for k, v in pairs(timers) do
			cD[k] = timeStr(v)
		end
		
		t.dryAct
			:title(toJson(
				{
					"",
					{text = "Set Drying Timer\n\n", bold = true, color = c.primary},
					{text = "Scroll to adjust how long it takes for you to dry.\nLeft click resets timer to 20 seconds.\n\n", color = c.secondary},
					{text = "Drying timer:\n", bold = true, color = c.secondary},
					{text = cD.set.."\n\n"},
					{text = cD.legs and "Legs form:\n" or "", bold = true, color = c.secondary},
					{text = cD.legs and (cD.legs.."\n\n") or ""},
					{text = "Tail fully dry:\n", bold = true, color = c.secondary},
					{text = cD.tail.."\n\n"},
					{text = "Ears fully dry:\n", bold = true, color = c.secondary},
					{text = cD.ears.."\n\n"},
					{text = "Hint: Holding a dry sponge will increase drying rate by x10!", color = "gray"}
				}
			))
			:item(itemCheck((timers.tail ~= 0 or timers.ears ~= 0) and "wet_sponge" or "sponge"))
		
		t.legsAct
			:title(toJson(
				{
					"",
					{text = "Set Legs Threshold\n\n", bold = true, color = c.primary},
					{text = "Scroll to adjust the threshold for when the legs should form.\n\n", color = c.secondary},
					{text = "Legs threshold:\n", bold = true, color = c.secondary},
					{text = math.round(legsForm * 100).."% Wet"}
				}
			))
		
		t.gradualAct
			:title(toJson(
				{
					"",
					{text = "Toggle Gradual Dry\n\n", bold = true, color = c.primary},
					{text = "Toggles the scaling of your tail to be gradual rather than instantly changing size.", color = c.secondary}
				}
			))
			:toggled(gradual)
		
		t.soundAct
			:title(toJson(
				{
					"",
					{text = "Toggle Flop Sound\n\n", bold = true, color = c.primary},
					{text = "Toggles flopping sound effects when landing on the ground.\nIf tail can dry, volume will gradually decrease over time until dry.", color = c.secondary}
				}
			))
		
		for _, act in pairs(t) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end

-- Return tail data and actions
return tailData, t
-- Required scripts
require("lib.GSAnimBlend")
local parts   = require("lib.PartsAPI")
local lerp    = require("lib.LerpAPI")
local ground  = require("lib.GroundCheck")
local tail    = require("scripts.Tail")
local pose    = require("scripts.Posing")
local effects = require("scripts.SyncedVariables")

-- Animations setup
local anims = animations.Merling

-- Config setup
config:name("Merling")
local isShark   = config:load("AnimShark") or false
local isCrawl   = config:load("AnimCrawl") or false
local mountDir  = config:load("AnimMountDir") or false
local mountFlip = config:load("AnimMountFlip") or false

-- Table setup
v = {}

-- Animation variables
v.time     = 0
v.strength = 1

v.pitch = 0
v.yaw   = 0
v.roll  = 0
v.headY = 0

v.shark = isShark and 1 or 0

v.scale = math.map(math.max(tail.scale, tail.legs), 0, 1, 1, 0)

-- Variables
local waterTimer = 0
local canTwirl = false
local isSing   = false

-- Lerps
local time     = lerp:new(1)
local strength = lerp:new(1)

local pitch = lerp:new(0.1)
local yaw   = lerp:new(1)
local roll  = lerp:new(0.1)

local shark = lerp:new(0.25, isShark and 1 or 0)
local mountFlipLerp = lerp:new(0.2, mountFlip and 1 or 0)

-- Spawns notes around a model part
local function notes(part, blocks)
	
	local pos   = part:partToWorldMatrix():apply()
	local range = blocks * 16
	particles["note"]
		:pos(pos + vec(math.random(-range, range)/16, math.random(-range, range)/16, math.random(-range, range)/16))
		:setColor(math.random(51,200)/150, math.random(51,200)/150, math.random(51,200)/150)
		:spawn()
	
end

-- Set staticYaw to Yaw on init
local staticYaw = 0
function events.ENTITY_INIT()
	
	staticYaw = player:getBodyYaw()
	
end

function events.TICK()
	
	-- Player variables
	local vel      = player:getVelocity()
	local dir      = player:getLookDir()
	local bodyYaw  = player:getBodyYaw()
	local onGround = ground()
	
	-- Timer settings
	if player:isInWater() or player:isInLava() then
		waterTimer = 20
	else
		waterTimer = math.max(waterTimer - 1, 0)
	end
	
	-- Animation variables
	local largeTail  = tail.large >= tail.swap
	local smallTail  = tail.small >= tail.swap or tail.large <= tail.swap
	local groundAnim = (onGround or waterTimer == 0) and not (pose.climb or pose.swim or pose.crawl or pose.spin) and not pose.elytra and not pose.sleep and not player:getVehicle() and not effects.cF
	
	-- Directional velocity
	local fbVel = player:getVelocity():dot((dir.x_z):normalize())
	local lrVel = player:getVelocity():cross(dir.x_z:normalize()).y
	local udVel = player:getVelocity().y
	local diagCancel = math.abs(lrVel) - math.abs(fbVel)
	
	-- Static yaw
	staticYaw = math.clamp(staticYaw, bodyYaw - 45, bodyYaw + 45)
	staticYaw = math.lerp(staticYaw, bodyYaw, onGround and math.clamp(vel:length(), 0, 1) or 0.25)
	local yawDif = staticYaw - bodyYaw
	
	-- Animation control
	if player:getVehicle() then
		
		-- In vehicle
		time.target = time.target + 0.0005
		strength.target = 1
		
	elseif (onGround or waterTimer == 0) and largeTail and not effects.cF then
		
		-- Above water or on ground
		time.target = time.target + math.clamp(fbVel < -0.05 and math.min(fbVel, math.abs(lrVel)) * 0.005 - 0.0005 or math.max(fbVel, math.abs(lrVel)) * 0.005 + 0.0005, -0.0045, 0.0045)
		strength.target = math.clamp(vel.xz:length() * 2 + 1, 1, 2)
		
	else
		
		-- Assumed floating in water
		time.target = time.target + math.clamp(vel:length() * 0.005 + 0.0005, -0.0045, 0.0045)
		strength.target = math.clamp(vel:length() * 2 + 1, 1, 2)
		
	end
	
	-- Axis controls
	-- X axis control
	if pose.elytra then
		
		-- When using elytra
		pitch.target = math.clamp(-udVel * 20 * (-math.abs(player:getLookDir().y) + 1), -20, 20)
		
	elseif pose.climb or not largeTail or pose.spin then
		
		-- Assumed climbing
		pitch.target = 0
		
	elseif (pose.swim or waterTimer == 0) and not effects.cF then
		
		-- While "swimming" or outside of water
		pitch.target = math.clamp(-udVel * 40 * -(math.abs(player:getLookDir().y * 2) - 1), -20, 20)
		
	else
		
		-- Assumed floating in water
		pitch.target = math.clamp((fbVel + math.max(-udVel, 0) + (math.abs(lrVel) * diagCancel) * 4) * 80, -20, 20)
		
	end
	
	-- Y axis control
	yaw.target = yawDif
	
	-- Z Axis control
	if effects.dG then
		
		-- Dolphin's grace applied
		roll.target = 0
		
	elseif pose.elytra then
		
		-- When using an elytra
		roll.target = math.clamp((-lrVel * 20) - (yawDif * math.clamp(fbVel, -1, 1)), -20, 20)
		
	else
		
		-- Assumed floating in water
		roll.target = math.clamp((-lrVel * diagCancel * 80) - (yawDif * math.clamp(fbVel, -1, 1)), -20, 20)
		
	end
	
	-- Shark control
	shark.target = isShark and 1 or 0
	
	-- Mount rot target
	mountFlipLerp.target = mountFlip and 1 or -1
	
	-- Animation states
	local swim      = largeTail and ((not onGround and waterTimer ~= 0) or (pose.climb or pose.swim or pose.crawl or pose.elytra or player:getVehicle()) or effects.cF) and not pose.sleep
	local stand     = largeTail and not isCrawl and groundAnim
	local crawl     = largeTail and     isCrawl and groundAnim
	local small     = smallTail and not largeTail
	local mountUp   = largeTail and player:getVehicle() and mountDir
	local mountDown = largeTail and player:getVehicle() and not mountDir
	local sleep     = pose.sleep
	local ears      = player:isUnderwater()
	local sing      = isSing and not pose.sleep
	
	-- Animations
	anims.swim:playing(swim)
	anims.stand:playing(stand)
	anims.crawl:playing(crawl)
	anims.small:playing(small)
	anims.mountUp:playing(mountUp)
	anims.mountDown:playing(mountDown)
	anims.sleep:playing(sleep)
	anims.ears:playing(ears)
	anims.sing:playing(sing)
	
	-- Spawns notes around head while singing
	if isSing and world.getTime() % 5 == 0 then
		notes(parts.group.Head, 1)
	end
	
	-- Determins when to stop twirl animaton
	canTwirl = largeTail and not onGround and (waterTimer ~= 0 or effects.cF) and not pose.sleep
	if not canTwirl then
		anims.twirl:stop()
	end
	
end

function events.RENDER(delta, context)
	
	-- Store animation variables
	v.time     = time.currPos
	v.strength = strength.currPos
	
	v.pitch = pitch.currPos
	v.yaw   = yaw.currPos
	v.roll  = roll.currPos
	v.headY = (vanilla_model.HEAD:getOriginRot().y + 180) % 360 - 180
	
	v.shark = shark.currPos
	
	v.scale = math.map(math.max(tail.scale, tail.legs), 0, 1, 1, 0)
	
	-- Animation blending
	anims.mountUp:blend(mountFlipLerp.currPos)
	anims.mountDown:blend(mountFlipLerp.currPos)
	
end

-- GS Blending Setup
local blendAnims = {
	{ anim = anims.swim,      ticks = {7,7} },
	{ anim = anims.stand,     ticks = {7,7} },
	{ anim = anims.crawl,     ticks = {7,7} },
	{ anim = anims.small,     ticks = {7,7} },
	{ anim = anims.mountUp,   ticks = {7,7} },
	{ anim = anims.mountDown, ticks = {7,7} },
	{ anim = anims.sleep,     ticks = {7,7} },
	{ anim = anims.ears,      ticks = {7,7} },
	{ anim = anims.sing,      ticks = {3,3} }
}

-- Apply GS Blending
for _, blend in ipairs(blendAnims) do
	blend.anim:blendTime(table.unpack(blend.ticks)):onBlend("easeOutQuad")
end

-- Fixing spyglass jank
function events.RENDER(delta, context)
	
	local rot = vanilla_model.HEAD:getOriginRot()
	rot.x = math.clamp(rot.x, -90, 30)
	parts.group.Spyglass:offsetRot(rot)
		:pos(pose.crouch and vec(0, -4, 0) or nil)
	
end

-- Shark anim toggle
function pings.setAnimShark(boolean)
	
	isShark = boolean
	config:save("AnimShark", isShark)
	
end

-- Crawl anim toggle
function pings.setAnimCrawl(boolean)
	
	isCrawl = boolean
	config:save("AnimCrawl", isCrawl)
	
end

-- Mount direction anim toggle
function pings.setAnimMountDir()
	
	mountDir = not mountDir
	config:save("AnimMountDir", mountDir)
	
end

-- Set mount rotation
function pings.setAnimMountFlip()
	
	mountFlip = not mountFlip
	config:save("AnimMountFlip", mountFlip)
	
end

-- Play twirl anim
function pings.animPlayTwirl()
	
	if canTwirl then
		anims.twirl:play()
	end
	
end

-- Singing anim toggle
function pings.setAnimSing(boolean)
	
	isSing = boolean
	
end

-- Sync variables
function pings.syncAnims(a, b, c, d, e)
	
	isShark   = a
	isCrawl   = b
	mountDir  = c
	mountFlip = d
	isSing    = e
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local s, color = pcall(require, "scripts.ColorProperties")
if not s then color = {} end

-- Twirl keybind
local twirlBind   = config:load("AnimTwirlKeybind") or "key.keyboard.keypad.6"
local setTwirlKey = keybinds:newKeybind("Twirl Animation"):onPress(pings.animPlayTwirl):key(twirlBind)

-- Sing keybind
local singBind   = config:load("AnimSingKeybind") or "key.keyboard.keypad.7"
local setSingKey = keybinds:newKeybind("Singing Animation"):onPress(function() pings.setAnimSing(not isSing) end):key(singBind)

-- Keybind updaters
function events.TICK()
	
	local twirlKey = setTwirlKey:getKey()
	local singKey  = setSingKey:getKey()
	if twirlKey ~= twirlBind then
		twirlBind = twirlKey
		config:save("AnimTwirlKeybind", twirlKey)
	end
	if singKey ~= singBind then
		singBind = singKey
		config:save("AnimSingKeybind", singKey)
	end
	
end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncAnims(isShark, isCrawl, mountDir, mountFlip, isSing)
	end
	
end

-- Table setup
local t = {}

-- Actions
t.sharkAct = action_wheel:newAction()
	:item(itemCheck("dolphin_spawn_egg"))
	:toggleItem(itemCheck("guardian_spawn_egg"))
	:onToggle(pings.setAnimShark)
	:toggled(isShark)

t.crawlAct = action_wheel:newAction()
	:item(itemCheck("armor_stand"))
	:toggleItem(itemCheck("oak_boat"))
	:onToggle(pings.setAnimCrawl)
	:toggled(isCrawl)

t.mountAct = action_wheel:newAction()
	:item(itemCheck("saddle"))
	:onLeftClick(pings.setAnimMountDir)
	:onRightClick(pings.setAnimMountFlip)

t.twirlAct = action_wheel:newAction()
	:item(itemCheck("cod"))
	:onLeftClick(pings.animPlayTwirl)

t.singAct = action_wheel:newAction()
	:item(itemCheck("music_disc_blocks"))
	:toggleItem(itemCheck("music_disc_cat"))
	:onToggle(pings.setAnimSing)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		t.sharkAct
			:title(toJson
				{"",
				{text = "Toggle Shark Animations\n\n", bold = true, color = color.primary},
				{text = "Toggles the movement of the tail to be more shark based.", color = color.secondary}}
			)
		
		t.crawlAct
			:title(toJson
				{"",
				{text = "Toggle Crawl Animation\n\n", bold = true, color = color.primary},
				{text = "Toggles crawling over standing when you are touching the ground.", color = color.secondary}}
			)
		
		t.mountAct
			:title(toJson
				{"",
				{text = "Set Mount Positioning\n\n", bold = true, color = color.primary},
				{text = "Left and Right click to set the orientation of your tail while mounted/sitting.\n\n", color = color.secondary},
				{text = "Current direction: ", bold = true, color = color.secondary},
				{text = mountDir and "Up" or "Down"},
				{text = " & "},
				{text = mountFlip and "Front" or "Back"}}
			)
		
		t.twirlAct
			:title(toJson
				{text = "Play Twirl animation", bold = true, color = color.primary}
			)
		
		t.singAct
			:title(toJson
				{text = "Play Singing animation", bold = true, color = color.primary}
			)
			:toggled(isSing)
		
		for _, page in pairs(t) do
			page:hoverColor(color.hover):toggleColor(color.active)
		end
		
	end
	
end

-- Returns animation variables & actions
return t
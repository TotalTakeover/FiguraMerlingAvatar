-- Required scripts
require("lib.GSAnimBlend")
local merlingParts = require("lib.GroupIndex")(models.models.Merling)
local ground       = require("lib.GroundCheck")
local average      = require("lib.Average")
local itemCheck    = require("lib.ItemCheck")
local waterTicks   = require("scripts.WaterTicks")
local pose         = require("scripts.Posing")
local effects      = require("scripts.SyncedVariables")
local color        = require("scripts.ColorProperties")

-- Animations setup
local anims = animations["models.Merling"]

-- Config setup
config:name("Merling")
local isShark = config:load("TailShark") or false
local isCrawl = config:load("TailCrawl") or false
local mountDir = config:load("AnimMountDir") or false
local mountRot = config:load("AnimMountRot") or 1

-- Table setup
local a = {}

-- Animation variables
a.time     = 0
a.strength = 1

-- Axis variables
a.pitch    = 0
a.yaw      = 0
a.roll     = 0
a.headY    = 0

-- Animation types
a.normal = isShark and 0 or 1
a.shark  = isShark and 1 or 0

local canTwirl = false
local isSing   = false

local time = {
	prev = 0,
	next = 0
}

local strength = {
	prev = 1,
	next = 1
}

local pitch = {
	current  = 0,
	nextTick = 0,
	target   = 0
}

local yaw = {
	current  = 0,
	nextTick = 0,
	target   = 0
}

local roll = {
	current  = 0,
	nextTick = 0,
	target   = 0
}

local shark = {
	current  = 0,
	nextTick = 0,
	target   = 0
}

local mountRotLerp = {
	current    = mountRot,
	nextTick   = mountRot,
	target     = mountRot,
	currentPos = mountRot
}

-- Set lerp start on init
function events.ENTITY_INIT()
	
	local apply = isShark and 1 or 0
	for k, v in pairs(shark) do
		shark[k] = apply
	end
	
end

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
	
	-- Animation variables
	local largeTail  = average(merlingParts.Tail1:getScale():unpack()) >= 0.75
	local groundAnim = (onGround or waterTicks.water >= 20) and not (pose.climb or pose.swim or pose.crawl) and not pose.elytra and not pose.sleep and not player:getVehicle() and not effects.cF
	
	-- Directional velocity
	local fbVel = player:getVelocity():dot((dir.x_z):normalize())
	local lrVel = player:getVelocity():cross(dir.x_z:normalize()).y
	local udVel = player:getVelocity().y
	local diagCancel = math.abs(lrVel) - math.abs(fbVel)
	
	-- Static yaw
	staticYaw = math.clamp(staticYaw, bodyYaw - 45, bodyYaw + 45)
	staticYaw = math.lerp(staticYaw, bodyYaw, onGround and math.clamp(vel:length(), 0, 1) or 0.25)
	local yawDif = staticYaw - bodyYaw
	
	-- Store animation variables
	time.prev     = time.next
	strength.prev = strength.next
	
	-- Animation control
	if player:getVehicle() then
		
		-- In vehicle
		time.next = time.next + 0.0005
		strength.next = 1
		
	elseif (waterTicks.water >= 20 or onGround) and largeTail and not effects.cF then
		
		-- Above water or on ground
		time.next = time.next + math.clamp(fbVel < -0.05 and math.min(fbVel, math.abs(lrVel)) * 0.005 - 0.0005 or math.max(fbVel, math.abs(lrVel)) * 0.005 + 0.0005, -0.0045, 0.0045)
		strength.next = math.clamp(vel.xz:length() * 2 + 1, 1, 2)
		
	else
		
		-- Assumed floating in water
		time.next = time.next + math.clamp(vel:length() * 0.005 + 0.0005, -0.0045, 0.0045)
		strength.next = math.clamp(vel:length() * 2 + 1, 1, 2)
		
	end
	
	-- Axis controls
	-- X axis control
	if pose.elytra then
		
		-- When using elytra
		pitch.target = math.clamp(-udVel * 20 * (-math.abs(player:getLookDir().y) + 1), -20, 20)
		
	elseif pose.climb or not largeTail then
		
		-- Assumed climbing
		pitch.target = 0
		
	elseif (pose.swim or waterTicks.water >= 20) and not effects.cF then
		
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
		
		-- Dolphins grace applied
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
	
	-- Tick lerps
	shark.current  = shark.nextTick
	shark.nextTick = math.lerp(shark.nextTick, shark.target, 0.25)
	
	pitch.current = pitch.nextTick
	yaw.current   = yaw.nextTick
	roll.current  = roll.nextTick
	
	pitch.nextTick = math.lerp(pitch.nextTick, pitch.target, 0.1)
	yaw.nextTick   = math.lerp(yaw.nextTick,   yaw.target,   1)
	roll.nextTick  = math.lerp(roll.nextTick,  roll.target,  0.1)
	
	-- Mount rot target
	mountRotLerp.target = mountRot
	
	-- Tick lerp
	mountRotLerp.current  = mountRotLerp.nextTick
	mountRotLerp.nextTick = math.lerp(mountRotLerp.nextTick, mountRotLerp.target, 0.2)
	
	-- Animation states
	local swim      = largeTail and ((not onGround and waterTicks.water < 20) or (pose.climb or pose.swim or pose.crawl or pose.elytra or player:getVehicle()) or effects.cF) and not pose.sleep
	local stand     = largeTail and not isCrawl and groundAnim
	local crawl     = largeTail and     isCrawl and groundAnim
	local small     = not largeTail
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
		notes(merlingParts.Head, 1)
	end
	
	-- Determins when to stop twirl animaton
	canTwirl = largeTail and not onGround and waterTicks.water < 20 and not pose.sleep
	if not canTwirl then
		anims.twirl:stop()
	end
	
end

function events.RENDER(delta, context)
	
	-- Render lerps
	a.time     = math.lerp(time.prev, time.next, delta)
	a.strength = math.lerp(strength.prev, strength.next, delta)
	
	a.pitch = math.lerp(pitch.current, pitch.nextTick, delta)
	a.yaw   = math.lerp(yaw.current, yaw.nextTick, delta)
	a.roll  = math.lerp(roll.current, roll.nextTick, delta)
	
	a.shark  = math.lerp(shark.current, shark.nextTick, delta)
	a.normal = math.map(a.shark, 0, 1, 1 ,0)
	
	mountRotLerp.currentPos = math.lerp(mountRotLerp.current, mountRotLerp.nextTick, delta)
	
	-- Head Y rot calc (for sleep offset)
	a.headY = (vanilla_model.HEAD:getOriginRot().y + 180) % 360 - 180
	
	-- Animation blending
	anims.mountUp:blend(mountRotLerp.currentPos)
	anims.mountDown:blend(mountRotLerp.currentPos)
	
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
	
for _, blend in ipairs(blendAnims) do
	blend.anim:blendTime(table.unpack(blend.ticks)):onBlend("easeOutQuad")
end

-- Fixing spyglass jank
function events.RENDER(delta, context)
	
	local rot = vanilla_model.HEAD:getOriginRot()
	rot.x = math.clamp(rot.x, -90, 30)
	merlingParts.Spyglass:rot(rot)
		:pos(pose.crouch and vec(0, -4, 0) or nil)
	
end

-- Shark anim toggle
function pings.setAnimShark(boolean)
	
	isShark = boolean
	config:save("TailShark", isShark)
	
end

-- Crawl anim toggle
function pings.setAnimCrawl(boolean)
	
	isCrawl = boolean
	config:save("TailCrawl", isCrawl)
	
end

-- Mount direction anim toggle
function pings.setAnimMountDir()
	
	mountDir = not mountDir
	config:save("AnimMountDir", mountDir)
	
end

-- Set mount rotation
local function setMountRot(x)
	
	mountRot = math.clamp(mountRot + x * (5/90), -1, 1)
	config:save("AnimMountRot", mountRot)
	
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
	
	isShark  = a
	isCrawl  = b
	mountDir = c
	mountRot = d
	isSing   = e
	
end

-- Host only instructions
if not host:isHost() then return a end

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
		pings.syncAnims(isShark, isCrawl, mountDir, mountRot, isSing)
	end
	
end

-- Table setup
local t = {}

-- Action wheel pages
t.sharkPage = action_wheel:newAction()
	:item(itemCheck("dolphin_spawn_egg"))
	:toggleItem(itemCheck("guardian_spawn_egg"))
	:onToggle(pings.setAnimShark)
	:toggled(isShark)

t.crawlPage = action_wheel:newAction()
	:item(itemCheck("armor_stand"))
	:toggleItem(itemCheck("oak_boat"))
	:onToggle(pings.setAnimCrawl)
	:toggled(isCrawl)

t.mountPage = action_wheel:newAction()
	:item(itemCheck("saddle"))
	:onScroll(setMountRot)
	:onLeftClick(pings.setAnimMountDir)
	:onRightClick(function() mountRot = 1 config:save("AnimMountRot", mountRot) end)

t.twirlPage = action_wheel:newAction()
	:item(itemCheck("cod"))
	:onLeftClick(pings.animPlayTwirl)

t.singPage = action_wheel:newAction()
	:item(itemCheck("music_disc_blocks"))
	:toggleItem(itemCheck("music_disc_cat"))
	:onToggle(pings.setAnimSing)

-- Update action page info
function events.TICK()
	
	if action_wheel:isEnabled() then
		t.sharkPage
			:title(toJson
				{"",
				{text = "Toggle Shark Animations\n\n", bold = true, color = color.primary},
				{text = "Toggles the movement of the tail to be more shark based.", color = color.secondary}}
			)
		
		t.crawlPage
			:title(toJson
				{"",
				{text = "Toggle Crawl Animation\n\n", bold = true, color = color.primary},
				{text = "Toggles crawling over standing when you are touching the ground.", color = color.secondary}}
			)
		
		t.mountPage
			:title(toJson
				{"",
				{text = "Set Mount Rotation\n\n", bold = true, color = color.primary},
				{text = "Scroll to set the rotation of your tail while mounted/sitting.\n\n", color = color.secondary},
				{text = "Current direction: ", bold = true, color = color.secondary},
				{text = (mountDir and "Up" or "Down").."\n"},
				{text = "Current rotation: ", bold = true, color = color.secondary},
				{text = math.round(mountRot * 90).."\n\n"},
				{text = "Left click to reset back to default rotation.", color = color.secondary}}
			)
		
		t.twirlPage
			:title(toJson
				{text = "Play Twirl animation", bold = true, color = color.primary}
			)
		
		t.singPage
			:title(toJson
				{text = "Play Singing animation", bold = true, color = color.primary}
			)
			:toggled(isSing)
		
		for _, page in pairs(t) do
			page:hoverColor(color.hover):toggleColor(color.active)
		end
		
	end
	
end

-- Returns animation variables/action wheel pages
return a, t
-- Required scripts
require("lib.GSAnimBlend")
local parts      = require("lib.GroupIndex")(models)
local waterTicks = require("scripts.WaterTicks")
local pose       = require("scripts.Posing")
local ground     = require("lib.GroundCheck")
local effects    = require("scripts.SyncedVariables")

-- Animations setup
local anims = animations["models.Merling"]

-- Config setup
config:name("Merling")
local isShark = config:load("TailShark") or false
local isCrawl = config:load("TailCrawl") or false

-- Table setup
local t = {}

-- Animation variables
t.time     = 0
t.strength = 1

-- Axis variables
t.pitch    = 0
t.yaw      = 0
t.roll     = 0
t.headY    = 0

-- Animation types
t.normal = isShark and 0 or 1
t.shark  = isShark and 1 or 0

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

-- Set lerp start on init
function events.ENTITY_INIT()
	
	local apply = isShark and 1 or 0
	for k, v in pairs(shark) do
		shark[k] = apply
	end
	
end

-- Get the average of a vector
local function average(vec)
	
	local sum = 0
	for _, v in ipairs{vec:unpack()} do
		sum = sum + v
	end
	return sum / #vec
	
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
	local largeTail  = average(parts.Tail1:getScale()) >= 0.75
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
	
	-- Animation states
	local swim  = largeTail and ((not onGround and waterTicks.water < 20) or (pose.climb or pose.swim or pose.crawl or pose.elytra) or effects.cF) and not pose.sleep and not player:getVehicle()
	local stand = largeTail and not isCrawl and groundAnim
	local crawl = largeTail and     isCrawl and groundAnim
	local small = not largeTail
	local mount = largeTail and player:getVehicle()
	local sleep = pose.sleep
	local ears  = player:isUnderwater()
	local sing  = isSing and not pose.sleep
	
	-- Animations
	anims.swim:playing(swim)
	anims.stand:playing(stand)
	anims.crawl:playing(crawl)
	anims.small:playing(small)
	anims.mount:playing(mount)
	anims.sleep:playing(sleep)
	anims.ears:playing(ears)
	anims.sing:playing(sing)
	
	-- Spawns notes around head while singing
	if isSing and world.getTime() % 5 == 0 then
		notes(parts.Head, 1)
	end
	
	-- Determins when to stop twirl animaton
	canTwirl = largeTail and not onGround and waterTicks.water < 20 and not pose.sleep
	if not canTwirl then
		anims.twirl:stop()
	end
	
end

function events.RENDER(delta, context)
	
	-- Render lerps
	t.time     = math.lerp(time.prev, time.next, delta)
	t.strength = math.lerp(strength.prev, strength.next, delta)
	
	t.pitch = math.lerp(pitch.current, pitch.nextTick, delta)
	t.yaw   = math.lerp(yaw.current, yaw.nextTick, delta)
	t.roll  = math.lerp(roll.current, roll.nextTick, delta)
	
	t.shark  = math.lerp(shark.current, shark.nextTick, delta)
	t.normal = math.map(t.shark, 0, 1, 1 ,0)
	
	-- Head Y rot calc (for sleep offset)
	t.headY = (vanilla_model.HEAD:getOriginRot().y + 180) % 360 - 180
	
end

-- GS Blending Setup
local blendAnims = {
	{ anim = anims.swim,  ticks = 7 },
	{ anim = anims.stand, ticks = 7 },
	{ anim = anims.crawl, ticks = 7 },
	{ anim = anims.small, ticks = 7 },
	{ anim = anims.mount, ticks = 7 },
	{ anim = anims.sleep, ticks = 7 },
	{ anim = anims.ears,  ticks = 7 },
	{ anim = anims.sing,  ticks = 3 }
}
	
for _, blend in ipairs(blendAnims) do
	blend.anim:blendTime(blend.ticks):onBlend("easeOutQuad")
end

-- Fixing spyglass jank
function events.RENDER(delta, context)
	
	local rot = vanilla_model.HEAD:getOriginRot()
	rot.x = math.clamp(rot.x, -90, 30)
	parts.Spyglass:rot(rot)
		:pos(pose.crouch and vec(0, -4, 0) or nil)
	
end

-- Shark anim toggle
local function setShark(boolean)
	
	isShark = boolean
	config:save("TailShark", isShark)
	
end

-- Crawl anim toggle
local function setCrawl(boolean)
	
	isCrawl = boolean
	config:save("TailCrawl", isCrawl)
	
end

-- Play twirl anim
local function playTwirl()
	
	if canTwirl then
		anims.twirl:play()
	end
	
end

-- Singing anim toggle
local function setSing(boolean)
	
	isSing = boolean
	
end

-- Sync variables
local function syncAnims(a, b, c)
	
	isShark = a
	isCrawl = b
	isSing  = c
	
end

-- Pings setup
pings.setTailShark  = setShark
pings.setTailCrawl  = setCrawl
pings.animPlayTwirl = playTwirl
pings.setAnimSing   = setSing
pings.syncAnims     = syncAnims

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
if host:isHost() then
	function events.TICK()
		
		if world.getTime() % 200 == 0 then
			pings.syncAnims(isShark, isCrawl, isSing)
		end
		
	end
end

-- Activate actions
setShark(isShark)
setCrawl(isCrawl)

-- Action wheel pages
t.sharkPage = action_wheel:newAction("TailShark")
	:title("§9§lToggle Shark Animations\n\n§bToggles the movement of the tail to be more shark based.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("dolphin_spawn_egg")
	:toggleItem("guardian_spawn_egg")
	:onToggle(pings.setTailShark)
	:toggled(isShark)

t.crawlPage = action_wheel:newAction("TailCrawl")
	:title("§9§lToggle Crawl Animation\n\n§bToggles crawling over standing when you are touching the ground.\n\n§5§lNote: §5Heavily recommend using a crawling mod instead.\nThey are much cooler, and will play nicely :D")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("armor_stand")
	:toggleItem("oak_boat")
	:onToggle(pings.setTailCrawl)
	:toggled(isCrawl)

t.twirlPage = action_wheel:newAction("AnimTwirl")
	:title("§9§lPlay Twirl animation")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:item("cod")
	:onLeftClick(pings.animPlayTwirl)

t.singPage = action_wheel:newAction("AnimSing")
	:title("§9§lPlay Singing animation")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("music_disc_blocks")
	:toggleItem("music_disc_cat")
	:onToggle(pings.setAnimSing)

-- Updates action page info
function events.TICK()
	
	t.singPage:toggled(isSing)
	
end

-- Returns animation variables/action wheel pages
return t
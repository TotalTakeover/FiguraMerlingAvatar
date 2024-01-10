-- Required scripts
require("lib.GSAnimBlend")
local model      = require("scripts.ModelParts")
local waterTicks = require("scripts.WaterTicks")
local pose       = require("scripts.Posing")
local ground     = require("lib.GroundCheck")
local effects    = require("scripts.SyncedVariables")

-- Animations setup
local anims = animations.Merling

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
	prev    = 0,
	current = 0
}

local strength = {
	prev    = 1,
	current = 1
}

local pitch = {
	current    = 0,
	nextTick   = 0,
	target     = 0
}

local yaw = {
	current    = 0,
	nextTick   = 0,
	target     = 0
}

local roll = {
	current    = 0,
	nextTick   = 0,
	target     = 0
}

local shark = {
	current    = 0,
	nextTick   = 0,
	target     = 0
}

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
	
	-- Variables
	local vel     = player:getVelocity()
	local dir     = player:getLookDir()
	local bodyYaw = player:getBodyYaw()
	
	-- Directional velocity
	local fbVel = player:getVelocity():dot((dir.x_z):normalize())
	local lrVel = player:getVelocity():cross(dir.x_z:normalize()).y
	local udVel = player:getVelocity().y
	local diagCancel = math.abs(lrVel) - math.abs(fbVel)
	
	-- Static yaw
	staticYaw = math.clamp(staticYaw, bodyYaw - 45, bodyYaw + 45)
	staticYaw = math.lerp(staticYaw, bodyYaw, vel:length())
	
	-- Store previous variables
	time.prev     = time.current
	strength.prev = strength.current
	
	-- Animation modifiers
	if player:getVehicle() then
		
		-- In vehicle
		time.current = time.current + 0.1
		strength.current = 1
		
	elseif waterTicks.water >= 20 or ground() then
		
		-- Above water or on ground
		time.current = time.current + math.clamp(fbVel < -0.01 and math.min(fbVel, math.abs(lrVel)) - 0.1 or math.max(fbVel, math.abs(lrVel)) + 0.1, -0.75, 0.75)
		strength.current = math.clamp(vel.xz:length() * 2, 0, 1) + 1
		
	else
		
		-- Assumed floating in water
		time.current = time.current + math.clamp(vel:length(), -0.75, 0.75) + 0.1
		strength.current = math.clamp(vel:length() * 2, 0, 1) + 1
		
	end
	
	-- Axis lerps
	pitch.target = math.clamp(pose.elytra and -udVel * 20 * (-math.abs(player:getLookDir().y) + 1) or (pose.swim or waterTicks.water >= 20) and -udVel * 40 * -(math.abs(player:getLookDir().y * 2) - 1) or fbVel * 80 + (math.abs(lrVel) * diagCancel) * 60, -20, 20)
	
	yaw.target   = (staticYaw - bodyYaw) + t.roll
	
	roll.target  = math.clamp(effects.dG and 0 or pose.elytra and -lrVel * 20 or (-lrVel * diagCancel) * 80, -20, 20)
	
	if isSing and world.getTime() % 5 == 0 then
		notes(model.head, 1)
	end
	
	-- Tick lerps
	shark.current = shark.nextTick
	shark.nextTick = math.lerp(shark.nextTick, shark.target, 0.25)
	
	pitch.current = pitch.nextTick
	yaw.current   = yaw.nextTick
	roll.current  = roll.nextTick
	
	pitch.nextTick = math.lerp(pitch.nextTick, pitch.target, 0.1)
	yaw.nextTick   = math.lerp(yaw.nextTick,   yaw.target,   1)
	roll.nextTick  = math.lerp(roll.nextTick,  roll.target,  0.1)
	
end

function events.RENDER(delta, context)
	
	-- Head Y rot calc (for sleep offset)
	t.headY     = (vanilla_model.HEAD:getOriginRot().y + 180) % 360 - 180
	
	-- Shark anims lerp
	shark.target = isShark and 1 or 0
	t.shark     = math.lerp(shark.current, shark.nextTick, delta)
	t.normal    = math.map(t.shark, 0, 1, 1 ,0)
	
	-- Render lerps
	t.time     = math.lerp(time.prev, time.current, delta)
	t.strength = math.lerp(strength.prev, strength.current, delta)
	
	t.pitch = math.lerp(pitch.current, pitch.nextTick, delta)
	t.yaw   = math.lerp(yaw.current, yaw.nextTick, delta)
	t.roll  = math.lerp(roll.current, roll.nextTick, delta)
	
end

function events.TICK()
	
	-- Animation variables
	local tail       = average(model.tailRoot:getScale()) > 0.5
	local groundAnim = (ground() or waterTicks.water >= 20) and not (pose.swim or pose.crawl) and not pose.elytra and not pose.sleep and not player:getVehicle()
	
	-- Animation states
	local swim     = tail and ((not ground() and waterTicks.water < 20) or (pose.swim or pose.crawl or pose.elytra)) and not pose.sleep and not player:getVehicle()
	local stand    = tail and not isCrawl and groundAnim
	local crawl    = tail and     isCrawl and groundAnim
	local mount    = tail and player:getVehicle()
	local sleep    = pose.sleep
	local ears     = player:isUnderwater()
	local sing     = isSing and not pose.sleep
	
	-- Animations
	anims.swim:playing(swim)
	anims.stand:playing(stand)
	anims.crawl:playing(crawl)
	anims.mount:playing(mount)
	anims.sleep:playing(sleep)
	anims.ears:playing(ears)
	anims.sing:playing(sing)
	
	canTwirl = tail and not ground() and waterTicks.water < 20 and not pose.sleep
	if not canTwirl then
		anims.twirl:stop()
	end
	
end

-- GS Blending Setup
local blendAnims = {
	{ anim = anims.swim,  ticks = 7 },
	{ anim = anims.stand, ticks = 7 },
	{ anim = anims.crawl, ticks = 7 },
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
	model.root.Spyglass:rot(rot)
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
	
	isShark   = a
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
local twirlBind   = config:load("AnimTwirlKeybind") or "key.keyboard.keypad.4"
local setTwirlKey = keybinds:newKeybind("Twirl Animation"):onPress(pings.animPlayTwirl):key(twirlBind)

-- Sing keybind
local singBind   = config:load("AnimSingKeybind") or "key.keyboard.keypad.5"
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
	:item("minecraft:dolphin_spawn_egg")
	:toggleItem("minecraft:guardian_spawn_egg")
	:onToggle(pings.setTailShark)
	:toggled(isShark)

t.crawlPage = action_wheel:newAction("TailCrawl")
	:title("§9§lToggle Crawl Animation\n\n§bToggles crawling over standing when you are touching the ground.\n\n§5§lNote: §5Heavily recommend using a crawling mod instead.\nThey are much cooler, and will play nicely :D")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("minecraft:armor_stand")
	:toggleItem("minecraft:oak_boat")
	:onToggle(pings.setTailCrawl)
	:toggled(isCrawl)

t.twirlPage = action_wheel:newAction("AnimTwirl")
	:title("§9§lPlay Twirl animation")
	:hoverColor(vectors.hexToRGB("55FFFF"))
    :item("minecraft:cod")
    :onLeftClick(pings.animPlayTwirl)

t.singPage = action_wheel:newAction("AnimSing")
	:title("§9§lPlay Singing animation")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("minecraft:music_disc_blocks")
    :toggleItem("minecraft:music_disc_cat")
    :onToggle(pings.setAnimSing)

-- Updates action page info
function events.TICK()
	
	t.singPage:toggled(isSing)
	
end

-- Returns animation variables/action wheel pages
return t
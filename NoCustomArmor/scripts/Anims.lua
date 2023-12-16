-- Model setup
local model     = models.Merling
local modelRoot = model.Player
local anims     = animations.Merling

-- Config setup
config:name("Merling")
local shark   = config:load("TailShark") or false
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
t.normal   = shark and 0 or 1
t.shark    = shark and 1 or 0

-- Variables
local ticks  = require("scripts.WaterTicks")
local pose   = require("scripts.Posing")
local ground = require("lib.GroundCheck")
local time,     _time     = 0, 0
local strength, _strength = 0, 0

local pitchCurrent, pitchNextTick, pitchTarget = 0, 0, 0
local yawCurrent,   yawNextTick,   yawTarget   = 0, 0, 0
local rollCurrent,  rollNextTick,  rollTarget  = 0, 0, 0

local sharkCurrent, sharkNextTick, sharkTarget = t.shark, t.shark, t.shark

local staticYaw = 0
function events.ENTITY_INIT()
	staticYaw = player:getBodyYaw(delta)
end

function events.TICK()
	
	-- Lerps
	sharkCurrent = sharkNextTick
	sharkNextTick = math.lerp(sharkNextTick, sharkTarget, 0.25)
	
	pitchCurrent,  yawCurrent,  rollCurrent  = pitchNextTick, yawNextTick, rollNextTick
	pitchNextTick, yawNextTick, rollNextTick = math.lerp(pitchNextTick, pitchTarget, 0.1), math.lerp(yawNextTick, yawTarget, 0.1), math.lerp(rollNextTick, rollTarget, 0.1)
	
	-- Static yaw modifiers
	local yaw = player:getBodyYaw(delta)
	if yaw + 20 < staticYaw then
		staticYaw = yaw + 20
	elseif yaw - 20 > staticYaw then
		staticYaw = yaw - 20
	end
	
	-- Yaw static
	staticYaw = player:getVelocity():length() ~= 0 and math.lerp(staticYaw, yaw, 0.5) or staticYaw
	
	-- Store previous vars
	_time     = time
	_strength = strength
	
	-- Animation timeline + target vars
	local animSpeed = player:getVehicle() and 0 or math.min((ticks.water >= 20 and player:getVelocity().xz:length() or player:getVelocity():length()), 0.75)
	time     = time + 0.1 + animSpeed
	strength = (ticks.water >= 20 and math.clamp(player:getVelocity().xz:length() * 2, 0, 1) or math.clamp(player:getVelocity():length() * 2, 0, 2)) + 1
	
end

function events.RENDER(delta, context)
	
	-- Velocity variables
	local fbVel      = player:getVelocity():dot((player:getLookDir().x_z):normalize())
	local lrVel      = player:getVelocity():cross(player:getLookDir().x_z:normalize()).y
	local udVel      = player:getVelocity().y
	local diagCancel = math.abs(lrVel) - math.abs(fbVel)
	
	-- Animation timeline deltas
	t.time      = math.lerp(_time,     time,     delta)
	t.strength  = math.lerp(_strength, strength, delta)
	
	-- Axis lerps
	pitchTarget = math.clamp(pose.elytra and -udVel * 20 * (-math.abs(player:getLookDir().y) + 1) or (pose.swim or ticks.water >= 20) and -udVel * 40 * -(math.abs(player:getLookDir().y * 2) - 1) or fbVel * 80 + (math.abs(lrVel) * diagCancel) * 60, -20, 20)
	t.pitch     = math.lerp(pitchCurrent, pitchNextTick, delta)
	
	yawTarget   = math.clamp((staticYaw - player:getBodyYaw(delta)) + t.roll, -20, 20)
	t.yaw       = math.lerp(yawCurrent, yawNextTick, delta)
	
	rollTarget  = math.clamp(require("scripts.SyncedVariables").dG and 0 or pose.elytra and -lrVel * 20 or (-lrVel * diagCancel) * 80, -20, 20)
	t.roll      = math.lerp(rollCurrent, rollNextTick, delta)
	
	-- Head Y rot calc (for sleep offset)
	t.headY     = (vanilla_model.HEAD:getOriginRot().y + 180) % 360 - 180
	
	-- Shark anims lerp
	sharkTarget = shark and 1 or 0
	t.shark     = math.lerp(sharkCurrent, sharkNextTick, delta)
	t.normal    = math.map(t.shark, 0, 1, 1 ,0)
	
	-- Animation variables
	local tail       = modelRoot.Body.Tail1:getScale().x > 0.5
	local groundAnim = (ground() or ticks.water >= 20) and not (pose.swim or pose.crawl) and not pose.elytra   and not pose.sleep and not player:getVehicle()
	
	-- Animation states
	local swim  = tail and ((not ground() and ticks.water < 20) or (pose.swim or pose.crawl or pose.elytra)) and not pose.sleep and not player:getVehicle()
	local stand = tail and not isCrawl and groundAnim
	local crawl = tail and     isCrawl and groundAnim
	local mount = tail and player:getVehicle()
	local sleep = pose.sleep
	local ears  = player:isUnderwater()
	
	-- Animations
	anims.swim:playing(swim)
	anims.stand:playing(stand)
	anims.crawl:playing(crawl)
	anims.mount:playing(mount)
	anims.sleep:playing(sleep)
	anims.ears:playing(ears)
end

-- Fixing spyglass jank
function events.RENDER(delta, context)
	if context == "RENDER" or context == "FIRST_PERSON" or (not client.isHudEnabled() and context ~= "MINECRAFT_GUI") then
		local rot = vanilla_model.HEAD:getOriginRot()
		rot.x = math.clamp(rot.x, -90, 30)
		modelRoot.Spyglass:rot(rot)
			:pos(pose.crouch and vec(0, -4, 0) or nil)
	end
end

-- GS Blending Setup
do
	require("lib.GSAnimBlend")
	
	local blendAnims = {
		{ anim = anims.swim,  ticks = 7, type = "easeOutQuad" },
		{ anim = anims.stand, ticks = 7, type = "easeOutQuad" },
		{ anim = anims.crawl, ticks = 7, type = "easeOutQuad" },
		{ anim = anims.mount, ticks = 7, type = "easeOutQuad" },
		{ anim = anims.sleep, ticks = 7, type = "easeOutQuad" },
		{ anim = anims.ears,  ticks = 7, type = "easeOutQuad" }
	}
	
	for _, blend in ipairs(blendAnims) do
		blend.anim:blendTime(blend.ticks):onBlend(blend.type)
	end
	
end

-- Shark animation toggle
local function setShark(boolean)
	shark = boolean
	config:save("TailShark", shark)
end

-- Crawl animation toggle
local function setCrawl(boolean)
	isCrawl = boolean
	config:save("TailCrawl", isCrawl)
end

-- Sync variables
local function syncShark(a, b)
	shark   = a
	isCrawl = b
end

-- Pings setup
pings.setTailShark = setShark
pings.setTailCrawl = setCrawl
pings.syncShark    = syncShark

-- Sync on tick
if host:isHost() then
	function events.TICK()
		if world.getTime() % 200 == 0 then
			pings.syncShark(shark, isCrawl)
		end
	end
end

-- Activate actions
setShark(shark)
setCrawl(isCrawl)

-- Action wheel pages
t.sharkPage = action_wheel:newAction("TailShark")
	:title("§9§lToggle Shark Animations\n\n§bToggles the movement of the tail to be more shark based.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("minecraft:dolphin_spawn_egg")
	:toggleItem("minecraft:guardian_spawn_egg")
	:onToggle(pings.setTailShark)
	:toggled(shark)

t.crawlPage = action_wheel:newAction("TailCrawl")
	:title("§9§lToggle Crawl Animation\n\n§bToggles crawling over standing when you are touching the ground.\n\n§5§lNote: §5Heavily recommend using a crawling mod instead.\nThey are much cooler, and will play nicely :D")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("minecraft:armor_stand")
	:toggleItem("minecraft:oak_boat")
	:onToggle(pings.setTailCrawl)
	:toggled(isCrawl)

-- Returns table
return t
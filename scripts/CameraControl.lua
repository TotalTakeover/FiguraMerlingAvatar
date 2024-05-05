-- Required scripts
local merlingParts = require("lib.GroupIndex")(models.models.Merling)
local itemCheck    = require("lib.ItemCheck")
local pose         = require("scripts.Posing")
local color        = require("scripts.ColorProperties")

-- Config setup
config:name("Merling")
local camPos = config:load("CameraPos") or false

-- Variable setup
local head    = merlingParts.Head
local eyePos  = false
local headPos = 0

-- Box check
local function inBox(pos, box_min, box_max)
	return pos.x >= box_min.x and pos.x <= box_max.x and
		   pos.y >= box_min.y and pos.y <= box_max.y and
		   pos.z >= box_min.z and pos.z <= box_max.z
end

local crouchOffset = {
	prev = 0,
	next = 0,
	curr = 0
}

local eyeHeight = {
	prev = 0,
	next = 0,
	curr = 0
}

-- Set starting head pos on init
function events.ENTITY_INIT()
	
	headPos = player:getPos()
	
	local height = toggle and 1 or 0
	for k, v in pairs(eyeHeight) do
		eyeHeight[k] = height
	end
	
end

local wasCrouch = false
function events.TICK()
	
	if player:getPose() == "CROUCHING" and not wasCrouch then
		
		crouchOffset.next = 0.35
		wasCrouch = true
		
	elseif player:getPose() ~= "CROUCHING" and wasCrouch then
		
		crouchOffset.next = -0.35
		wasCrouch = false
		
	else
	
		crouchOffset.prev = crouchOffset.next
		crouchOffset.next = math.lerp(crouchOffset.prev, 0, 0.5)
	
	end
	
	eyeHeight.prev = eyeHeight.next
	eyeHeight.next = math.lerp(eyeHeight.next, player:getEyeHeight(), 0.5)
	
end

function events.POST_RENDER(delta, context)
	if context == "FIRST_PERSON" or context == "RENDER" or (not client.isHudEnabled() and context ~= "MINECRAFT_GUI") then
		
		-- Pos checking
		local basePos = player:getPos(delta)
		headMatrix    = head:partToWorldMatrix():apply()
		
		-- Camera offset
		local posOffset = headMatrix - basePos
		
		if context == "FIRST_PERSON" then
			
			-- Pehkui scaling
			local nbt   = player:getNbt()
			local types = nbt["pehkui:scale_data_types"]
			local playerScale = (
				types and
				types["pehkui:base"] and
				types["pehkui:base"]["scale"] or 1)
			local width = (
				types and
				types["pehkui:width"] and
				types["pehkui:width"]["scale"] or 1)
			local modelWidth = (
				types and
				types["pehkui:model_width"] and
				types["pehkui:model_width"]["scale"] or 1)
			local height = (
				types and
				types["pehkui:height"] and
				types["pehkui:height"]["scale"] or 1)
			local modelHeight = (
				types and
				types["pehkui:model_height"] and
				types["pehkui:model_height"]["scale"] or 1)
			local offsetScale = vec(width * modelWidth, height * modelHeight, width * modelWidth) * playerScale
			
			posOffset = posOffset * offsetScale
			
		end
		
		-- Lerp eye height
		crouchOffset.curr = math.lerp(crouchOffset.prev, crouchOffset.next, delta)
		eyeHeight.curr = math.lerp(eyeHeight.prev, eyeHeight.next, delta)
		
		-- Add eye height and slight offset
		posOffset.y = posOffset.y + 0.2 + crouchOffset.curr - eyeHeight.curr
		
		-- Check for block obstruction
		local obstructed = false
		local cameraPos = headMatrix + vec(0, 0.2, 0) + client:getCameraDir() * 0.1
		local blockPos = cameraPos:copy():floor()
		local block = world.getBlockState(blockPos)
		local boxes = block:getCollisionShape()
		if boxes then
			for i = 1, #boxes do
				local box = boxes[i]
				if inBox(cameraPos, blockPos + box[1], blockPos + box[2]) then
					obstructed = true
					break
				end
			end
		end
		
		-- Renders offset
		local posOffsetApply = not player:riptideSpinning()
		renderer
			:offsetCameraPivot(camPos and posOffsetApply and not obstructed and posOffset or 0)
			:eyeOffset(eyePos and camPos and posOffsetApply and not obstructed and posOffset or 0)
		
		-- Nameplate Placement
		nameplate.ENTITY:pivot(posOffset + vec(0, 0.7 - crouchOffset.curr + eyeHeight.curr, 0))
		
	end
end

-- Camera pos toggle
local function setPos(boolean)
	
	camPos = boolean
	config:save("CameraPos", camPos)
	
end

-- Eye pos toggle
local function setEye(boolean)
	
	eyePos = boolean
	
end

-- Sync variables
local function syncCamera(a, b)
	
	camPos = a
	eyePos = b
	
end

-- Setup pings
pings.setCameraPos = setPos
pings.setCameraEye = setEye
pings.syncCamera   = syncCamera

-- Sync on tick
if host:isHost() then
	function events.TICK()
		
		if world.getTime() % 200 == 0 then
			pings.syncCamera(camPos, eyePos)
		end
		
	end
end

-- Activate actions
setPos(camPos)

-- Table setup
local t = {}

-- Action wheel pages
t.posPage = action_wheel:newAction()
	:item(itemCheck("skeleton_skull"))
	:toggleItem(itemCheck("player_head{'SkullOwner':'"..avatar:getEntityName().."'}"))
	:onToggle(pings.setCameraPos)
	:toggled(camPos)

t.eyePage = action_wheel:newAction()
	:item(itemCheck("ender_pearl"))
	:toggleItem(itemCheck("ender_eye"))
	:onToggle(pings.setCameraEye)

-- Update action page info
function events.TICK()
	
	t.posPage
		:title(toJson
			{"",
			{text = "Camera Position Toggle\n\n", bold = true, color = color.primary},
			{text = "Sets the camera position to where your avatar's head is.\n\n", color = color.secondary},
			{text = "To prevent x-ray, the camera will reset to its default position if inside a block.", color = "red"}}
		)
		:hoverColor(color.hover)
		:toggleColor(color.active)
	
	t.eyePage
		:title(toJson
			{"",
			{text = "Eye Position Toggle\n\n", bold = true, color = color.primary},
			{text = "Sets the eye position to match the avatar's head.\nRequires camera position toggle.\n\n", color = color.secondary},
			{text = "WARNING: ", bold = true, color = "dark_red"},
			{text = "This feature is dangerous!\nIt can and will be flagged on servers with anticheat!\nFurthermore, \"In Wall\" damage is possible. (The x-ray prevention will try to avoid this)\nThis setting will ", color = "red"},
			{text = "NOT ", bold = true, color = "red"},
			{text = "be saved between sessions for your safety.\n\nPlease use with extreme caution!", color = "red"}}
		)
		:hoverColor(color.hover)
		:toggleColor(color.active)
	
end

-- Return action wheel pages
return t
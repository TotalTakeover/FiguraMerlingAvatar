-- Required scripts
local merlingParts = require("lib.GroupIndex")(models.models.Merling)
local itemCheck    = require("lib.ItemCheck")
local pose         = require("scripts.Posing")
local color        = require("scripts.ColorProperties")

-- Config setup
config:name("Merling")
local camPos = config:load("CameraPos") or false

-- Variable setup
local head = merlingParts.Head

-- Sleep rotations
local dirRot = {
	north = 0,
	east  = 270,
	south = 180,
	west  = 90
}

local function calcMatrix(p)
	return p and p ~= models and (calcMatrix(p:getParent()) * p:getPositionMatrix()) or matrices.mat4()
end

-- Box check
local function inBox(pos, box_min, box_max)
	return pos.x >= box_min.x and pos.x <= box_max.x and
		   pos.y >= box_min.y and pos.y <= box_max.y and
		   pos.z >= box_min.z and pos.z <= box_max.z
end

function events.RENDER(delta, context)
	if context == "FIRST_PERSON" or context == "RENDER" or (not client.isHudEnabled() and context ~= "MINECRAFT_GUI") then
		
		-- Variables
		local yaw = player:getBodyYaw(delta)
		
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
		local modelEyeHeight = (
			types and
			types["pehkui:eye_height"] and
			types["pehkui:eye_height"]["scale"] or 1)
		local offsetScale = vec(width * modelWidth, height * modelHeight, width * modelWidth) * playerScale
		
		-- Camera offset
		local posOffset  = calcMatrix(head):apply(head:getPivot()) / 16
		local nameOffset = posOffset + vec(0, 0.85, 0)
		
		if pose.stand or pose.crouch then
			
			-- If standing, lower camera offset
			posOffset = posOffset - vec(0, 24 * modelEyeHeight, 0) / 16
			
		else
			
			-- else, slightly lower camera offset
			posOffset  = posOffset - vec(0, (pose.sleep and 24 or pose.elytra and 0 or 16), 0) / 16
			nameOffset = posOffset - vec(0, (pose.sleep and 4 or -4) * modelEyeHeight, -20) / 16
			
			-- else, rotate camera offset on x axis
			posOffset  = vectors.rotateAroundAxis(-player:getRot().x - 90, posOffset,  vec(1, 0, 0))
			nameOffset = vectors.rotateAroundAxis(-player:getRot().x - 90, nameOffset, vec(1, 0, 0))
			
		end
		
		-- Rotate camera offset on y axis
		if pose.sleep then
			
			-- Find block
			local block = world.getBlockState(player:getPos())
			local sleepRot = dirRot[block.properties["facing"]]
			
			posOffset  = vectors.rotateAroundAxis(sleepRot, posOffset,  vec(0, 1, 0))
			nameOffset = vectors.rotateAroundAxis(sleepRot, nameOffset, vec(0, 1, 0))
			
		else
			
			posOffset  = vectors.rotateAroundAxis(-yaw + 180, posOffset,  vec(0, 1, 0))
			nameOffset = vectors.rotateAroundAxis(-yaw + 180, nameOffset, vec(0, 1, 0))
			
		end
		
		posOffset = posOffset * offsetScale
		
		-- Check for block obstruction
		local obstructed = false
		local cameraPos = merlingParts.Body:partToWorldMatrix():apply() + vec(0, 0.2, 0) + client:getCameraDir() * 0.1
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
		renderer
			:offsetCameraPivot(camPos and not obstructed and posOffset or 0)
			:eyeOffset(eyePos and camPos and not obstructed and posOffset or 0)
		
		-- Nameplate Placement
		nameplate.ENTITY
			:pivot(nameOffset)
		
	end
	
	head:visible(context ~= "OTHER")
	
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
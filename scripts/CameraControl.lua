-- Required scripts
local merlingParts = require("lib.GroupIndex")(models.models.Merling)
local itemCheck    = require("lib.ItemCheck")
local pose         = require("scripts.Posing")
local color        = require("scripts.ColorProperties")

-- Config setup
config:name("Merling")
local camPos = config:load("CameraPos") or false

-- Variable setup
local eyePos = false

-- Box check
local function inBox(pos, box_min, box_max)
	return pos.x >= box_min.x and pos.x <= box_max.x and
		   pos.y >= box_min.y and pos.y <= box_max.y and
		   pos.z >= box_min.z and pos.z <= box_max.z
end

-- Set starting head pos on init
local headPos = 0
function events.ENTITY_INIT()
	
	headPos = player:getPos()
	
end

function events.RENDER(delta, context)
	if context == "FIRST_PERSON" or context == "RENDER" or (not client.isHudEnabled() and context ~= "MINECRAFT_GUI") then
		
		-- Pos checking
		local basePos = player:getPos(delta)
		headPos       = merlingParts.Head:partToWorldMatrix():apply()
		
		-- Camera offset
		local posOffset = headPos - basePos
		
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
		
		-- Add eye height and slight offset
		posOffset.y = posOffset.y - player:getEyeHeight() + 0.2
		
		-- Check for block obstruction
		local obstructed = false
		local cameraPos = headPos + vec(0, 0.2, 0) + client:getCameraDir() * 0.1
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
		renderer:offsetCameraPivot(camPos and posOffsetApply and not obstructed and posOffset or 0)
			:eyeOffset(eyePos and camPos and posOffsetApply and not obstructed and posOffset or 0)
		
		-- Nameplate Placement
		nameplate.ENTITY:pivot(posOffset + vec(0, player:getBoundingBox().y + 0.5, 0))
		
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
	:title(color.primary.."Camera Position Toggle\n\n"..color.secondary.."Sets the camera position to where your avatar's head is.\n\n§cTo prevent x-ray, the camera will reset to its default position if inside a block.")
	:hoverColor(color.hover)
	:toggleColor(color.active)
	:item(itemCheck("skeleton_skull"))
	:toggleItem(itemCheck("player_head{'SkullOwner':'"..avatar:getEntityName().."'}"))
	:onToggle(pings.setCameraPos)
	:toggled(camPos)
	
t.eyePage = action_wheel:newAction()
	:title(color.primary.."Eye Position Toggle\n\n"..color.secondary.."Sets the eye position to match the avatar's head.\nRequires camera position toggle.\n\n§4§lWARNING: §cThis feature is dangerous!\nIt can and will be flagged on servers with anticheat!\nFurthermore, \"In Wall\" damage is possible. (The x-ray prevention will try to avoid this)\nThis setting will §lNOT §cbe saved between sessions for your safety.\n\nPlease use with extreme caution!")
	:hoverColor(color.hover)
	:toggleColor(color.active)
	:item(itemCheck("ender_pearl"))
	:toggleItem(itemCheck("ender_eye"))
	:onToggle(pings.setCameraEye)

-- Return action wheel pages
return t
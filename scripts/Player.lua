-- Required scripts
local parts     = require("lib.GroupIndex")(models)
local itemCheck = require("lib.ItemCheck")
local color     = require("scripts.ColorProperties")

-- Config setup
config:name("Merling")
local vanillaSkin = config:load("AvatarVanillaSkin")
local slim        = config:load("AvatarSlim") or false
if vanillaSkin == nil then vanillaSkin = true end

-- Set legs, skull, and portrait groups to visible (incase disabled in blockbench)
parts.LeftLeg :visible(true)
parts.RightLeg:visible(true)
parts.Skull   :visible(true)
parts.Portrait:visible(true)

-- All vanilla skin parts
local skin = {
	
	parts.Head.Head,
	parts.Head.Layer,
	
	parts.Body.Body,
	parts.Body.Layer,
	
	parts.leftArmDefault,
	parts.leftArmSlim,
	
	parts.rightArmDefault,
	parts.rightArmSlim,
	
	parts.LeftLeg.Leg,
	parts.LeftLeg.Layer,
	
	parts.RightLeg.Leg,
	parts.RightLeg.Layer,
	
	parts.Portrait.Head,
	parts.Portrait.Layer,
	
	parts.Skull.Head,
	parts.Skull.Layer
	
}

-- All layer parts
local layer = {

	HAT = {
		parts.Head.Layer
	},
	JACKET = {
		parts.Body.Layer
	},
	LEFT_SLEEVE = {
		parts.leftArmDefault.Layer,
		parts.leftArmSlim.Layer
	},
	RIGHT_SLEEVE = {
		parts.rightArmDefault.Layer,
		parts.rightArmSlim.Layer
	},
	LEFT_PANTS_LEG = {
		parts.LeftLeg.Layer
	},
	RIGHT_PANTS_LEG = {
		parts.RightLeg.Layer
	},
	TAIL = {
		parts.Tail1.Layer,
		parts.Tail2.Layer,
		parts.Tail3.Layer,
		parts.Tail4.Layer
	},
	CAPE = {
		parts.Cape
	}
	
}

--[[
	
	Because flat parts in the model are 2 faces directly on top
	of eachother, and have 0 inflate, the two faces will z-fight.
	This prevents z-fighting, as well as z-fighting at a distance,
	as well as translucent stacking.
	
	Please add plane/flat parts with 2 faces to the table below.
	0.01 works, but this works much better :)
	
--]]

-- All plane parts
local planeParts = {
	
	parts.LeftEar.Ear,
	parts.RightEar.Ear,
	
	parts.LeftEarSkull.Ear,
	parts.RightEarSkull.Ear,
	
	parts.Tail2LeftFin.Fin,
	parts.Tail2RightFin.Fin,
	parts.Fluke
	
}

-- Apply
for _, part in ipairs(planeParts) do
	part:primaryRenderType("TRANSLUCENT_CULL")
end

-- Determine vanilla player type on init
local vanillaAvatarType
function events.ENTITY_INIT()
	
	vanillaAvatarType = player:getModelType()
	
end

-- Misc tick required events
function events.TICK()
	
	-- Model shape
	local slimShape = (vanillaSkin and vanillaAvatarType == "SLIM") or (slim and not vanillaSkin)
	
	parts.leftArmDefault:visible(not slimShape)
	parts.rightArmDefault:visible(not slimShape)
	
	parts.leftArmSlim:visible(slimShape)
	parts.rightArmSlim:visible(slimShape)
	
	-- Skin textures
	local skinType = vanillaSkin and "SKIN" or "PRIMARY"
	for _, part in ipairs(skin) do
		part:primaryTexture(skinType)
	end
	
	-- Cape textures
	parts.Cape:primaryTexture(vanillaSkin and "CAPE" or "PRIMARY")
	
	-- Layer toggling
	for layerType, parts in pairs(layer) do
		local enabled = enabled
		if layerType == "TAIL" then
			enabled = player:isSkinLayerVisible("RIGHT_PANTS_LEG") or player:isSkinLayerVisible("LEFT_PANTS_LEG")
		else
			enabled = player:isSkinLayerVisible(layerType)
		end
		for _, part in ipairs(parts) do
			part:visible(enabled)
		end
	end
	
end

-- Vanilla skin toggle
local function setVanillaSkin(boolean)
	
	vanillaSkin = boolean
	config:save("AvatarVanillaSkin", vanillaSkin)
	
end

-- Model type toggle
local function setModelType(boolean)
	
	slim = boolean
	config:save("AvatarSlim", slim)
	
end

-- Sync variables
local function syncPlayer(a, b)
	
	vanillaSkin = a
	slim = b
	
end

-- Pings setup
pings.setAvatarVanillaSkin = setVanillaSkin
pings.setAvatarModelType   = setModelType
pings.syncPlayer           = syncPlayer

-- Sync on tick
if host:isHost() then
	function events.TICK()
		
		if world.getTime() % 200 == 0 then
			pings.syncPlayer(vanillaSkin, slim)
		end
		
	end
end

-- Activate actions
setVanillaSkin(vanillaSkin)
setModelType(slim)

-- Setup table
local t = {}

-- Action wheel pages
t.vanillaSkinPage = action_wheel:newAction()
	:title(color.primary.."Toggle Vanilla Texture\n\n"..color.secondary.."Toggles the usage of your vanilla skin.")
	:hoverColor(color.hover)
	:toggleColor(color.active)
	:item(itemCheck("player_head{'SkullOwner':'"..avatar:getEntityName().."'}"))
	:onToggle(pings.setAvatarVanillaSkin)
	:toggled(vanillaSkin)

t.modelPage = action_wheel:newAction()
	:title(color.primary.."Toggle Model Shape\n\n"..color.secondary.."Adjust the model shape to use Default or Slim Proportions.\nWill be overridden by the vanilla skin toggle.")
	:hoverColor(color.hover)
	:toggleColor(color.active)
	:item(itemCheck("player_head"))
	:toggleItem(itemCheck("player_head{'SkullOwner':'MHF_Alex'}"))
	:onToggle(pings.setAvatarModelType)
	:toggled(slim)

-- Return action wheel pages
return t
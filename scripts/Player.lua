-- Required scripts
local merlingParts = require("lib.GroupIndex")(models.models.Merling)
local itemCheck    = require("lib.ItemCheck")
local color        = require("scripts.ColorProperties")

-- Config setup
config:name("Merling")
local vanillaSkin = config:load("AvatarVanillaSkin")
local slim        = config:load("AvatarSlim") or false
if vanillaSkin == nil then vanillaSkin = true end

-- Set legs, skull, and portrait groups to visible (incase disabled in blockbench)
merlingParts.LeftLeg :visible(true)
merlingParts.RightLeg:visible(true)
merlingParts.Skull   :visible(true)
merlingParts.Portrait:visible(true)

-- All vanilla skin parts
local skin = {
	
	merlingParts.Head.Head,
	merlingParts.Head.Layer,
	
	merlingParts.Body.Body,
	merlingParts.Body.Layer,
	
	merlingParts.leftArmDefault,
	merlingParts.leftArmSlim,
	
	merlingParts.rightArmDefault,
	merlingParts.rightArmSlim,
	
	merlingParts.LeftLeg.Leg,
	merlingParts.LeftLeg.Layer,
	
	merlingParts.RightLeg.Leg,
	merlingParts.RightLeg.Layer,
	
	merlingParts.Portrait.Head,
	merlingParts.Portrait.Layer,
	
	merlingParts.Skull.Head,
	merlingParts.Skull.Layer
	
}

-- All layer parts
local layer = {

	HAT = {
		merlingParts.Head.Layer
	},
	JACKET = {
		merlingParts.Body.Layer
	},
	LEFT_SLEEVE = {
		merlingParts.leftArmDefault.Layer,
		merlingParts.leftArmSlim.Layer
	},
	RIGHT_SLEEVE = {
		merlingParts.rightArmDefault.Layer,
		merlingParts.rightArmSlim.Layer
	},
	LEFT_PANTS_LEG = {
		merlingParts.LeftLeg.Layer
	},
	RIGHT_PANTS_LEG = {
		merlingParts.RightLeg.Layer
	},
	TAIL = {
		merlingParts.Tail1.Layer,
		merlingParts.Tail2.Layer,
		merlingParts.Tail3.Layer,
		merlingParts.Tail4.Layer
	},
	CAPE = {
		merlingParts.Cape
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
	
	merlingParts.LeftEar.Ear,
	merlingParts.RightEar.Ear,
	
	merlingParts.LeftEarSkull.Ear,
	merlingParts.RightEarSkull.Ear,
	
	merlingParts.Tail2LeftFin.Fin,
	merlingParts.Tail2RightFin.Fin,
	merlingParts.Fluke
	
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
	
	merlingParts.leftArmDefault:visible(not slimShape)
	merlingParts.rightArmDefault:visible(not slimShape)
	
	merlingParts.leftArmSlim:visible(slimShape)
	merlingParts.rightArmSlim:visible(slimShape)
	
	-- Skin textures
	local skinType = vanillaSkin and "SKIN" or "PRIMARY"
	for _, part in ipairs(skin) do
		part:primaryTexture(skinType)
	end
	
	-- Cape textures
	merlingParts.Cape:primaryTexture(vanillaSkin and "CAPE" or "PRIMARY")
	
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
	:item(itemCheck("player_head{'SkullOwner':'"..avatar:getEntityName().."'}"))
	:onToggle(pings.setAvatarVanillaSkin)
	:toggled(vanillaSkin)

t.modelPage = action_wheel:newAction()
	:item(itemCheck("player_head"))
	:toggleItem(itemCheck("player_head{'SkullOwner':'MHF_Alex'}"))
	:onToggle(pings.setAvatarModelType)
	:toggled(slim)

-- Update action page info
function events.TICK()
	
	t.vanillaSkinPage
		:title(toJson
			{"",
			{text = "Toggle Vanilla Texture\n\n", bold = true, color = color.primary},
			{text = "Toggles the usage of your vanilla skin.", color = color.secondary}}
		)
		:hoverColor(color.hover)
		:toggleColor(color.active)
	
	t.modelPage
		:title(toJson
			{"",
			{text = "Toggle Model Shape\n\n", bold = true, color = color.primary},
			{text = "Adjust the model shape to use Default or Slim Proportions.\nWill be overridden by the vanilla skin toggle.", color = color.secondary}}
		)
		:hoverColor(color.hover)
		:toggleColor(color.active)
	
end

-- Return action wheel pages
return t
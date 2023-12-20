-- Model setup
local model     = models.Merling
local modelRoot = model.Player

-- Config setup
config:name("Merling")
local vanillaSkin = config:load("AvatarVanillaSkin")
if vanillaSkin == nil then vanillaSkin = true end
local slim = config:load("AvatarSlim") or false

-- Vanilla parts table
local skinParts = {
	modelRoot.Head.Head,
	modelRoot.Head.HatLayer,
	
	modelRoot.Body.Body,
	modelRoot.Body.BodyLayer,
	
	modelRoot.RightArm.DefaultRightArm,
	modelRoot.RightArm.SlimRightArm,
	
	modelRoot.LeftArm.DefaultLeftArm,
	modelRoot.LeftArm.SlimLeftArm,
	
	modelRoot.LeftLeg.Leg,
	modelRoot.LeftLeg.LegLayer,
	
	modelRoot.RightLeg.Leg,
	modelRoot.RightLeg.LegLayer,
	
	model.Portrait.Head,
	model.Portrait.HatLayer,
	
	model.Skull.Head,
	model.Skull.HatLayer,
}

-- Variable setup
local vanillaAvatarType = nil
function events.ENTITY_INIT()
	vanillaAvatarType = player:getModelType()
end

-- Misc tick required events
function events.TICK()
	-- Model shape
	local slimShape = (vanillaSkin and vanillaAvatarType == "SLIM") or (slim and not vanillaSkin)
	
	modelRoot.LeftArm.DefaultLeftArm:setVisible(not slimShape)
	modelRoot.RightArm.DefaultRightArm:setVisible(not slimShape)
	
	modelRoot.LeftArm.SlimLeftArm:setVisible(slimShape)
	modelRoot.RightArm.SlimRightArm:setVisible(slimShape)
	
	-- Skin textures
	for _, part in ipairs(skinParts) do
		part:primaryTexture(vanillaSkin and "SKIN" or nil)
	end
	
	-- Cape/Elytra texture
	modelRoot.Body.Cape:primaryTexture(vanillaSkin and "CAPE" or nil)
	modelRoot.Body.Elytra:primaryTexture(vanillaSkin and player:hasCape() and (player:isSkinLayerVisible("CAPE") and "CAPE" or "ELYTRA") or nil)
		:secondaryRenderType(player:getItem(5):hasGlint() and "GLINT" or "NONE")
end

-- Show/hide skin layers depending on Skin Customization settings
local layerParts = {
	HAT = {
		modelRoot.Head.HatLayer,
	},
	JACKET = {
		modelRoot.Body.BodyLayer,
	},
	RIGHT_SLEEVE = {
		modelRoot.RightArm.DefaultRightArm.ArmLayer,
		modelRoot.RightArm.SlimRightArm.ArmLayer,
	},
	LEFT_SLEEVE = {
		modelRoot.LeftArm.DefaultLeftArm.ArmLayer,
		modelRoot.LeftArm.SlimLeftArm.ArmLayer,
	},
	RIGHT_PANTS_LEG = {
		modelRoot.RightLeg.LegLayer,
	},
	LEFT_PANTS_LEG = {
		modelRoot.LeftLeg.LegLayer,
	},
	CAPE = {
		modelRoot.Body.Cape,
	},
	TAIL = {
		modelRoot.Body.Tail1.Layer,
		modelRoot.Body.Tail1.Tail2.Layer,
		modelRoot.Body.Tail1.Tail2.Tail3.Layer,
		modelRoot.Body.Tail1.Tail2.Tail3.Tail4.Layer,
	},
}
function events.TICK()
	for playerPart, parts in pairs(layerParts) do
		local enabled = enabled
		if playerPart == "TAIL" then
			enabled = player:isSkinLayerVisible("RIGHT_PANTS_LEG") or player:isSkinLayerVisible("LEFT_PANTS_LEG")
		else
			enabled = player:isSkinLayerVisible(playerPart)
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
t.vanillaSkinPage = action_wheel:newAction("VanillaSkin")
	:title("§9§lToggle Vanilla Texture\n\n§bToggles the usage of your vanilla skin.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item('minecraft:player_head{"SkullOwner":"'..avatar:getEntityName()..'"}')
	:onToggle(pings.setAvatarVanillaSkin)
	:toggled(vanillaSkin)

t.modelPage = action_wheel:newAction("ModelShape")
	:title("§9§lToggle Model Shape\n\n§bAdjust the model shape to use Default or Slim Proportions.\nWill be overridden by the vanilla skin toggle.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item('minecraft:player_head')
	:toggleItem('minecraft:player_head{"SkullOwner":"MHF_Alex"}')
	:onToggle(pings.setAvatarModelType)
	:toggled(slim)

-- Return table
return t
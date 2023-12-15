-- Model setup
local model     = models.Merling
local modelRoot = model.Player

-- Setup table
local t = {}

-- Config setup
config:name("Merling")
t.vanillaSkin = config:load("AvatarVanillaSkin")
if t.vanillaSkin == nil then t.vanillaSkin = true end
local slim = config:load("AvatarSlim") or false

-- Vanilla parts table
local skinParts = {
	modelRoot.Head.Head,
	modelRoot.Head.HatLayer,
	
	modelRoot.Body.Body,
	modelRoot.Body.BodyLayer,
	
	modelRoot.RightArm.Default,
	modelRoot.RightArm.Slim,
	
	modelRoot.LeftArm.Default,
	modelRoot.LeftArm.Slim,
	
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
	local slimShape = (t.vanillaSkin and vanillaAvatarType == "SLIM") or (slim and not t.vanillaSkin)
	
	modelRoot.LeftArm.Default:setVisible(not slimShape)
	modelRoot.RightArm.Default:setVisible(not slimShape)
	
	modelRoot.LeftArm.Slim:setVisible(slimShape)
	modelRoot.RightArm.Slim:setVisible(slimShape)
	
	-- Skin textures
	for _, part in ipairs(skinParts) do
		part:primaryTexture(t.vanillaSkin and "SKIN" or nil)
	end
	
	-- Cape/Elytra texture
	modelRoot.Body.Cape:primaryTexture(t.vanillaSkin and "CAPE" or nil)
	modelRoot.Body.Elytra:primaryTexture(t.vanillaSkin and player:hasCape() and (player:isSkinLayerVisible("CAPE") and "CAPE" or "ELYTRA") or nil)
		:secondaryRenderType(player:getItem(5):hasGlint() and "GLINT" or "NONE")
end

-- Show/hide skin layers depending on Skin Customization settings
local layerParts = {
	HAT = {
		modelRoot.Head.HatLayer,
	},
	JACKET = {
		modelRoot.Body.BodyLayer,
		modelRoot.Body.Tail.Layer,
		modelRoot.Body.Tail.Tail.Layer,
		modelRoot.Body.Tail.Tail.Tail.Layer,
		modelRoot.Body.Tail.Tail.Tail.Tail.Layer,
	},
	RIGHT_SLEEVE = {
		modelRoot.RightArm.Default.ArmLayer,
		modelRoot.RightArm.Slim.ArmLayer,
	},
	LEFT_SLEEVE = {
		modelRoot.LeftArm.Default.ArmLayer,
		modelRoot.LeftArm.Slim.ArmLayer,
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
}
function events.TICK()
	for playerPart, parts in pairs(layerParts) do
		local enabled = player:isSkinLayerVisible(playerPart)
		for _, part in ipairs(parts) do
			part:visible(enabled)
		end
	end
end

-- Vanilla skin toggle
local function setVanillaSkin(boolean)
	t.vanillaSkin = boolean
	config:save("AvatarVanillaSkin", t.vanillaSkin)
end

-- Model type toggle
local function setModelType(boolean)
	slim = boolean
	config:save("AvatarSlim", slim)
end

-- Sync variables
local function syncPlayer(a, b)
	t.vanillaSkin = a
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
			pings.syncPlayer(t.vanillaSkin, slim)
		end
	end
end

-- Activate actions
setVanillaSkin(t.vanillaSkin)
setModelType(slim)

-- Action wheel pages
t.vanillaSkinPage = action_wheel:newAction("VanillaSkin")
	:title("§9§lToggle Vanilla Texture\n\n§bToggles the usage of your vanilla skin.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item('minecraft:player_head{"SkullOwner":"'..avatar:getEntityName()..'"}')
	:onToggle(pings.setAvatarVanillaSkin)
	:toggled(t.vanillaSkin)

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
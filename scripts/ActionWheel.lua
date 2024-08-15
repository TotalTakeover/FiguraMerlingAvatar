-- Disables code if not avatar host
if not host:isHost() then return end

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local avatar    = require("scripts.Player")
local armor     = require("scripts.Armor")
local camera    = require("scripts.CameraControl")
local _, tail   = require("scripts.Tail")
local whirlpool = require("scripts.WhirlpoolEffect")
local glow      = require("scripts.GlowingTail")
local eyes      = require("scripts.GlowingEyes")
local _, anims  = require("scripts.Anims")
local squapi    = require("scripts.SquishyAnims")
local color     = require("scripts.ColorProperties")

-- Logs pages for navigation
local navigation = {}

-- Go forward a page
local function descend(page)
	
	navigation[#navigation + 1] = action_wheel:getCurrentPage() 
	action_wheel:setPage(page)
	
end

-- Go back a page
local function ascend()
	
	action_wheel:setPage(table.remove(navigation, #navigation))
	
end

-- Page setups
local pages = {
	
	main      = action_wheel:newPage("Main"),
	avatar    = action_wheel:newPage("Avatar"),
	armor     = action_wheel:newPage("Armor"),
	camera    = action_wheel:newPage("Camera"),
	tail      = action_wheel:newPage("Tail"),
	dry       = action_wheel:newPage("Dry"),
	whirlpool = action_wheel:newPage("Whirlpool"),
	glow      = action_wheel:newPage("Glow"),
	eyes      = action_wheel:newPage("Eyes"),
	anims     = action_wheel:newPage("Anims")
	
}

-- Page actions
local pageActions = {
	
	avatar = action_wheel:newAction()
		:item(itemCheck("armor_stand"))
		:onLeftClick(function() descend(pages.avatar) end),
	
	tail = action_wheel:newAction()
		:item(itemCheck("tropical_fish"))
		:onLeftClick(function() descend(pages.tail) end),
	
	glow = action_wheel:newAction()
		:item(itemCheck("glow_ink_sac"))
		:onLeftClick(function() descend(pages.glow) end),
	
	anims = action_wheel:newAction()
		:item(itemCheck("jukebox"))
		:onLeftClick(function() descend(pages.anims) end),
	
	armor = action_wheel:newAction()
		:item(itemCheck("iron_chestplate"))
		:onLeftClick(function() descend(pages.armor) end),
	
	camera = action_wheel:newAction()
		:item(itemCheck("redstone"))
		:onLeftClick(function() descend(pages.camera) end),
	
	dry = action_wheel:newAction()
		:item(itemCheck("sponge"))
		:onLeftClick(function() descend(pages.dry) end),
	
	whirlpool = action_wheel:newAction()
		:item(itemCheck("magma_block"))
		:onLeftClick(function() descend(pages.whirlpool) end),
	
	eyes = action_wheel:newAction()
		:item(itemCheck("ender_eye"))
		:onLeftClick(function() descend(pages.eyes) end)
	
}

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		pageActions.avatar
			:title(toJson
				{text = "Avatar Settings", bold = true, color = color.primary}
			)
		
		pageActions.tail
			:title(toJson
				{text = "Merling Settings", bold = true, color = color.primary}
			)
		
		pageActions.glow
			:title(toJson
				{text = "Glowing Settings", bold = true, color = color.primary}
			)
		
		pageActions.anims
			:title(toJson
				{text = "Animations", bold = true, color = color.primary}
			)
		
		pageActions.armor
			:title(toJson
				{text = "Armor Settings", bold = true, color = color.primary}
			)
		
		pageActions.camera
			:title(toJson
				{text = "Camera Settings", bold = true, color = color.primary}
			)
		
		pageActions.dry
			:title(toJson
				{text = "Drying Settings", bold = true, color = color.primary}
			)
		
		pageActions.whirlpool
			:title(toJson
				{text = "Whirlpool Settings", bold = true, color = color.primary}
			)
		
		pageActions.eyes
			:title(toJson
				{text = "Glowing Eyes Settings", bold = true, color = color.primary}
			)
		
		for _, page in pairs(pageActions) do
			page:hoverColor(color.hover)
		end
		
	end
	
end

-- Action back to previous page
local backAction = action_wheel:newAction()
	:title(toJson
		{text = "Go Back?", bold = true, color = "red"}
	)
	:hoverColor(vectors.hexToRGB("FF5555"))
	:item(itemCheck("barrier"))
	:onLeftClick(function() ascend() end)

-- Set starting page to main page
action_wheel:setPage(pages.main)

-- Main actions
pages.main
	:action( -1, pageActions.avatar)
	:action( -1, pageActions.tail)
	:action( -1, pageActions.glow)
	:action( -1, pageActions.anims)

-- Avatar actions
pages.avatar
	:action( -1, pageActions.armor)
	:action( -1, pageActions.camera)
	:action( -1, backAction)
	:action( -1, avatar.vanillaSkinAct)
	:action( -1, avatar.modelAct)

-- Armor actions
pages.armor
	:action( -1, backAction)
	:action( -1, armor.allAct)
	:action( -1, armor.bootsAct)
	:action( -1, armor.leggingsAct)
	:action( -1, armor.chestplateAct)
	:action( -1, armor.helmetAct)

-- Camera actions
pages.camera
	:action( -1, backAction)
	:action( -1, camera.posAct)
	:action( -1, camera.eyeAct)

-- Tail actions
pages.tail
	:action( -1, pageActions.dry)
	:action( -1, pageActions.whirlpool)
	:action( -1, backAction)
	:action( -1, tail.waterAct)
	:action( -1, tail.smallAct)
	:action( -1, tail.earsAct)

-- Dry actions
pages.dry
	:action( -1, backAction)
	:action( -1, tail.dryAct)
	:action( -1, tail.soundAct)

-- Whirlpool actions
pages.whirlpool
	:action( -1, backAction)
	:action( -1, whirlpool.bubbleAct)
	:action( -1, whirlpool.dolphinsGraceAct)

-- Glowing actions
pages.glow
	:action( -1, pageActions.eyes)
	:action( -1, backAction)
	:action( -1, glow.toggleAct)
	:action( -1, glow.dynamicAct)
	:action( -1, glow.waterAct)
	:action( -1, glow.uniqueAct)

-- Eye glow actions
pages.eyes
	:action( -1, backAction)
	:action( -1, eyes.toggleAct)
	:action( -1, eyes.powerAct)
	:action( -1, eyes.nightVisionAct)
	:action( -1, eyes.waterAct)

-- Animation actions
pages.anims
	:action( -1, backAction)	:action( -1, anims.sharkAct)
	:action( -1, anims.crawlAct)
	:action( -1, anims.mountAct)
	:action( -1, squapi.armsAct)
	:action( -1, anims.twirlAct)
	:action( -1, anims.singAct)

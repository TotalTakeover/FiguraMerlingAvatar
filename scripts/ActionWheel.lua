-- Required scripts
local avatar    = require("scripts.Player")
local armor     = require("scripts.Armor")
local camera    = require("scripts.CameraControl")
local tail      = require("scripts.Tail")
local whirlpool = require("scripts.WhirlpoolEffect")
local glow      = require("scripts.GlowingTail")
local eyes      = require("scripts.GlowingEyes")
local anims     = require("scripts.Anims")
local arms      = require("scripts.Arms")

-- Page setups
local mainPage      = action_wheel:newPage("MainPage")
local avatarPage    = action_wheel:newPage("AvatarPage")
local armorPage     = action_wheel:newPage("ArmorPage")
local cameraPage    = action_wheel:newPage("CameraPage")
local tailPage      = action_wheel:newPage("TailPage")
local dryPage       = action_wheel:newPage("DryPage")
local whirlpoolPage = action_wheel:newPage("WhirlpoolPage")
local glowPage      = action_wheel:newPage("GlowPage")
local eyesPage      = action_wheel:newPage("GlowingEyesPage")
local animsPage     = action_wheel:newPage("AnimationPage")

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

-- Action back to previous page
local backPage = action_wheel:newAction()
	:title("§c§lGo Back?")
	:hoverColor(vectors.hexToRGB("FF5555"))
	:item("barrier")
	:onLeftClick(function() ascend() end)

-- Set starting page to main page
action_wheel:setPage(mainPage)

-- Main actions
mainPage
	:action( -1,
		action_wheel:newAction()
			:title("§9§lAvatar Settings")
			:hoverColor(vectors.hexToRGB("55FFFF"))
			:item("armor_stand")
			:onLeftClick(function() descend(avatarPage) end))
	
	:action( -1,
		action_wheel:newAction()
			:title("§9§lMerling Settings")
			:hoverColor(vectors.hexToRGB("55FFFF"))
			:item("tropical_fish")
			:onLeftClick(function() descend(tailPage) end))
	
	:action( -1,
		action_wheel:newAction()
			:title("§9§lGlowing Settings")
			:hoverColor(vectors.hexToRGB("55FFFF"))
			:item("glow_ink_sac")
			:onLeftClick(function() descend(glowPage) end))
	
	:action( -1,
		action_wheel:newAction()
			:title("§9§lAnimations")
			:hoverColor(vectors.hexToRGB("55FFFF"))
			:item("jukebox")
			:onLeftClick(function() descend(animsPage) end))

-- Avatar actions
avatarPage
	:action( -1, avatar.vanillaSkinPage)
	:action( -1, avatar.modelPage)
	:action( -1,
		action_wheel:newAction()
			:title("§9§lArmor Settings")
			:hoverColor(vectors.hexToRGB("55FFFF"))
			:item("iron_chestplate")
			:onLeftClick(function() descend(armorPage) end))
	:action( -1,
		action_wheel:newAction()
			:title("§9§lCamera Settings")
			:hoverColor(vectors.hexToRGB("55FFFF"))
			:item("redstone")
			:onLeftClick(function() descend(cameraPage) end))
	:action( -1, backPage)

-- Armor actions
armorPage
	:action( -1, armor.allPage)
	:action( -1, armor.bootsPage)
	:action( -1, armor.leggingsPage)
	:action( -1, armor.chestplatePage)
	:action( -1, armor.helmetPage)
	:action( -1, backPage)

-- Camera actions
cameraPage
	:action( -1, camera.posPage)
	:action( -1, camera.eyePage)
	:action( -1, backPage)

-- Tail actions
tailPage
	:action( -1, tail.activePage)
	:action( -1, tail.waterPage)
	:action( -1, tail.smallPage)
	:action( -1, tail.earsPage)
	:action( -1,
		action_wheel:newAction()
			:title("§9§lDrying Settings")
			:hoverColor(vectors.hexToRGB("55FFFF"))
			:item("sponge")
			:onLeftClick(function() descend(dryPage) end))
	:action( -1,
		action_wheel:newAction()
			:title("§9§lWhirlpool Settings")
			:hoverColor(vectors.hexToRGB("55FFFF"))
			:item("magma_block")
			:onLeftClick(function() descend(whirlpoolPage) end))
	:action( -1, backPage)

-- Dry actions
dryPage
	:action( -1, tail.dryPage)
	:action( -1, tail.soundPage)
	:action( -1, backPage)

-- Whirlpool actions
whirlpoolPage
	:action( -1, whirlpool.bubblePage)
	:action( -1, whirlpool.dolphinsGracePage)
	:action( -1, backPage)

-- Glowing actions
glowPage
	:action( -1, glow.togglePage)
	:action( -1, glow.dynamicPage)
	:action( -1, glow.waterPage)
	:action( -1,
		action_wheel:newAction()
			:title("§9§lGlowing Eyes Settings")
			:hoverColor(vectors.hexToRGB("55FFFF"))
			:item("ender_eye")
			:onLeftClick(function() descend(eyesPage) end))
	:action( -1, backPage)

-- Eye glow actions
eyesPage
	:action( -1, eyes.togglePage)
	:action( -1, eyes.powerPage)
	:action( -1, eyes.nightVisionPage)
	:action( -1, eyes.waterPage)
	:action( -1, backPage)

-- Animation actions
animsPage
	:action( -1, anims.sharkPage)
	:action( -1, anims.crawlPage)
	:action( -1, arms.movePage)
	:action( -1, anims.twirlPage)
	:action( -1, anims.singPage)
	:action( -1, backPage)
-- Required scripts
local itemCheck = require("lib.ItemCheck")
local avatar    = require("scripts.Player")
local armor     = require("scripts.Armor")
local camera    = require("scripts.CameraControl")
local tail      = require("scripts.Tail")
local whirlpool = require("scripts.WhirlpoolEffect")
local glow      = require("scripts.GlowingTail")
local eyes      = require("scripts.GlowingEyes")
local anims     = require("scripts.Anims")
local arms      = require("scripts.Arms")
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
	
	main      = action_wheel:newPage(),
	avatar    = action_wheel:newPage(),
	armor     = action_wheel:newPage(),
	camera    = action_wheel:newPage(),
	tail      = action_wheel:newPage(),
	dry       = action_wheel:newPage(),
	whirlpool = action_wheel:newPage(),
	glow      = action_wheel:newPage(),
	eyes      = action_wheel:newPage(),
	anims     = action_wheel:newPage()
	
}

-- Page actions
local pageActions = {
	
	avatar = action_wheel:newAction()
		:title(color.primary.."Avatar Settings")
		:hoverColor(color.hover)
		:item(itemCheck("armor_stand"))
		:onLeftClick(function() descend(pages.avatar) end),
	
	tail = action_wheel:newAction()
		:title(color.primary.."Merling Settings")
		:hoverColor(color.hover)
		:item(itemCheck("tropical_fish"))
		:onLeftClick(function() descend(pages.tail) end),
	
	glow = action_wheel:newAction()
		:title(color.primary.."Glowing Settings")
		:hoverColor(color.hover)
		:item(itemCheck("glow_ink_sac"))
		:onLeftClick(function() descend(pages.glow) end),
	
	anims = action_wheel:newAction()
		:title(color.primary.."Animations")
		:hoverColor(color.hover)
		:item(itemCheck("jukebox"))
		:onLeftClick(function() descend(pages.anims) end),
	
	armor = action_wheel:newAction()
		:title(color.primary.."Armor Settings")
		:hoverColor(color.hover)
		:item(itemCheck("iron_chestplate"))
		:onLeftClick(function() descend(pages.armor) end),
	
	camera = action_wheel:newAction()
		:title(color.primary.."Camera Settings")
		:hoverColor(color.hover)
		:item(itemCheck("redstone"))
		:onLeftClick(function() descend(pages.camera) end),
	
	dry = action_wheel:newAction()
		:title(color.primary.."Drying Settings")
		:hoverColor(color.hover)
		:item(itemCheck("sponge"))
		:onLeftClick(function() descend(pages.dry) end),
	
	whirlpool = action_wheel:newAction()
		:title(color.primary.."Whirlpool Settings")
		:hoverColor(color.hover)
		:item(itemCheck("magma_block"))
		:onLeftClick(function() descend(pages.whirlpool) end),
	
	eyes = action_wheel:newAction()
		:title(color.primary.."Glowing Eyes Settings")
		:hoverColor(color.hover)
		:item(itemCheck("ender_eye"))
		:onLeftClick(function() descend(pages.eyes) end)
	
}

-- Action back to previous page
local backAction = action_wheel:newAction()
	:title("§c§lGo Back?")
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
	:action( -1, avatar.vanillaSkinPage)
	:action( -1, avatar.modelPage)
	:action( -1, pageActions.armor)
	:action( -1, pageActions.camera)
	:action( -1, backAction)

-- Armor actions
pages.armor
	:action( -1, armor.allPage)
	:action( -1, armor.bootsPage)
	:action( -1, armor.leggingsPage)
	:action( -1, armor.chestplatePage)
	:action( -1, armor.helmetPage)
	:action( -1, backAction)

-- Camera actions
pages.camera
	:action( -1, camera.posPage)
	:action( -1, camera.eyePage)
	:action( -1, backAction)

-- Tail actions
pages.tail
	:action( -1, tail.activePage)
	:action( -1, tail.waterPage)
	:action( -1, tail.smallPage)
	:action( -1, tail.earsPage)
	:action( -1, pageActions.dry)
	:action( -1, pageActions.whirlpool)
	:action( -1, backAction)

-- Dry actions
pages.dry
	:action( -1, tail.dryPage)
	:action( -1, tail.soundPage)
	:action( -1, backAction)

-- Whirlpool actions
pages.whirlpool
	:action( -1, whirlpool.bubblePage)
	:action( -1, whirlpool.dolphinsGracePage)
	:action( -1, backAction)

-- Glowing actions
pages.glow
	:action( -1, glow.togglePage)
	:action( -1, glow.dynamicPage)
	:action( -1, glow.waterPage)
	:action( -1, pageActions.eyes)
	:action( -1, backAction)

-- Eye glow actions
pages.eyes
	:action( -1, eyes.togglePage)
	:action( -1, eyes.powerPage)
	:action( -1, eyes.nightVisionPage)
	:action( -1, eyes.waterPage)
	:action( -1, backAction)

-- Animation actions
pages.anims
	:action( -1, anims.sharkPage)
	:action( -1, anims.crawlPage)
	:action( -1, arms.movePage)
	:action( -1, anims.twirlPage)
	:action( -1, anims.singPage)
	:action( -1, backAction)
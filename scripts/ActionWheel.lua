-- Connects various actions accross many scripts into pages
local mainPage = action_wheel:newPage("MainPage")
local eyesPage = action_wheel:newPage("GlowingEyesPage")
local tailPage = action_wheel:newPage("TailPage")
local glowPage = action_wheel:newPage("GlowPage")
local whirPage = action_wheel:newPage("WhirlpoolPage")
local avatPage = action_wheel:newPage("AvatarPage")
local camPage  = action_wheel:newPage("CameraPage")
local animPage = action_wheel:newPage("AnimationPage")
local backPage = action_wheel:newAction()
	:title("§c§lGo Back?")
	:hoverColor(vectors.hexToRGB("FF5555"))
	:item("minecraft:barrier")
	:onLeftClick(function() action_wheel:setPage(mainPage) end)

action_wheel:setPage(mainPage)

-- Main actions
mainPage
	:action( 1,
		action_wheel:newAction()
			:title("§9§lGlowing Eyes Settings")
			:hoverColor(vectors.hexToRGB("55FFFF"))
			:item("minecraft:ender_eye")
			:onLeftClick(function() action_wheel:setPage(eyesPage) end))
	
	:action( 2,
		action_wheel:newAction()
			:title("§9§lMerling Tail Settings")
			:hoverColor(vectors.hexToRGB("55FFFF"))
			:item("minecraft:tropical_fish")
			:onLeftClick(function() action_wheel:setPage(tailPage) end))
	
	:action( 3,
		action_wheel:newAction()
			:title("§9§lGlowing Settings")
			:hoverColor(vectors.hexToRGB("55FFFF"))
			:item("minecraft:glow_ink_sac")
			:onLeftClick(function() action_wheel:setPage(glowPage) end))
	
	:action( 4,
		action_wheel:newAction()
			:title("§9§lWhirlpool Settings")
			:hoverColor(vectors.hexToRGB("55FFFF"))
			:item("minecraft:magma_block")
			:onLeftClick(function() action_wheel:setPage(whirPage) end))
	
	:action( 5,
		action_wheel:newAction()
			:title("§9§lAvatar Settings")
			:hoverColor(vectors.hexToRGB("55FFFF"))
			:item("minecraft:armor_stand")
			:onLeftClick(function() action_wheel:setPage(avatPage) end))
	
	:action( 6,
		action_wheel:newAction()
			:title("§9§lCamera Settings")
			:hoverColor(vectors.hexToRGB("55FFFF"))
			:item("minecraft:redstone")
			:onLeftClick(function() action_wheel:setPage(camPage) end))
	
	:action( 7,
		action_wheel:newAction()
			:title("§9§lAnimations")
			:hoverColor(vectors.hexToRGB("55FFFF"))
			:item("minecraft:jukebox")
			:onLeftClick(function() action_wheel:setPage(animPage) end))

-- Eye glow actions
do
	local eyes = require("scripts.GlowingEyes")
	eyesPage
		:action( 1, eyes.togglePage)
		:action( 2, eyes.originsPage)
		:action( 3, eyes.effectPage)
		:action( 4, eyes.waterPage)
		:action( 5, backPage)
end

-- Tail actions
do
	local tail = require("scripts.Tail")
	tailPage
		:action( 1, tail.tailPage)
		:action( 2, tail.waterPage)
		:action( 3, tail.dryPage)
		:action( 4, tail.soundPage)
		:action( 5, backPage)
end

-- Glowing actions
do
	local glow = require("scripts.GlowingTail")
	glowPage
		:action( 1, glow.glowPage)
		:action( 2, glow.dynamicPage)
		:action( 3, glow.waterPage)
		:action( 4, backPage)
end

-- Whirlpool actions
do
	local whir = require("scripts.WhirlpoolEffect")
	whirPage
		:action( 1, whir.bubblePage)
		:action( 2, whir.effectPage)
		:action( 3, backPage)
end

-- Avatar actions
do
	local avatar = require("scripts.Player")
	avatPage
		:action( 1, avatar.vanillaSkinPage)
		:action( 2, avatar.modelPage)
		:action( 3, require("scripts.Arms"))
		:action( 4, backPage)
end

-- Camera actions
do
	local camera = require("scripts.CameraControl")
	camPage
		:action( 1, camera.posPage)
		:action( 2, camera.eyePage)
		:action( 3, backPage)
end

-- Animation actions
do
    local anim = require("scripts.Anims")
    animPage
		:action( 1, anim.sharkPage)
		:action( 2, anim.crawlPage)
		:action( 3, anim.twirlPage)
		:action( 4, anim.singPage)
		:action( 5, backPage)
end
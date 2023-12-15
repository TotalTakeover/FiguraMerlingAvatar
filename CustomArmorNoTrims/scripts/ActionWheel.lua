-- Connects various actions accross many scripts into pages
local mainPage = action_wheel:newPage("MainPage")
local eyesPage = action_wheel:newPage("GlowingEyesPage")
local tailPage = action_wheel:newPage("TailPage")
local glowPage = action_wheel:newPage("GlowPage")
local whirPage = action_wheel:newPage("WhirlpoolPage")
local avatPage = action_wheel:newPage("AvatarPage")
local camPage  = action_wheel:newPage("CameraPage")
local backPage = action_wheel:newAction()
	:title("§c§lGo Back?")
	:hoverColor(vectors.hexToRGB("FF5555"))
	:item("minecraft:barrier")
	:onLeftClick(function() action_wheel:setPage(mainPage) end)

action_wheel:setPage(mainPage)

-- Main actions
mainPage
	:action( -1,
		action_wheel:newAction()
			:title("§9§lGlowing Eyes Settings")
			:hoverColor(vectors.hexToRGB("55FFFF"))
			:item("minecraft:ender_eye")
			:onLeftClick(function() action_wheel:setPage(eyesPage) end))
	
	:action( -1,
		action_wheel:newAction()
			:title("§9§lMerling Tail Settings")
			:hoverColor(vectors.hexToRGB("55FFFF"))
			:item("minecraft:tropical_fish")
			:onLeftClick(function() action_wheel:setPage(tailPage) end))
	
	:action( -1,
		action_wheel:newAction()
			:title("§9§lGlowing Settings")
			:hoverColor(vectors.hexToRGB("55FFFF"))
			:item("minecraft:glow_ink_sac")
			:onLeftClick(function() action_wheel:setPage(glowPage) end))
	
	:action( -1,
		action_wheel:newAction()
			:title("§9§lWhirlpool Settings")
			:hoverColor(vectors.hexToRGB("55FFFF"))
			:item("minecraft:magma_block")
			:onLeftClick(function() action_wheel:setPage(whirPage) end))
	
	:action( -1,
		action_wheel:newAction()
			:title("§9§lAvatar Settings")
			:hoverColor(vectors.hexToRGB("55FFFF"))
			:item("minecraft:armor_stand")
			:onLeftClick(function() action_wheel:setPage(avatPage) end))
	
	:action( -1,
		action_wheel:newAction()
			:title("§9§lCamera Settings")
			:hoverColor(vectors.hexToRGB("55FFFF"))
			:item("minecraft:redstone")
			:onLeftClick(function() action_wheel:setPage(camPage) end))

-- Eye glow actions
do
	local eyes = require("scripts.GlowingEyes")
	eyesPage
		:action( -1, eyes.togglePage)
		:action( -1, eyes.originsPage)
		:action( -1, eyes.effectPage)
		:action( -1, eyes.waterPage)
		:action( -1, backPage)
end

-- Tail actions
do
	local tail = require("scripts.Tail")
	local anim = require("scripts.Anims")
	tailPage
		:action( -1, tail.tailPage)
		:action( -1, tail.waterPage)
		:action( -1, tail.dryPage)
		:action( -1, tail.soundPage)
		:action( -1, anim.sharkPage)
		:action( -1, anim.crawlPage)
		:action( -1, backPage)
	
	function events.TICK()
		action_wheel:getPage("TailPage"):getAction(2):title(tail.waterTitle)
			:item(tail.waterItem)
			:color(vectors.hexToRGB(tail.waterColor))
		action_wheel:getPage("TailPage"):getAction(3):title(tail.dryTitle)
	end
end

-- Glowing actions
do
	local glow = require("scripts.GlowingTail")
	glowPage
		:action( -1, glow.glowPage)
		:action( -1, glow.dynamicPage)
		:action( -1, glow.waterPage)
		:action( -1, backPage)
	
	function events.TICK()
		action_wheel:getPage("GlowPage"):getAction(2):toggleItem(glow.dynamicItem)
	end
end

-- Whirlpool actions
do
	local whir = require("scripts.WhirlpoolEffect")
	whirPage
		:action( -1, whir.bubblePage)
		:action( -1, whir.effectPage)
		:action( -1, backPage)
end

-- Avatar actions
do
	local avatar = require("scripts.Player")
	avatPage
		:action( -1, avatar.vanillaSkinPage)
		:action( -1, avatar.modelPage)
		:action( -1, require("scripts.Arms"))
		:action( -1, backPage)
end

-- Camera actions
do
	local camera = require("scripts.CameraControl")
	camPage
		:action( -1, camera.posPage)
		:action( -1, camera.eyePage)
		:action( -1, backPage)
end
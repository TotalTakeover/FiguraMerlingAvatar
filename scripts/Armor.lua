-- Model setup
local model     = models.Merling
local modelRoot = model.Player

-- Katt armor setup
local kattArmor = require("lib.KattArmor")()

-- Setting the leggings to layer 1
kattArmor.Armor.Leggings:setLayer(1)

-- Armor parts
kattArmor.Armor.Leggings
	:addParts(
		modelRoot.Body.Tail1.Tail1Armor.Leggings,
		modelRoot.Body.Tail1.Tail1Armor.Brim,
		modelRoot.Body.Tail1.Tail2.Tail2Armor.Leggings
	)
	:addTrimParts(
		modelRoot.Body.Tail1.Tail1Armor.LeggingsTrim,
		modelRoot.Body.Tail1.Tail1Armor.BrimTrim,
		modelRoot.Body.Tail1.Tail2.Tail2Armor.LeggingsTrim
	)
kattArmor.Armor.Boots
	:addParts(
		modelRoot.Body.Tail1.Tail2.Tail3.Tail3Armor.Boots,
		modelRoot.Body.Tail1.Tail2.Tail3.Tail4.Tail4Armor.Boots
	)
	:addTrimParts(
		modelRoot.Body.Tail1.Tail2.Tail3.Tail3Armor.BootsTrim,
		modelRoot.Body.Tail1.Tail2.Tail3.Tail4.Tail4Armor.BootsTrim
	)

-- Leather armor
kattArmor.Materials.leather
	:setTexture(textures["textures.armor.leatherArmor"])
	:addParts(kattArmor.Armor.Leggings,
		modelRoot.Body.Tail1.Tail1Armor.LeggingsLeather,
		modelRoot.Body.Tail1.Tail1Armor.BrimLeather,
		modelRoot.Body.Tail1.Tail2.Tail2Armor.LeggingsLeather
	)
	:addParts(kattArmor.Armor.Boots,
		modelRoot.Body.Tail1.Tail2.Tail3.Tail3Armor.BootsLeather,
		modelRoot.Body.Tail1.Tail2.Tail3.Tail4.Tail4Armor.BootsLeather
	)

-- Chainmail armor
kattArmor.Materials.chainmail
	:setTexture(textures["textures.armor.chainmailArmor"])

-- Iron armor
kattArmor.Materials.iron
	:setTexture(textures["textures.armor.ironArmor"])

-- Golden armor
kattArmor.Materials.golden
	:setTexture(textures["textures.armor.goldenArmor"])

-- Diamond armor
kattArmor.Materials.diamond
	:setTexture(textures["textures.armor.diamondArmor"])

-- Netherite armor
kattArmor.Materials.netherite
	:setTexture(textures["textures.armor.netheriteArmor"])

-- Turtle helmet
kattArmor.Materials.turtle
	:setTexture(textures["textures.armor.turtleHelmet"])

-- Trims
-- Coast
kattArmor.TrimPatterns.coast
	:setTexture(textures["textures.armor.trims.coastTrim"])

-- Dune
kattArmor.TrimPatterns.dune
	:setTexture(textures["textures.armor.trims.duneTrim"])

-- Eye
kattArmor.TrimPatterns.eye
	:setTexture(textures["textures.armor.trims.eyeTrim"])

-- Host
kattArmor.TrimPatterns.host
	:setTexture(textures["textures.armor.trims.hostTrim"])

-- Raiser
kattArmor.TrimPatterns.raiser
	:setTexture(textures["textures.armor.trims.raiserTrim"])

-- Rib
kattArmor.TrimPatterns.rib
	:setTexture(textures["textures.armor.trims.ribTrim"])

-- Sentry
kattArmor.TrimPatterns.sentry
	:setTexture(textures["textures.armor.trims.sentryTrim"])

-- Shaper
kattArmor.TrimPatterns.shaper
	:setTexture(textures["textures.armor.trims.shaperTrim"])

-- Silence
kattArmor.TrimPatterns.silence
	:setTexture(textures["textures.armor.trims.silenceTrim"])

-- Snout
kattArmor.TrimPatterns.snout
	:setTexture(textures["textures.armor.trims.snoutTrim"])

-- Spire
kattArmor.TrimPatterns.spire
	:setTexture(textures["textures.armor.trims.spireTrim"])

-- Tide
kattArmor.TrimPatterns.tide
	:setTexture(textures["textures.armor.trims.tideTrim"])

-- Vex
kattArmor.TrimPatterns.vex
	:setTexture(textures["textures.armor.trims.vexTrim"])

-- Ward
kattArmor.TrimPatterns.ward
	:setTexture(textures["textures.armor.trims.wardTrim"])

-- Wayfinder
kattArmor.TrimPatterns.wayfinder
	:setTexture(textures["textures.armor.trims.wayfinderTrim"])

-- Wild
kattArmor.TrimPatterns.wild
	:setTexture(textures["textures.armor.trims.wildTrim"])
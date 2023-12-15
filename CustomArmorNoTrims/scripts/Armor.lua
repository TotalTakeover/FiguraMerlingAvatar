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
		modelRoot.Body.Tail.Armor.Leggings,
		modelRoot.Body.Tail.Armor.Brim,
		modelRoot.Body.Tail.Tail.Armor.Leggings
	)
kattArmor.Armor.Boots
	:addParts(
		modelRoot.Body.Tail.Tail.Tail.Armor.Boots,
		modelRoot.Body.Tail.Tail.Tail.Tail.Armor.Boots
	)

-- Leather armor
kattArmor.Materials.leather
	:setTexture(textures["textures.armor.leatherArmor"])
	:addParts(kattArmor.Armor.Leggings,
		modelRoot.Body.Tail.Armor.LeggingsLeather,
		modelRoot.Body.Tail.Armor.BrimLeather,
		modelRoot.Body.Tail.Tail.Armor.LeggingsLeather
	)
	:addParts(kattArmor.Armor.Boots,
		modelRoot.Body.Tail.Tail.Tail.Armor.BootsLeather,
		modelRoot.Body.Tail.Tail.Tail.Tail.Armor.BootsLeather
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
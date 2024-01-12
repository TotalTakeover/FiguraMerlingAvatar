-- Required scripts
local model     = require("scripts.ModelParts")
local kattArmor = require("lib.KattArmor")()

-- Setting the leggings to layer 1
kattArmor.Armor.Leggings:setLayer(1)

-- Armor parts
kattArmor.Armor.Leggings
	:addParts(
		model.tailRoot.Tail1ArmorLeggings.Leggings,
		model.tailRoot.Tail1ArmorLeggings.LeggingsBrim,
		model.tailRoot.Tail2.Tail2ArmorLeggings.Leggings
	)
	:addTrimParts(
		model.tailRoot.Tail1ArmorLeggings.LeggingsTrim,
		model.tailRoot.Tail1ArmorLeggings.LeggingsBrimTrim,
		model.tailRoot.Tail2.Tail2ArmorLeggings.LeggingsTrim
	)
kattArmor.Armor.Boots
	:addParts(
		model.tailRoot.Tail2.Tail3.Tail3ArmorBoots.Boots,
		model.tailRoot.Tail2.Tail3.Tail4.Tail4ArmorBoots.Boots
	)
	:addTrimParts(
		model.tailRoot.Tail2.Tail3.Tail3ArmorBoots.BootsTrim,
		model.tailRoot.Tail2.Tail3.Tail4.Tail4ArmorBoots.BootsTrim
	)

-- Leather armor
kattArmor.Materials.leather
	:setTexture(textures["textures.armor.leatherArmor"])
	:addParts(kattArmor.Armor.Leggings,
		model.tailRoot.Tail1ArmorLeggings.LeggingsLeather,
		model.tailRoot.Tail1ArmorLeggings.LeggingsBrimLeather,
		model.tailRoot.Tail2.Tail2ArmorLeggings.LeggingsLeather
	)
	:addParts(kattArmor.Armor.Boots,
		model.tailRoot.Tail2.Tail3.Tail3ArmorBoots.BootsLeather,
		model.tailRoot.Tail2.Tail3.Tail4.Tail4ArmorBoots.BootsLeather
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

-- Config setup
config:name("Merling")
local helmet     = config:load("ArmorHelmet")
local chestplate = config:load("ArmorChestplate")
local leggings   = config:load("ArmorLeggings")
local boots      = config:load("ArmorBoots")
if helmet     == nil then helmet     = true end
if chestplate == nil then chestplate = true end
if leggings   == nil then leggings   = true end
if boots      == nil then boots      = true end

function events.TICK()
	
	for _, part in ipairs(model.helmetToggle) do
		part:visible(helmet)
	end
	
	for _, part in ipairs(model.chestplateToggle) do
		part:visible(chestplate)
	end
	
	for _, part in ipairs(model.leggingsToggle) do
		part:visible(leggings)
	end
	
	for _, part in ipairs(model.bootsToggle) do
		part:visible(boots)
	end
	
end

-- Armor all toggle
local function setAll(boolean)
	
	helmet     = boolean
	chestplate = boolean
	leggings   = boolean
	boots      = boolean
	config:save("ArmorHelmet", helmet)
	config:save("ArmorChestplate", chestplate)
	config:save("ArmorLeggings", leggings)
	config:save("ArmorBoots", boots)
	if player:isLoaded() then
		sounds:playSound("minecraft:item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor helmet toggle
local function setHelmet(boolean)
	
	helmet = boolean
	config:save("ArmorHelmet", helmet)
	if player:isLoaded() then
		sounds:playSound("minecraft:item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor chestplate toggle
local function setChestplate(boolean)
	
	chestplate = boolean
	config:save("ArmorChestplate", chestplate)
	if player:isLoaded() then
		sounds:playSound("minecraft:item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor leggings toggle
local function setLeggings(boolean)
	
	leggings = boolean
	config:save("ArmorLeggings", leggings)
	if player:isLoaded() then
		sounds:playSound("minecraft:item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor boots toggle
local function setBoots(boolean)
	
	boots = boolean
	config:save("ArmorBoots", boots)
	if player:isLoaded() then
		sounds:playSound("minecraft:item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Sync variables
local function syncArmor(a, b, c, d)
	
	helmet     = a
	chestplate = b
	leggings   = c
	boots      = d
	
end

-- Pings setup
pings.setArmorAll        = setAll
pings.setArmorHelmet     = setHelmet
pings.setArmorChestplate = setChestplate
pings.setArmorLeggings   = setLeggings
pings.setArmorBoots      = setBoots
pings.syncArmor          = syncArmor

-- Sync on tick
if host:isHost() then
	function events.TICK()
		
		if world.getTime() % 200 == 0 then
			pings.syncArmor(helmet, chestplate, leggings, boots)
		end
		
	end
end

-- Activate actions
setHelmet(helmet)
setChestplate(chestplate)
setLeggings(leggings)
setBoots(boots)

-- Setup table
local t = {}

-- Action wheel pages
t.allPage = action_wheel:newAction("AllArmorToggle")
	:title("§9§lToggle All Armor\n\n§bToggles visibility of all armor parts.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("minecraft:armor_stand")
	:toggleItem("minecraft:netherite_chestplate")
	:onToggle(pings.setArmorAll)

t.helmetPage = action_wheel:newAction("HelmetArmorToggle")
	:title("§9§lToggle Helmet\n\n§bToggles visibility of helmet parts.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("minecraft:iron_helmet")
	:toggleItem("minecraft:diamond_helmet")
	:onToggle(pings.setArmorHelmet)

t.chestplatePage = action_wheel:newAction("ChestplateArmorToggle")
	:title("§9§lToggle Chestplate\n\n§bToggles visibility of chestplate parts.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("minecraft:iron_chestplate")
	:toggleItem("minecraft:diamond_chestplate")
	:onToggle(pings.setArmorChestplate)

t.leggingsPage = action_wheel:newAction("LeggingsArmorToggle")
	:title("§9§lToggle Leggings\n\n§bToggles visibility of leggings parts.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("minecraft:iron_leggings")
	:toggleItem("minecraft:diamond_leggings")
	:onToggle(pings.setArmorLeggings)

t.bootsPage = action_wheel:newAction("BootsArmorToggle")
	:title("§9§lToggle Boots\n\n§bToggles visibility of boots.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("minecraft:iron_boots")
	:toggleItem("minecraft:diamond_boots")
	:onToggle(pings.setArmorBoots)

-- Update action page info
function events.TICK()
	
	t.allPage       :toggled(helmet and chestplate and leggings and boots)
	t.helmetPage    :toggled(helmet)
	t.chestplatePage:toggled(chestplate)
	t.leggingsPage  :toggled(leggings)
	t.bootsPage     :toggled(boots)
	
end

-- Return action wheel pages
return t
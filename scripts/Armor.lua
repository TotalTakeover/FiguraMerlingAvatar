-- Required scripts
local parts     = require("lib.GroupIndex")(models)
local kattArmor = require("lib.KattArmor")()

-- Setting the leggings to layer 1
kattArmor.Armor.Leggings:setLayer(1)

-- Armor parts
kattArmor.Armor.Leggings
	:addParts(
		parts.Tail1ArmorLeggings.Leggings,
		parts.Tail1ArmorLeggings.BrimLeggings,
		parts.Tail2ArmorLeggings.Leggings
	)
	:addTrimParts(
		parts.Tail1ArmorLeggings.Trim,
		parts.Tail1ArmorLeggings.BrimTrim,
		parts.Tail2ArmorLeggings.Trim
	)
kattArmor.Armor.Boots
	:addParts(
		parts.Tail3ArmorBoots.Boots,
		parts.Tail4ArmorBoots.Boots
	)
	:addTrimParts(
		parts.Tail3ArmorBoots.Trim,
		parts.Tail4ArmorBoots.Trim
	)

-- Leather armor
kattArmor.Materials.leather
	:setTexture(textures["textures.armor.leatherArmor"])
	:addParts(kattArmor.Armor.Leggings,
		parts.Tail1ArmorLeggings.Leather,
		parts.Tail1ArmorLeggings.BrimLeather,
		parts.Tail2ArmorLeggings.Leather
	)
	:addParts(kattArmor.Armor.Boots,
		parts.Tail3ArmorBoots.Leather,
		parts.Tail4ArmorBoots.Leather
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

-- All helmet parts
local helmetGroups = {
	
	parts.HelmetPivot,
	parts.HelmetItemPivot
	
}

-- All chestplate parts
local chestplateGroups = {
	
	parts.ChestplatePivot,
	parts.LeftShoulderPivot,
	parts.RightShoulderPivot
	
}

-- All leggings parts
local leggingsGroups = {
	
	parts.LeggingsPivot,
	parts.LeftLeggingPivot,
	parts.RightLeggingPivot,
	
	parts.Tail1ArmorLeggings,
	parts.Tail2ArmorLeggings
	
}

-- All boots parts
local bootsGroups = {
	
	parts.LeftBootPivot,
	parts.RightBootPivot,
	
	parts.Tail3ArmorBoots,
	parts.Tail4ArmorBoots
	
}

function events.TICK()
	
	for _, part in ipairs(helmetGroups) do
		part:visible(helmet)
	end
	
	for _, part in ipairs(chestplateGroups) do
		part:visible(chestplate)
	end
	
	for _, part in ipairs(leggingsGroups) do
		part:visible(leggings)
	end
	
	for _, part in ipairs(bootsGroups) do
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
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor helmet toggle
local function setHelmet(boolean)
	
	helmet = boolean
	config:save("ArmorHelmet", helmet)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor chestplate toggle
local function setChestplate(boolean)
	
	chestplate = boolean
	config:save("ArmorChestplate", chestplate)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor leggings toggle
local function setLeggings(boolean)
	
	leggings = boolean
	config:save("ArmorLeggings", leggings)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor boots toggle
local function setBoots(boolean)
	
	boots = boolean
	config:save("ArmorBoots", boots)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
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
	:item("armor_stand")
	:toggleItem("netherite_chestplate")
	:onToggle(pings.setArmorAll)

t.helmetPage = action_wheel:newAction("HelmetArmorToggle")
	:title("§9§lToggle Helmet\n\n§bToggles visibility of helmet parts.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("iron_helmet")
	:toggleItem("diamond_helmet")
	:onToggle(pings.setArmorHelmet)

t.chestplatePage = action_wheel:newAction("ChestplateArmorToggle")
	:title("§9§lToggle Chestplate\n\n§bToggles visibility of chestplate parts.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("iron_chestplate")
	:toggleItem("diamond_chestplate")
	:onToggle(pings.setArmorChestplate)

t.leggingsPage = action_wheel:newAction("LeggingsArmorToggle")
	:title("§9§lToggle Leggings\n\n§bToggles visibility of leggings parts.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("iron_leggings")
	:toggleItem("diamond_leggings")
	:onToggle(pings.setArmorLeggings)

t.bootsPage = action_wheel:newAction("BootsArmorToggle")
	:title("§9§lToggle Boots\n\n§bToggles visibility of boots.")
	:hoverColor(vectors.hexToRGB("55FFFF"))
	:toggleColor(vectors.hexToRGB("5555FF"))
	:item("iron_boots")
	:toggleItem("diamond_boots")
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
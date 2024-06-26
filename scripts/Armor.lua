-- Required scripts
local merlingParts = require("lib.GroupIndex")(models.models.Merling)
local kattArmor    = require("lib.KattArmor")()
local itemCheck    = require("lib.ItemCheck")
local color        = require("scripts.ColorProperties")

-- Setting the leggings to layer 1
kattArmor.Armor.Leggings:setLayer(1)

-- Armor parts
kattArmor.Armor.Leggings
	:addParts(
		merlingParts.Tail1ArmorLeggings.Leggings,
		merlingParts.Tail1ArmorLeggings.BrimLeggings,
		merlingParts.Tail2ArmorLeggings.Leggings
	)
	:addTrimParts(
		merlingParts.Tail1ArmorLeggings.Trim,
		merlingParts.Tail1ArmorLeggings.BrimTrim,
		merlingParts.Tail2ArmorLeggings.Trim
	)
kattArmor.Armor.Boots
	:addParts(
		merlingParts.Tail3ArmorBoots.Boots,
		merlingParts.Tail4ArmorBoots.Boots
	)
	:addTrimParts(
		merlingParts.Tail3ArmorBoots.Trim,
		merlingParts.Tail4ArmorBoots.Trim
	)

-- Leather armor
kattArmor.Materials.leather
	:setTexture(textures["models.Merling.leatherArmor"])
	:addParts(kattArmor.Armor.Leggings,
		merlingParts.Tail1ArmorLeggings.Leather,
		merlingParts.Tail1ArmorLeggings.BrimLeather,
		merlingParts.Tail2ArmorLeggings.Leather
	)
	:addParts(kattArmor.Armor.Boots,
		merlingParts.Tail3ArmorBoots.Leather,
		merlingParts.Tail4ArmorBoots.Leather
	)

-- Chainmail armor
kattArmor.Materials.chainmail
	:setTexture(textures["models.Merling.chainmailArmor"])

-- Iron armor
kattArmor.Materials.iron
	:setTexture(textures["models.Merling.ironArmor"])

-- Golden armor
kattArmor.Materials.golden
	:setTexture(textures["models.Merling.goldenArmor"])

-- Diamond armor
kattArmor.Materials.diamond
	:setTexture(textures["models.Merling.diamondArmor"])

-- Netherite armor
kattArmor.Materials.netherite
	:setTexture(textures["models.Merling.netheriteArmor"])

-- Trims
-- Coast
kattArmor.TrimPatterns.coast
	:setTexture(textures["models.Merling.coastTrim"])

-- Dune
kattArmor.TrimPatterns.dune
	:setTexture(textures["models.Merling.duneTrim"])

-- Eye
kattArmor.TrimPatterns.eye
	:setTexture(textures["models.Merling.eyeTrim"])

-- Host
kattArmor.TrimPatterns.host
	:setTexture(textures["models.Merling.hostTrim"])

-- Raiser
kattArmor.TrimPatterns.raiser
	:setTexture(textures["models.Merling.raiserTrim"])

-- Rib
kattArmor.TrimPatterns.rib
	:setTexture(textures["models.Merling.ribTrim"])

-- Sentry
kattArmor.TrimPatterns.sentry
	:setTexture(textures["models.Merling.sentryTrim"])

-- Shaper
kattArmor.TrimPatterns.shaper
	:setTexture(textures["models.Merling.shaperTrim"])

-- Silence
kattArmor.TrimPatterns.silence
	:setTexture(textures["models.Merling.silenceTrim"])

-- Snout
kattArmor.TrimPatterns.snout
	:setTexture(textures["models.Merling.snoutTrim"])

-- Spire
kattArmor.TrimPatterns.spire
	:setTexture(textures["models.Merling.spireTrim"])

-- Tide
kattArmor.TrimPatterns.tide
	:setTexture(textures["models.Merling.tideTrim"])

-- Vex
kattArmor.TrimPatterns.vex
	:setTexture(textures["models.Merling.vexTrim"])

-- Ward
kattArmor.TrimPatterns.ward
	:setTexture(textures["models.Merling.wardTrim"])

-- Wayfinder
kattArmor.TrimPatterns.wayfinder
	:setTexture(textures["models.Merling.wayfinderTrim"])

-- Wild
kattArmor.TrimPatterns.wild
	:setTexture(textures["models.Merling.wildTrim"])

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
	
	vanilla_model.HELMET
	
}

-- All chestplate parts
local chestplateGroups = {
	
	vanilla_model.CHESTPLATE
	
}

-- All leggings parts
local leggingsGroups = {
	
	vanilla_model.LEGGINGS,
	
	merlingParts.Tail1ArmorLeggings,
	merlingParts.Tail2ArmorLeggings
	
}

-- All boots parts
local bootsGroups = {
	
	vanilla_model.BOOTS,
	
	merlingParts.Tail3ArmorBoots,
	merlingParts.Tail4ArmorBoots
	
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
function pings.setArmorAll(boolean)
	
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
function pings.setArmorHelmet(boolean)
	
	helmet = boolean
	config:save("ArmorHelmet", helmet)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor chestplate toggle
function pings.setArmorChestplate(boolean)
	
	chestplate = boolean
	config:save("ArmorChestplate", chestplate)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor leggings toggle
function pings.setArmorLeggings(boolean)
	
	leggings = boolean
	config:save("ArmorLeggings", leggings)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor boots toggle
function pings.setArmorBoots(boolean)
	
	boots = boolean
	config:save("ArmorBoots", boots)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Sync variables
function pings.syncArmor(a, b, c, d)
	
	helmet     = a
	chestplate = b
	leggings   = c
	boots      = d
	
end

-- Host only instructions
if not host:isHost() then return end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncArmor(helmet, chestplate, leggings, boots)
	end
	
end

-- Setup table
local t = {}

-- Action wheel pages
t.allPage = action_wheel:newAction()
	:item(itemCheck("armor_stand"))
	:toggleItem(itemCheck("netherite_chestplate"))
	:onToggle(pings.setArmorAll)

t.helmetPage = action_wheel:newAction()
	:item(itemCheck("iron_helmet"))
	:toggleItem(itemCheck("diamond_helmet"))
	:onToggle(pings.setArmorHelmet)

t.chestplatePage = action_wheel:newAction()
	:item(itemCheck("iron_chestplate"))
	:toggleItem(itemCheck("diamond_chestplate"))
	:onToggle(pings.setArmorChestplate)

t.leggingsPage = action_wheel:newAction()
	:item(itemCheck("iron_leggings"))
	:toggleItem(itemCheck("diamond_leggings"))
	:onToggle(pings.setArmorLeggings)

t.bootsPage = action_wheel:newAction()
	:item(itemCheck("iron_boots"))
	:toggleItem(itemCheck("diamond_boots"))
	:onToggle(pings.setArmorBoots)

-- Update action page info
function events.TICK()
	
	if action_wheel:isEnabled() then
		t.allPage
			:title(toJson
				{"",
				{text = "Toggle All Armor\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of all armor parts.", color = color.secondary}}
			)
			:toggled(helmet and chestplate and leggings and boots)
		
		t.helmetPage
			:title(toJson
				{"",
				{text = "Toggle Helmet\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of helmet parts.", color = color.secondary}}
			)
			:toggled(helmet)
		
		t.chestplatePage
			:title(toJson
				{"",
				{text = "Toggle Chestplate\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of chestplate parts.", color = color.secondary}}
			)
			:toggled(chestplate)
		
		t.leggingsPage
			:title(toJson
				{"",
				{text = "Toggle Leggings\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of leggings parts.", color = color.secondary}}
			)
			:toggled(leggings)
		
		t.bootsPage
			:title(toJson
				{"",
				{text = "Toggle Boots\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of boots.", color = color.secondary}}
			)
			:toggled(boots)
		
		for _, page in pairs(t) do
			page:hoverColor(color.hover):toggleColor(color.active)
		end
		
	end
	
end

-- Return action wheel pages
return t
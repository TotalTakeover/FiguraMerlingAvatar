-- Required scripts
local parts     = require("lib.PartsAPI")
local kattArmor = require("lib.KattArmor")()

-- Setting the leggings to layer 1
kattArmor.Armor.Leggings:setLayer(1)

-- Armor parts
kattArmor.Armor.Leggings
	:addParts(
		table.unpack(parts:createTable(function(part) return part:getName() == "Leggings" end))
	)
	:addTrimParts(
		table.unpack(parts:createTable(function(part) return part:getName() == "LeggingsTrim" end))
	)
kattArmor.Armor.Boots
	:addParts(
		table.unpack(parts:createTable(function(part) return part:getName() == "Boots" end))
	)
	:addTrimParts(
		table.unpack(parts:createTable(function(part) return part:getName() == "BootsTrim" end))
	)

-- Leather armor
kattArmor.Materials.leather
	:setTexture(textures["textures.armor.leatherArmor"] or textures["models.Merling.leatherArmor"])
	:addParts(kattArmor.Armor.Leggings,
		table.unpack(parts:createTable(function(part) return part:getName() == "LeggingsLeather" end))
	)
	:addParts(kattArmor.Armor.Boots,
		table.unpack(parts:createTable(function(part) return part:getName() == "BootsLeather" end))
	)

-- Chainmail armor
kattArmor.Materials.chainmail
	:setTexture(textures["textures.armor.chainmailArmor"] or textures["models.Merling.chainmailArmor"])

-- Iron armor
kattArmor.Materials.iron
	:setTexture(textures["textures.armor.ironArmor"] or textures["models.Merling.ironArmor"])

-- Golden armor
kattArmor.Materials.golden
	:setTexture(textures["textures.armor.goldenArmor"] or textures["models.Merling.goldenArmor"])

-- Diamond armor
kattArmor.Materials.diamond
	:setTexture(textures["textures.armor.diamondArmor"] or textures["models.Merling.diamondArmor"])

-- Netherite armor
kattArmor.Materials.netherite
	:setTexture(textures["textures.armor.netheriteArmor"] or textures["models.Merling.netheriteArmor"])

-- Trims
-- Coast
kattArmor.TrimPatterns.coast
	:setTexture(textures["textures.armor.trims.coastTrim"] or textures["models.Merling.coastTrim"])

-- Dune
kattArmor.TrimPatterns.dune
	:setTexture(textures["textures.armor.trims.duneTrim"] or textures["models.Merling.duneTrim"])

-- Eye
kattArmor.TrimPatterns.eye
	:setTexture(textures["textures.armor.trims.eyeTrim"] or textures["models.Merling.eyeTrim"])

-- Host
kattArmor.TrimPatterns.host
	:setTexture(textures["textures.armor.trims.hostTrim"] or textures["models.Merling.hostTrim"])

-- Raiser
kattArmor.TrimPatterns.raiser
	:setTexture(textures["textures.armor.trims.raiserTrim"] or textures["models.Merling.raiserTrim"])

-- Rib
kattArmor.TrimPatterns.rib
	:setTexture(textures["textures.armor.trims.ribTrim"] or textures["models.Merling.ribTrim"])

-- Sentry
kattArmor.TrimPatterns.sentry
	:setTexture(textures["textures.armor.trims.sentryTrim"] or textures["models.Merling.sentryTrim"])

-- Shaper
kattArmor.TrimPatterns.shaper
	:setTexture(textures["textures.armor.trims.shaperTrim"] or textures["models.Merling.shaperTrim"])

-- Silence
kattArmor.TrimPatterns.silence
	:setTexture(textures["textures.armor.trims.silenceTrim"] or textures["models.Merling.silenceTrim"])

-- Snout
kattArmor.TrimPatterns.snout
	:setTexture(textures["textures.armor.trims.snoutTrim"] or textures["models.Merling.snoutTrim"])

-- Spire
kattArmor.TrimPatterns.spire
	:setTexture(textures["textures.armor.trims.spireTrim"] or textures["models.Merling.spireTrim"])

-- Tide
kattArmor.TrimPatterns.tide
	:setTexture(textures["textures.armor.trims.tideTrim"] or textures["models.Merling.tideTrim"])

-- Vex
kattArmor.TrimPatterns.vex
	:setTexture(textures["textures.armor.trims.vexTrim"] or textures["models.Merling.vexTrim"])

-- Ward
kattArmor.TrimPatterns.ward
	:setTexture(textures["textures.armor.trims.wardTrim"] or textures["models.Merling.wardTrim"])

-- Wayfinder
kattArmor.TrimPatterns.wayfinder
	:setTexture(textures["textures.armor.trims.wayfinderTrim"] or textures["models.Merling.wayfinderTrim"])

-- Wild
kattArmor.TrimPatterns.wild
	:setTexture(textures["textures.armor.trims.wildTrim"] or textures["models.Merling.wildTrim"])

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

-- Helmet parts
local helmetGroups = {
	
	vanilla_model.HELMET
	
}

-- Chestplate parts
local chestplateGroups = {
	
	vanilla_model.CHESTPLATE
	
}

-- Leggings parts
local leggingsGroups = {
	
	vanilla_model.LEGGINGS,
	table.unpack(parts:createTable(function(part) return part:getName():find("ArmorLeggings") end))
	
}

-- Boots parts
local bootsGroups = {
	
	vanilla_model.BOOTS,
	table.unpack(parts:createTable(function(part) return part:getName():find("ArmorBoots") end))
	
}

function events.TICK()
	
	-- Apply
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

-- All toggle
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

-- Helmet toggle
function pings.setArmorHelmet(boolean)
	
	helmet = boolean
	config:save("ArmorHelmet", helmet)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Chestplate toggle
function pings.setArmorChestplate(boolean)
	
	chestplate = boolean
	config:save("ArmorChestplate", chestplate)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Leggings toggle
function pings.setArmorLeggings(boolean)
	
	leggings = boolean
	config:save("ArmorLeggings", leggings)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Boots toggle
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

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local color     = require("scripts.ColorProperties")

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncArmor(helmet, chestplate, leggings, boots)
	end
	
end

-- Table setup
local t = {}

-- Actions
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

-- Update actions
function events.RENDER(delta, context)
	
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

-- Return actions
return t
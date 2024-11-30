-- Kill script if `mermod_tail` is not found
if not mermod_tail then return {} end 

-- Disable mermod tail
if mermod_tail.setVisible then -- 1.19+
	mermod_tail:setVisible(false)
end
if mermod_tail.setDisabled then -- 1.18
	mermod_tail.setDisabled(true)
end

-- Kill script if unable to style tail
if not mermod_tail.getTailStyle then return {} end

-- Required script
local parts = require("lib.PartsAPI")
local lerp  = require("lib.LerpAPI")

-- Config setup
config:name("Merling")
local override = config:load("MermodOverride") or false

-- Mermod parts
local mermodParts = parts:createTable(function(part) return part:getName():find("_[mM]ermod") end)

-- Variables
pcall(require, "scripts.ColorProperties")
initAvatarColor = vectors.hexToRGB(avatar:getColor() or "default")
local grayMat = matrices.mat4(
	vec(0.65, 0.65, 0.65, 0),
	vec(0.65, 0.65, 0.65, 0),
	vec(0.65, 0.65, 0.65, 0),
	vec(0, 0, 0, 1)
)

-- Lerps
local colorLerp = lerp:new(0.2, vec(1, 1, 1))
local gradLerp  = lerp:new(0.2, vec(1, 1, 1))
local typeLerp  = lerp:new(0.2, override and mermod_tail:getTailStyle() and 1 or 0)

-- Main textures
local mermodTextures = {
	
	primary   = textures:copy("mermodTail",   textures["textures.tail"]   or textures["Merling.tail"]),
	secondary = textures:copy("mermodTail_e", textures["textures.tail_e"] or textures["Merling.tail_e"])
	
}

-- Apply main textures
for _, part in ipairs(mermodParts) do
	
	part
		:primaryTexture("CUSTOM", mermodTextures.primary)
		:secondaryTexture("CUSTOM", mermodTextures.secondary)
	
end

-- Tails table
local tailParts = {
	
	{parts.group.Tail1},
	{
		parts.group.Tail2,
		parts.group.Tail2LeftFin,
		parts.group.Tail2RightFin
	},
	{parts.group.Tail3},
	{parts.group.Tail4},
	{parts.group.Fluke}
	
}

-- Establish tail textures
local segmentTextures = {}
local function applyGradTex(m, i)
	
	for _, c in ipairs(m:getChildren()) do
		
		if c:getName():find("_[mM]ermod") then
			c:primaryTexture("CUSTOM", segmentTextures[i].primary):secondaryTexture("CUSTOM", segmentTextures[i].secondary)
		end
		
	end
	
end
for i, k in ipairs(tailParts) do
	
	segmentTextures[i] = {
		primary   = textures:copy(mermodTextures.primary:getName()..i,       mermodTextures.primary),
		secondary = textures:copy(mermodTextures.primary:getName()..i.."_e", mermodTextures.secondary)
	}
	
	for _, part in ipairs(k) do
		applyGradTex(part, i)
	end
	
end

-- Apply color
local function applyColor(tex, color)
	
	local mat = math.lerp(matrices.mat4(), grayMat, typeLerp.currPos)
	
	local dimensions = tex:getDimensions()
	tex:restore():applyMatrix(0, 0, dimensions.x, dimensions.y, mat:scale(color), true):update()
	
end

function events.TICK()
	
	-- Variable
	local style = mermod_tail:getTailStyle()
	
	-- Targets
	colorLerp.target = override and style and vec(style.tailColorR, style.tailColorG, style.tailColorB) or vec(1, 1, 1)
	gradLerp.target  = override and style and style.hasGradient and vec(style.gradientColorR, style.gradientColorG, style.gradientColorB) or colorLerp.target
	typeLerp.target  = override and style and 1 or 0
	
end

function events.RENDER(delta, context)
	
	-- Variable
	local style = mermod_tail:getTailStyle()
	
	-- Tail textures
	for _, tex in pairs(mermodTextures) do
		applyColor(tex, colorLerp.currPos)
	end
	for k, v in ipairs(segmentTextures) do
		
		local setColor = math.lerp(colorLerp.currPos, gradLerp.currPos, k/#tailParts)
		for _, tex in pairs(v) do
			applyColor(tex, setColor)
		end
		
	end
	
	-- Avatar color
	avatar:color(math.lerp(initAvatarColor, (colorLerp.currPos + gradLerp.currPos) / 2, typeLerp.currPos))
	
end

-- Override toggle
function pings.setMermodOverride(bool)
	
	override = bool
	config:save("MermodOverride", override)
	
end

-- Sync variable
function pings.syncMermod(a)
	
	override = a
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local s, c = pcall(require, "scripts.ColorProperties")

if s then
	
	-- Store init colors
	local temp = {}
	temp.hover     = c.hover
	temp.active    = c.active
	temp.primary   = vectors.hexToRGB(c.primary)
	temp.secondary = vectors.hexToRGB(c.secondary)
	
	function events.RENDER(delta, context)
		
		-- Update action wheel colors
		c.hover     = math.lerp(temp.hover,  colorLerp.currPos, typeLerp.currPos)
		c.active    = math.lerp(temp.active, gradLerp.currPos,  typeLerp.currPos)
		c.primary   = "#"..vectors.rgbToHex(math.lerp(temp.primary,   colorLerp.currPos, typeLerp.currPos))
		c.secondary = "#"..vectors.rgbToHex(math.lerp(temp.secondary, gradLerp.currPos,  typeLerp.currPos))
		
	end
	
else
	
	c = {}
	
end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncMermod(override)
	end
	
end

-- Table setup
local t = {}

-- Action
t.overrideAct = action_wheel:newAction()
	:onToggle(pings.setMermodOverride)

-- Update action
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		
		-- Color variables
		local style = mermod_tail:getTailStyle()
		local necklace = style and vec(style.tailColorR, style.tailColorG, style.tailColorB) or vec(1, 1, 1)
		
		t.overrideAct
			:title(toJson(
				{
					"",
					{text = "Toggle Mermod Override\n\n", bold = true, color = c.primary},
					{text = "Allows mermod to apply various features onto the avatar.\n\nThis includes:\n- Tail color\n- Gradient", color = c.secondary}
				}
			))
			:item(itemCheck("mermod:sea_necklace{display:{color:"..vectors.rgbToInt(necklace).."}}"))
			:toggled(override)
		
		for _, act in pairs(t) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end

-- Return action
return t
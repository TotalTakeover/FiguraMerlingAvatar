-- Avatar color
avatar:color(vectors.hexToRGB("5555FF"))

-- Host only instructions
if not host:isHost() then return end

-- Table setup
local colors = {}

-- Action variables
colors.hover     = vectors.hexToRGB("5555FF")
colors.active    = vectors.hexToRGB("55FFFF")
colors.primary   = "blue"
colors.secondary = "aqua"

-- Return variables
return colors
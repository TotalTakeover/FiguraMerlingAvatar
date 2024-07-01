-- Avatar color
avatar:color(vectors.hexToRGB("5555FF"))

-- Host only instructions
if not host:isHost() then return end

-- Table setup
local t = {}

-- Set colors
t.hover     = vectors.hexToRGB("5555FF")
t.active    = vectors.hexToRGB("55FFFF")
t.primary   = "blue"
t.secondary = "aqua"

-- Return variables
return t
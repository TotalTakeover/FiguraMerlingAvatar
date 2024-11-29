-- Avatar color
avatar:color(vectors.hexToRGB("5555FF"))

-- Host only instructions
if not host:isHost() then return end

-- Table setup
local c = {}

-- Action variables
c.hover     = vectors.hexToRGB("5555FF")
c.active    = vectors.hexToRGB("55FFFF")
c.primary   = "blue"
c.secondary = "aqua"

-- Return variables
return c
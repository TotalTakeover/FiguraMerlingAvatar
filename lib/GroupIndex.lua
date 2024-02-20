-- Make this variable `false` or delete it if you want to turn off error messages resulting from groups of the same name
local warn = true

-- Index a model's or model part's child groups into a table
local function groupIndex(m, t)
	
    if not t then t = {} end
    local c = m:getChildren()
    
    for _, p in ipairs(c) do
        if p:getType() == "GROUP" then
			if t[p:getName()] == nil then
				t[p:getName()] = p
				groupIndex(p, t)
			elseif warn then
				error(
				"\n\n§2Please Read!§b\nYou have two Model Groups/Bones/Folders of the same name existing in the entered indexed path. This §nwill§b cause one Group to be overwritten. Please do one of the following:\n - Narrow your index search.\n - Rename one of the groups to a different name.\n - Turn off this warning in §nGroupIndex.lua§b\n\n This error occured with the Group Name:§f \""..p:getName().."\"\n§w", -1)
			end
        end
    end
    
    return t
    
end

return groupIndex
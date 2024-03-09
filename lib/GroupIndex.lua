-- Index a model's or model part's child groups into a table
local function groupIndex(m, t)
	
	if not t then 
		t = {}
		t[m:getName()] = m
	end
	
	local c = m:getChildren()
	
	for _, p in ipairs(c) do
		if p:getType() == "GROUP" then
			t[p:getName()] = p
			groupIndex(p, t)
		end
	end
	
	return t
	
end

return groupIndex
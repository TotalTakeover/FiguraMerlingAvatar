-- Check if an item exists before calling it in a function
local function itemCheck(...)
	
	local arg = {...}
	
	for _, item in ipairs(arg) do
		local success, itemStack = pcall(world.newItem, item)
		if success then return itemStack end
	end
	
end

return itemCheck
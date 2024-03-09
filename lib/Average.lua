-- Get the average of a vector
local function average(...)
	
	local sum = 0
	local arg = {...}
	
	for _, v in ipairs(arg) do
		sum = sum + v
	end
	
	return sum / #arg
	
end

return average
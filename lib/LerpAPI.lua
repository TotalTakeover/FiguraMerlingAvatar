-- LerpAPI
-- By:
--		 _________  ________  _________  ________  ___          
--		|\___   ___\\   __  \|\___   ___\\   __  \|\  \         
--		\|___ \  \_\ \  \|\  \|___ \  \_\ \  \|\  \ \  \        
--			 \ \  \ \ \  \\\  \   \ \  \ \ \   __  \ \  \       
--			  \ \  \ \ \  \\\  \   \ \  \ \ \  \ \  \ \  \____  
--			   \ \__\ \ \_______\   \ \__\ \ \__\ \__\ \_______\
--				\|__|  \|_______|    \|__|  \|__|\|__|\|_______|
--
-- Version: 1.0.0

-- Create API
local lerpAPI = {}

-- List of every lerp instance
local list = {}

-- Create a table of variables that can be lerped
function lerpAPI:new(speed, initPos)
	
	-- Create instance
	local inst = {}
	
	-- Speed
	inst.speed = speed
	
	-- Lerp variables
	local apply = initPos or 0
	inst.prevTick = apply
	inst.currTick = apply
	inst.target   = apply
	inst.currPos  = apply
	
	-- Lerp enabled
	inst.enabled = true
	
	-- Add instance to list
	table.insert(list, inst)
	
	-- Return instance variables
	return inst
	
end

-- Iterate through the list to set the next tick of each lerp
function events.TICK()
	for _, inst in ipairs(list) do
		if inst.enabled then
			inst.prevTick = inst.currTick
			inst.currTick = math.lerp(inst.currTick, inst.target, inst.speed)
		end
	end
end

-- Iterate through the list to smooth the lerp each frame
function events.RENDER(delta, context)
	for _, inst in ipairs(list) do
		if inst.enabled then
			inst.currPos = math.lerp(inst.prevTick, inst.currTick, delta)
		end
	end
end

-- Return API
return lerpAPI
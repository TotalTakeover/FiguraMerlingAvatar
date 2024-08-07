-- PartsAPI
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

-- Functions table
local partsAPI = {parts = {}, group = {}}

-- Flattens model tree
local function flatten(m, t)
	
	t = t or {}
	
	for _, c in ipairs(m:getChildren()) do
		
		table.insert(t, c)
		
		if #c:getChildren() ~= 0 then
			flatten(c, t)
		end
	
	end
	
	return t
	
end

-- Create a table of parts
function partsAPI:createTable(c, l)
	
	local t = {}
	l = l or #self.parts
	
	for _, p in ipairs(self.parts) do
		
		if c(p) then
			table.insert(t, p)
		end
		
		if l <= #t then
			break
		end
		
	end
	
	return t
	
end

-- Create a chain table based on a condition
function partsAPI:createChain(n, l, p, t)
	
	t = t or {}
	l = l or #self.parts
	
	if #t ~= 0 then
		
		for _, child in ipairs(p:getChildren()) do
			
			if #t == 1 and child:getName() == n or child:getName() == n..#t+1 then
				
				table.insert(t, child)
				self:createChain(n, l, child, t)
				break
				
			end
			
		end
		
	else
		
		t = self:createTable(function(part) return part:getName():find(n) end, 1)
		self:createChain(n, l, table.unpack(t), t)
		
	end
	
	return t
	
end

-- Create a table of groups, each with an index name, from partsAPI.parts
function partsAPI:indexGroups()
	
	local t = {}
	
	for _, p in ipairs(self.parts) do
		if p:getType() == "GROUP" then
			
			local n = p:getName()
			
			if not t[n] then
				t[n] = p
			else
				
				local c = 2
				::r::
				
				if not t[n..c] then
					t[n..c] = p
				else
					c = c + 1
					goto r
				end
				
			end
			
		end
	end
	
	return t
	
end

-- Creates/Resets part and group tables
function partsAPI:update()
	
	self.parts = flatten(models)
	self.group = self:indexGroups()
	
end

-- Create part and group tables on init
partsAPI:update()

-- Return table
return partsAPI
-- LetThatSyncFig
-- By:
--   _________  ________  _________  ________  ___
--  |\___   ___\\   __  \|\___   ___\\   __  \|\  \
--  \|___ \  \_\ \  \|\  \|___ \  \_\ \  \|\  \ \  \
--       \ \  \ \ \  \\\  \   \ \  \ \ \   __  \ \  \
--        \ \  \ \ \  \\\  \   \ \  \ \ \  \ \  \ \  \____
--         \ \__\ \ \_______\   \ \__\ \ \__\ \__\ \_______\
--          \|__|  \|_______|    \|__|  \|__|\|__|\|_______|
--
-- Special thanks: Grandpa Scout, Pool & Mangodev
-- Version: 1.1.7

-- Create API
local syncAPI = {}

-- Syncs table
local syncs = {}

-- Interal sync data
local syncInternal = {}

-- Meta table setup
local syncMeta = {
	__index = syncInternal,
	__type = "SyncObject"
}

-- Type checker that errors if type isnt what's needed
local errorOverride = false -- Unique ID error message likes to fight the typeCheck error message for some reason, this prevents that
local function typeCheck(value, typeStr)
	
	if type(value) ~= typeStr then
		errorOverride = true
		error("\n\n§6Argument must be a "..typeStr.."!\n§c", 3)
	end
	
end

-- Create a sync object
function syncAPI.new(id, ...)
	
	-- Check if the id is a string
	typeCheck(id, "string")
	
	-- Check if the id already exists
	for _, obj in ipairs(syncs) do
		if obj.id == id then
			if not errorOverride then
				error("\n\n§6ID must be unique!\n§c", 2)
			end
		end
	end
	
	-- Determine which value should be applied, checking for nil before returning
	local result
	for i = 1, select("#", ...) do
		local value = select(i, ...)
		if value ~= nil then
			result = value
		end
	end
	
	-- Create object
	local obj = setmetatable(
		{
			id = id,
			funcs = {},
			prev = result,
			curr = result
		},
		syncMeta
	)
	
	-- Add object to table
	table.insert(syncs, obj)
	
	-- Return object
	return obj
	
end

-- Sorts table deterministically
function events.ENTITY_INIT()
	
	-- Sorts table alphabetically
	table.sort(syncs, function(a, b)
		return a.id < b.id
	end)
	
	-- Grants each object a numerical id to be used when pinging
	for id, obj in ipairs(syncs) do
		obj.nid = id
	end
	
end

-- Updates sync values
local function updateValues(obj, value)
	
	-- Update current value
	obj.curr = value
	
	-- If value changed, preform the update
	if obj.curr ~= obj.prev then
		
		-- Preform optional function (if it exists)
		for _, func in pairs(obj.funcs) do func() end
		
		-- Update config if it exists
		if obj.cfg ~= nil then config:save(obj.cfg, value) end
		
		-- Update previous value
		obj.prev = value
		
	end
	
end

-- Sync variable via ping
function pings.sendSyncUpdate(key, value)
	
	-- Find sync object
	local obj = syncs[key]
	
	-- Update values
	updateValues(obj, value)
	
end

-- Sync ALL variables via ping
function pings.sendSyncUpdateAll(...)
	
	for i, value in ipairs({...}) do
		
		-- Find sync object
		local obj = syncs[i]
		
		-- Update values
		updateValues(obj, value)
		
	end
	
end

-- Update a sync object
function syncInternal:update(value, buffer)
	
	-- Check if change occured, and send ping
	-- Prevents spam caused by user
	if value ~= self.prev then
		
		-- If a buffer is provided
		if buffer ~= nil then
			
			-- Check if buffer is a number
			typeCheck(buffer, "number")
			
			-- Update on host only
			-- Ping will instead be sent when countdown reaches 0
			self.countdown = buffer
			updateValues(self, value)
			
			-- Return object
			return self
			
		end
		
		-- Send ping
		pings.sendSyncUpdate(self.nid, value)
		
	end
	
	-- Return object
	return self
	
end

-- Apply a function
function syncInternal:addFunc(func)
	
	-- Checks if function is actually a function
	typeCheck(func, "function")
	
	-- Apply function to sync
	self.funcs[func] = func
	
	-- Return object and function (incase you need it)
	return self, func
	
end

-- Remove a function
function syncInternal:removeFunc(func)
	
	-- Checks if function is actually a function
	typeCheck(func, "function")
	
	-- Remove function from sync
	self.funcs[func] = nil
	
	-- Return object
	return self
	
end

-- Apply a config key
function syncInternal:config(cfgName)
	
	-- Kill function if not host
	if not host:isHost() then return self end
	
	-- Check if the name is a string
	if cfgName ~= nil then
		typeCheck(cfgName, "string")
	end
	
	-- Apply config to sync
	self.cfg = cfgName or self.id
	
	-- Get config value
	local cfgValue = config:load(self.cfg)
	
	-- Update object if config has value
	if cfgValue ~= nil then
		updateValues(self, cfgValue)
	end
	
	-- Return object
	return self
	
end

-- Host only instructions
if not host:isHost() then return syncAPI end

-- Sync on tick
local _tick = 0
events.TICK:register(function()
	
	-- Get time
	local tick = world.getTime()
	
	-- Sync variables
	if tick % 200 == 0 and tick ~= _tick then
		
		-- Gather values
		local syncTables = {} 
		for i, obj in ipairs(syncs) do
			syncTables[i] = obj.curr
		end
		
		-- Send values
		pings.sendSyncUpdateAll(table.unpack(syncTables))
		
		-- Store prev tick
		-- Helps prevent ping spam if world is paused on tick
		_tick = tick
		
	end
	
	-- Countdown buffers
	for _, obj in ipairs(syncs) do
		if obj.countdown then
			
			-- Decrement countdown
			obj.countdown = math.max(obj.countdown - 1, 0)
			
			-- If countdown reaches 0, send ping
			if obj.countdown == 0 then
				obj.countdown = nil
				pings.sendSyncUpdate(obj.nid, obj.curr)
			end
			
		end
	end
	
end, "tickSync")

-- Return API
return syncAPI
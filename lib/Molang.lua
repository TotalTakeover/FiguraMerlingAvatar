-- Math functions
local _sin, _cos, _rad = math.sin, math.cos, math.rad

-- Molang to Lua conversions
Math = {
	---@param deg number
	sin = function(deg)
		return _sin(_rad(deg))
	end,
	---@param deg number
	cos = function(deg)
		return _cos(_rad(deg))
	end
}

-- A table of functions that will use an animation to return their values, based on the key provided.
---@type function[]
local animKeys = {
	-- Gets an animation's time with `anim_time`.
	---@param self Animation
	anim_time = function(self) return self:getTime() end
}

-- The animation that is playing at the time of key checking.
---@type Animation
local currAnim

-- The global variable Animations will use, matching Molang's `Query` or `q`.
query = setmetatable({},
	{
		-- Determines the current animation that is playing when a key is accessed.
		---@param anim Animation
		__call = function(_, _, anim)
			currAnim = anim
			return 0
		end,
		-- Determines the value of the key.
		---@param key string
		__index = function(_, key)
			return animKeys[key](currAnim)
		end
	}
)

-- Copy to alias
q = query
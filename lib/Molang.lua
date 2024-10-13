-- Molang to Lua conversions
Math = {}
Math.sin = function(a)
	return math.sin(math.rad(a))
end
Math.cos = function(a)
	return math.cos(math.rad(a))
end

-- Allow q.anim_time to be interpreted as anim:getTime()
local current
function prepare(t)
    current = t
    return 0
end
q = {}
setmetatable(q, {
    __index=function(...)
        if ({...})[2] == "anim_time" then
            return current[2]:getTime()
        end
    end
})
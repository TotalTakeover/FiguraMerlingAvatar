-- Required scripts
local merlingParts = require("lib.GroupIndex")(models.models.Merling)
local average      = require("lib.Average")

-- Remove Footsteps
function events.on_play_sound(id, pos, _, _, _, path)
	
	if average(merlingParts.Tail1:getScale():unpack()) >= 0.75 then
		return player:isLoaded() and (pos - player:getPos()):lengthSquared() < 1 and id:find("step") and path == "PLAYERS"
	end
	
end
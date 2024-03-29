-- Required scripts
local merlingParts = require("lib.GroupIndex")(models.models.Merling)
local average      = require("lib.Average")

function events.ON_PLAY_SOUND(id, pos, vol, pitch, loop, cat, path)
	
	-- Don't trigger if the sound was played by Figura (prevent potential infinite loop)
	if not path then return end
	
	-- Don't do anything if the user isn't loaded
	if not player:isLoaded() then return end
	
	-- Make sure the sound is (most likely) played by the user
	if (player:getPos() - pos):length() > 0.05 then return end
	
	-- If sound contains ".step", and the user's merling is above the 0.75 sounds threshold, stop the actual step sound
	if id:find(".step") and average(merlingParts.Tail1:getScale():unpack()) >= 0.75 then return true end
	
end
-- Table setup
local t  = {
	
	stand  = false, -- Standing
	crouch = false, -- Crouching
	swim   = false, -- Swimming / Crawling
	climb  = false, -- Climbing
	elytra = false, -- Elytra
	sleep  = false, -- Sleeping
	spin   = false, -- Riptide Spin
	crawl  = false  -- Crawling (Crawl mod required)
	
}

-- Pose checking
function events.TICK()
	
	local pose = player:getPose()
	t.stand  = pose == "STANDING"
	t.crouch = pose == "CROUCHING"
	t.swim   = pose == "SWIMMING"
	t.climb  = player:isClimbing() and not player:isOnGround()
	t.elytra = pose == "FALL_FLYING"
	t.sleep  = pose == "SLEEPING"
	t.spin   = pose == "SPIN_ATTACK"
	t.crawl  = pose == "CRAWLING" or (pose == "SWIMMING" and not player:isInWater())
	
end

-- Return table
return t
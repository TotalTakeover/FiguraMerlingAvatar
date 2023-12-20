-- GSCarrier setup
local carrier = require("lib.GSCarrier")

-- GSCarrier rider
carrier.rider.addRoots(models)
carrier.rider.addTag("gscarrier:humanoid")
carrier.rider.controller.setGlobalOffset(vec(0, -10, 0))
carrier.rider.controller.setModifyCamera(false)
carrier.rider.controller.setModifyEye(false)
carrier.rider.controller.setAimEnabled(false)

-- GSCarrier vehicle
carrier.vehicle.addTag("gscarrier:humanoid", "gscarrier:land", "gscarrier:water")

carrier.vehicle.newSeat("Seat1", models.Merling.Player.Body.Tail1.Seat1, {
	priority = 1,
	tags = {["gscarrier:piggyback"] = true}
})

function events.TICK()
	local swim = player:getPose() == "SWIMMING" or player:getPose() == "CRAWLING" or animations.Merling.crawl:isPlaying()
	models.Merling.Player.Body.Tail1.Seat1:pos(swim and vec(0, 0, -4) or nil)
end
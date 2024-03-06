function events.TICK()
	
	-- Hit sound
	if player:getNbt()["HurtTime"] == 10 then
		sounds:playSound("entity.salmon.hurt", player:getPos(), 0.6, math.random()+0.5)
	end
	
end
-- Disables mermod tail for given player
if mermod_tail then
	if mermod_tail.setVisible then -- 1.19+
		mermod_tail:setVisible(false)
	end
	if mermod_tail.setDisabled then -- 1.18
		mermod_tail.setDisabled(true)
	end
end
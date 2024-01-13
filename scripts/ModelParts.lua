-- Setup table
local t = {}

-- Model setup
t.model = models.Merling

-- Model parts
t.root = t.model.Player

-- Head parts
t.head = t.root.Head
t.eyes = t.head.Eyes
t.ears = t.head.Ears

-- Body parts
t.body     = t.root.Body
t.tailRoot = t.body.Tail1
t.elytra   = t.body.Elytra
t.cape     = t.body.Cape

-- Arm parts
t.leftArm  = t.root.LeftArm
t.rightArm = t.root.RightArm

-- Leg parts
t.leftLeg  = t.root.LeftLeg
t.rightLeg = t.root.RightLeg

-- Misc parts
t.skull    = t.model.Skull
t.portrait = t.model.Portrait

t.skull   :visible(true)
t.portrait:visible(true)

-- All vanilla skin parts
t.skin = {
	
	t.head.Head,
	t.head.HatLayer,
	
	t.body.Body,
	t.body.BodyLayer,
	
	t.leftArm.leftArmDefault,
	t.leftArm.leftArmSlim,
	
	t.rightArm.rightArmDefault,
	t.rightArm.rightArmSlim,
	
	t.leftLeg.Leg,
	t.leftLeg.LegLayer,
	
	t.rightLeg.Leg,
	t.rightLeg.LegLayer,
	
	t.portrait.Head,
	t.portrait.HatLayer,
	
	t.skull.Head,
	t.skull.HatLayer
	
}

-- All layer parts
t.layer = {

	HAT = {
		t.head.HatLayer
	},
	JACKET = {
		t.body.BodyLayer
	},
	LEFT_SLEEVE = {
		t.leftArm.leftArmDefault.ArmLayer,
		t.leftArm.leftArmSlim.ArmLayer
	},
	RIGHT_SLEEVE = {
		t.rightArm.rightArmDefault.ArmLayer,
		t.rightArm.rightArmSlim.ArmLayer
	},
	LEFT_PANTS_LEG = {
		t.leftLeg.LegLayer
	},
	RIGHT_PANTS_LEG = {
		t.rightLeg.LegLayer
	},
	TAIL = {
		t.tailRoot.Layer,
		t.tailRoot.Tail2.Layer,
		t.tailRoot.Tail2.Tail3.Layer,
		t.tailRoot.Tail2.Tail3.Tail4.Layer
	},
	CAPE = {
		t.cape
	}
	
}

-- All helmet parts
t.helmetToggle = {
	
	t.head.HelmetPivot,
	t.head.HelmetItemPivot
	
}

-- All chestplate parts
t.chestplateToggle = {
	
	t.body.ChestplatePivot,
	t.leftArm.LeftShoulderPivot,
	t.rightArm.RightShoulderPivot
	
}

-- All leggings parts
t.leggingsToggle = {
	
	t.body.LeggingsPivot,
	t.leftLeg.LeftLeggingPivot,
	t.rightLeg.RightLeggingPivot,
	
	t.tailRoot.Tail1ArmorLeggings,
	t.tailRoot.Tail2.Tail2ArmorLeggings
	
}

-- All boots parts
t.bootsToggle = {
	
	t.leftLeg.LeftBootPivot,
	t.rightLeg.RightBootPivot,
	
	t.tailRoot.Tail2.Tail3.Tail3ArmorBoots,
	t.tailRoot.Tail2.Tail3.Tail4.Tail4ArmorBoots
	
}

-- All glowing parts
t.glowingParts = {
	
	t.ears.LeftEar.Ear,
	t.ears.RightEar.Ear,
	
	t.skull.skullEars.skullLeftEar.Ear,
	t.skull.skullEars.skullRightEar.Ear,
	
	t.tailRoot.Segment,
	t.tailRoot.Tail2.Segment,
	t.tailRoot.Tail2.Tail2LeftFin.Fin,
	t.tailRoot.Tail2.Tail2RightFin.Fin,
	t.tailRoot.Tail2.Tail3.Segment,
	t.tailRoot.Tail2.Tail3.Tail4.Segment,
	t.tailRoot.Tail2.Tail3.Tail4.Fluke
	
}

--[[
	
	Because flat parts in the model are 2 faces directly on top
	of eachother, and have 0 inflate, the two faces will z-fight.
	This prevents z-fighting, as well as z-fighting at a distance,
	as well as translucent stacking.
	
	Please add plane/flat parts with 2 faces to the table below.
	0.01 works, but this works much better :)
	
--]]

-- All plane parts
t.planeParts = {
	
	t.ears.LeftEar.Ear,
	t.ears.RightEar.Ear,
	
	t.skull.skullEars.skullLeftEar.Ear,
	t.skull.skullEars.skullRightEar.Ear,
	
	t.tailRoot.Tail2.Tail2LeftFin.Fin,
	t.tailRoot.Tail2.Tail2RightFin.Fin,
	t.tailRoot.Tail2.Tail3.Tail4.Fluke
	
}

-- Apply
for _, part in ipairs(t.planeParts) do
	part:primaryRenderType("TRANSLUCENT_CULL")
end

-- Return model parts table
return t
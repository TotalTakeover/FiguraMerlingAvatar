local function overlaps(box1_min, box1_max, box2_min, box2_max)
    return not (box1_max.x <= box2_min.x or box2_max.x <= box1_min.x or
                box1_max.y <= box2_min.y or box2_max.y <= box1_min.y or
                box1_max.z <= box2_min.z or box2_max.z <= box1_min.z)
end

local CLEARANCE = 0.2
local function onGround()
    local pos = player:getPos()
    local hitbox = player:getBoundingBox()
    local min = pos - hitbox.x_z / 2 - vec(0, CLEARANCE, 0)
    local max = pos + hitbox.x_z / 2
    local search_min = min:copy():floor()
    local search_max = max:copy():floor()
    for x = search_min.x, search_max.x do
        for y = search_min.y, search_max.y do
            for z = search_min.z, search_max.z do
                local block_pos = vec(x,y,z)
                local block = world.getBlockState(block_pos)
                local boxes = block:getCollisionShape()
                for i = 1, #boxes do
                    local box = boxes[i]
                    if overlaps(min, max, block_pos + box[1], block_pos + box[2]) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

return onGround
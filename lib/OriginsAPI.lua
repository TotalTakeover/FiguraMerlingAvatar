---v1.0.1

local originsAPI = {}
---@alias Origin {Origin:string,Layer:string}
---@alias OriginPower {Type:string,Sources:string[],Data:OriginPowerData}
---@alias OriginPowerData unknown

---Checks if the given player has the given origin.
---@param playr PlayerAPI The Player to check
---@param origin string The originID to check
---@param originLayer? string Optionally, only return true if the origin is from this layer
---@return boolean
function originsAPI.hasOrigin(playr, origin, originLayer)
  local nbt=playr:getNbt()
  local origins = nbt.cardinal_components and nbt.cardinal_components["origins:origin"] and
      nbt.cardinal_components["origins:origin"].OriginLayers --[[@as Origin[] ]]
  if not origins then return false end
  for _, _origin in ipairs(origins) do
    if _origin.Origin == origin and (_origin.Layer == originLayer or originLayer == nil) then
      return true
    end
  end
  return false
end

---Checks if the given player has the given power.
---@param playr PlayerAPI The Player to check
---@param power string The powerID to check
---@param powerSource? string Optionally, only return true if the power has this source
---@return boolean
function originsAPI.hasPower(playr, power, powerSource)
  local nbt=playr:getNbt()
  local powers = nbt.cardinal_components and nbt.cardinal_components["apoli:powers"] and
      nbt.cardinal_components["apoli:powers"].Powers --[[@as OriginPower[] ]]
  if not powers then return false end
  for _, _power in ipairs(powers) do
    if _power.Type == power then
      if not powerSource then return true end
      for _, _source in ipairs(_power.Sources) do
        if _source == powerSource then
          return true
        end
      end
    end
  end
  return false
end

---Gets the resource data from the given power.
---@param playr PlayerAPI The Player to get the resource data from
---@param power string The power to get the power data from
---@param powerSource? string Optionally, only get the power data if the power has this source
---@return OriginPowerData?
function originsAPI.getPowerData(playr, power, powerSource)
  if not originsAPI.hasPower(playr, power, powerSource) then return end
  local nbt=playr:getNbt()
  local powers = nbt.cardinal_components and nbt.cardinal_components["apoli:powers"] and
      nbt.cardinal_components["apoli:powers"].Powers --[[@as OriginPower[] ]]
  for _, _power in ipairs(powers) do
    if _power.Type == power then
      return _power.Data
    end
  end
end

return originsAPI

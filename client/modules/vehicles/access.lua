local TRUNK_REACH <const> = 1.6
local SEARCH_RADIUS <const> = 5.0
local FRONT_SEAT <const> = 0
local DRIVER_SEAT <const> = -1

--- Where the boot of a vehicle is, in the world.
---
--- Worked out from the model rather than from a bone, because a bone named
--- `boot` is not something every model has and a missing one would answer the
--- centre of the car. The dimensions give a box; the boot is the middle of one
--- of its ends, and which end depends on where the engine is.
---@param entity number The vehicle entity.
---@param model number The model hash.
---@return vector3 coords Where a character has to stand.
local function bootCoords(entity, model)
  local min <const>, max <const> = GetModelDimensions(model)
  local size <const> = max - min
  local along <const> = HasFrontTrunk(model) and 1.0 or 0.0

  local offset <const> = vector3(
    min.x + size.x * 0.5,
    min.y + size.y * along,
    min.z + size.z * 0.5
  )

  return GetOffsetFromEntityInWorldCoords(entity, offset.x, offset.y, offset.z)
end

--- The vehicle the character is sitting in a front seat of.
---@return number? entity The vehicle, nil when they are not in one.
local function seatedVehicle()
  local ped <const> = PlayerPedId()
  local vehicle <const> = GetVehiclePedIsIn(ped, false)

  if not vehicle or vehicle == 0 then
    return nil
  end

  if GetPedInVehicleSeat(vehicle, DRIVER_SEAT) ~= ped
    and GetPedInVehicleSeat(vehicle, FRONT_SEAT) ~= ped then
    return nil
  end

  return vehicle
end

--- Whether a vehicle is in a state to be opened at all.
---@param entity number The vehicle entity.
---@return boolean usable Whether it may be opened.
local function isUsable(entity)
  return DoesEntityExist(entity)
    and not IsEntityDead(entity)
    and NetworkGetEntityIsNetworked(entity)
end

--- The boot the character is standing at, if any.
---
--- Every vehicle nearby is measured rather than only the closest: parked cars
--- touch, and the one whose boot you are standing at is not always the one
--- whose centre is nearest.
---@return number? entity The vehicle whose boot is within reach.
function GetReachableTrunk()
  local ped <const> = PlayerPedId()

  if GetVehiclePedIsIn(ped, false) ~= 0 then
    return nil
  end

  local coords <const> = GetEntityCoords(ped)
  local nearby <const> = Siku.GetNearbyVehicles(coords, SEARCH_RADIUS)
  local closest = nil
  local shortest = TRUNK_REACH

  for i = 1, #nearby do
    local entity <const> = nearby[i].entity

    if entity and isUsable(entity) then
      local model <const> = GetEntityModel(entity)

      if GetVehicleStorage('trunk', model, GetVehicleClass(entity)) then
        local distance <const> = #(coords - bootCoords(entity, model))

        if distance <= shortest then
          closest = entity
          shortest = distance
        end
      end
    end
  end

  return closest
end

--- The glovebox the character can reach from where they are sitting.
---@return number? entity The vehicle, nil when there is none to open.
function GetReachableGlovebox()
  local vehicle <const> = seatedVehicle()

  if not vehicle or not isUsable(vehicle) then
    return nil
  end

  if not GetVehicleStorage('glovebox', GetEntityModel(vehicle), GetVehicleClass(vehicle)) then
    return nil
  end

  return vehicle
end

--- What the server needs to find a compartment on a vehicle.
---
--- The class travels with the request because it cannot be read where it is
--- needed: the game only answers it on this side. It decides nothing but how
--- much the compartment holds, and only among the sizes the configuration
--- already declares — everything that decides whether it may be opened at all
--- is read from the entity by the server.
---@param entity number The vehicle entity.
---@return table request The vehicle network id and its class.
local function describeVehicle(entity)
  return {
    vehicle = NetworkGetNetworkIdFromEntity(entity),
    class = GetVehicleClass(entity),
  }
end

--- Opens the compartment the character is standing at, or sitting in front of.
---
--- Where they are decides what they get: a front seat opens the glovebox, and
--- standing at a boot opens the boot. Neither answers, so the bag opens on its
--- own like it always did.
---@return boolean asked Whether a compartment was asked for.
function OpenReachableCompartment()
  local glovebox <const> = GetReachableGlovebox()

  if glovebox then
    return OpenContainer('glovebox', describeVehicle(glovebox))
  end

  local trunk <const> = GetReachableTrunk()

  if trunk then
    return OpenContainer('trunk', describeVehicle(trunk))
  end

  return false
end

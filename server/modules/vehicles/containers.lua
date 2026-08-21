local REACH <const> = 6.0
local FRONT_SEAT <const> = 0
local DRIVER_SEAT <const> = -1

local ICONS <const> = {
  trunk = 'mdi-car-back',
  glovebox = 'mdi-car-door',
}

--- Reads the vehicle a request named, and everything about it that decides
--- whether a compartment may be opened.
---
--- Everything is read from the entity, except the class: the game only answers
--- that one where the vehicle is rendered, so it arrives with the request. It
--- is the single thing here that is taken on the client's word, and it decides
--- nothing but which of the declared sizes applies — a claim that names no
--- declared class simply finds no compartment.
---@param request any What was asked for.
---@return table? vehicle The entity, its plate, its model and its class.
local function readVehicle(request)
  if type(request) ~= 'table' or type(request.vehicle) ~= 'number' then
    return nil
  end

  local entity <const> = NetworkGetEntityFromNetworkId(request.vehicle)

  if not entity or entity == 0 or not DoesEntityExist(entity) then
    return nil
  end

  local plate <const> = ReadVehiclePlate(GetVehicleNumberPlateText(entity))

  if not plate then
    return nil
  end

  return {
    entity = entity,
    plate = plate,
    model = GetEntityModel(entity),
    class = type(request.class) == 'number' and request.class or nil,
  }
end

--- Whether a session is sitting where the glovebox can be reached.
---
--- The two front seats and nowhere else. Somebody in the back is a passenger,
--- not somebody with their hand on the dashboard.
---@param sessionId number The player server id.
---@param entity number The vehicle entity.
---@return boolean seated Whether they are in a front seat of that vehicle.
local function isInFront(sessionId, entity)
  local ped <const> = GetPlayerPed(tostring(sessionId))

  if not ped or ped == 0 then
    return false
  end

  return GetPedInVehicleSeat(entity, DRIVER_SEAT) == ped
    or GetPedInVehicleSeat(entity, FRONT_SEAT) == ped
end

--- Whether a session is close enough to a vehicle to be working on it.
---
--- Generous on purpose: which end the boot is at, and whether the character
--- can really reach it, is decided where the model dimensions are known. What
--- is settled here is that they are not opening a boot from across the map.
---@param sessionId number The player server id.
---@param entity number The vehicle entity.
---@return boolean near Whether they are within reach of it.
local function isNear(sessionId, entity)
  local coords <const> = GetSessionCoords(sessionId)

  if not coords then
    return false
  end

  return #(coords - GetEntityCoords(entity)) <= REACH
end

--- Builds the container behind a compartment request.
---@param compartment string `'trunk'` or `'glovebox'`.
---@param sessionId number The player server id.
---@param request table What was asked for.
---@return table? descriptor, string? reason The container to show, and why the request was refused otherwise.
local function resolveCompartment(compartment, sessionId, request)
  if not GetSessionInventory(sessionId) then
    return nil, 'no_character'
  end

  local vehicle <const> = readVehicle(request)

  if not vehicle then
    return nil, 'invalid_request'
  end

  local size <const> = GetVehicleStorage(compartment, vehicle.model, vehicle.class)

  if not size then
    return nil, 'no_storage'
  end

  local reachable <const> = compartment == 'glovebox'
    and isInFront(sessionId, vehicle.entity)
    or isNear(sessionId, vehicle.entity)

  if not reachable then
    return nil, 'unreachable'
  end

  local inventory <const> = GetKeyedInventory(
    compartment,
    vehicle.plate,
    size.slots,
    size.maxWeight
  )

  if not inventory then
    return nil, 'refused'
  end

  return {
    id = vehicle.plate,
    label = T(compartment == 'trunk' and 'trunk_label' or 'glovebox_label', vehicle.plate),
    icon = ICONS[compartment],
    plate = vehicle.plate,
    netId = request.vehicle,
    inventoryId = inventory.id,
  }
end

--- Whether a compartment may stay open. The vehicle has to still be there,
--- and the character still where they were when it opened: driving off with
--- somebody's boot open is not a way to keep looking into it.
---@param compartment string `'trunk'` or `'glovebox'`.
---@param sessionId number The player server id.
---@param descriptor table The open container.
---@return boolean allowed, string? reason Whether the view may stay, and why it may not.
local function validateCompartment(compartment, sessionId, descriptor)
  local entity <const> = NetworkGetEntityFromNetworkId(descriptor.netId)

  if not entity or entity == 0 or not DoesEntityExist(entity) then
    return false, 'unreachable'
  end

  if ReadVehiclePlate(GetVehicleNumberPlateText(entity)) ~= descriptor.plate then
    return false, 'unreachable'
  end

  if compartment == 'glovebox' then
    return isInFront(sessionId, entity), 'unreachable'
  end

  return isNear(sessionId, entity), 'unreachable'
end

RegisterContainerKind('trunk', {
  resolve = function(sessionId, request)
    return resolveCompartment('trunk', sessionId, request)
  end,
  validate = function(sessionId, descriptor)
    return validateCompartment('trunk', sessionId, descriptor)
  end,
})

RegisterContainerKind('glovebox', {
  resolve = function(sessionId, request)
    return resolveCompartment('glovebox', sessionId, request)
  end,
  validate = function(sessionId, descriptor)
    return validateCompartment('glovebox', sessionId, descriptor)
  end,
})

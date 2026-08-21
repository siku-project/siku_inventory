local CLASS_NAMES <const> = {
  [0] = 'compact',
  [1] = 'sedan',
  [2] = 'suv',
  [3] = 'coupe',
  [4] = 'muscle',
  [5] = 'sportsclassic',
  [6] = 'sports',
  [7] = 'super',
  [8] = 'motorcycle',
  [9] = 'offroad',
  [10] = 'industrial',
  [11] = 'utility',
  [12] = 'van',
  [13] = 'cycle',
  [14] = 'boat',
  [15] = 'helicopter',
  [16] = 'plane',
  [17] = 'service',
  [18] = 'emergency',
  [19] = 'military',
  [20] = 'commercial',
  [21] = 'train',
}

local COMPARTMENTS <const> = { trunk = true, glovebox = true }

local byHash = {}

--- Indexes the model exceptions by the hash the game answers with.
---
--- Written by name because a name can be read and corrected; looked up by hash
--- because that is what GetEntityModel gives back. The translation happens
--- once, here, rather than at every lookup.
---@return nil
local function indexModels()
  for name, exception in pairs(Vehicles.Models) do
    byHash[joaat(name)] = exception
  end
end

indexModels()

--- Whether a value describes a compartment rather than the absence of one.
---@param value any The declared compartment.
---@return boolean sized Whether it names a size.
local function isSized(value)
  return type(value) == 'table'
    and type(value.slots) == 'number'
    and value.slots > 0
    and type(value.maxWeight) == 'number'
    and value.maxWeight >= 0
end

--- The name this resource gives a vehicle class.
---@param class any The class the game answered with.
---@return string? name The class name, nil when the game named one we do not.
function GetVehicleClassName(class)
  return type(class) == 'number' and CLASS_NAMES[class] or nil
end

--- What a model was declared to do differently from its class.
---@param model any The model hash.
---@return table? exception The declared exception.
function GetVehicleException(model)
  return type(model) == 'number' and byHash[model] or nil
end

--- How big a compartment is on a given vehicle, and nil when it has none.
---
--- The model has the last word: it may take a compartment away that its class
--- has, give itself a size of its own, or move its boot to the front without
--- changing how much it holds.
---@param compartment string `'trunk'` or `'glovebox'`.
---@param model number The model hash.
---@param class number The class the game answered with.
---@return table? size The slots and grams it holds.
function GetVehicleStorage(compartment, model, class)
  if not COMPARTMENTS[compartment] then
    return nil
  end

  local exception <const> = GetVehicleException(model)
  local declared <const> = exception and exception[compartment]

  if declared == false then
    return nil
  end

  if isSized(declared) then
    return declared
  end

  local name <const> = GetVehicleClassName(class)
  local sizes <const> = name and Vehicles.Classes[name]

  if type(sizes) ~= 'table' then
    return nil
  end

  return isSized(sizes[compartment]) and sizes[compartment] or nil
end

--- Whether the boot of a model sits under the bonnet.
---
--- The engine is at the back on a handful of cars, and on those the boot is at
--- the front. Standing at the wrong end of one and finding nothing is the kind
--- of thing a player blames the server for.
---@param model number The model hash.
---@return boolean front Whether the boot is at the front.
function HasFrontTrunk(model)
  local exception <const> = GetVehicleException(model)

  return exception ~= nil and exception.trunk == 'front'
end

--- Reads a plate into the name a compartment is stored under.
---
--- The game pads plates to eight characters and is not fussy about case. Two
--- spellings of one plate would be two boots, so the padding goes and the case
--- is settled here, once, on both sides.
---@param plate any The plate as the game gives it.
---@return string? plate The plate as this resource stores it.
function ReadVehiclePlate(plate)
  if type(plate) ~= 'string' then
    return nil
  end

  local trimmed <const> = plate:gsub('%s+', ''):upper()

  return trimmed ~= '' and trimmed or nil
end

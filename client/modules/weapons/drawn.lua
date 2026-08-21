local REPORT_INTERVAL <const> = 400
local GUARD_INTERVAL <const> = 500
local UNARMED <const> = GetHashKey('WEAPON_UNARMED')
local MEASURE_AMMO <const> = 0
local MINIMUM_MAGAZINE <const> = 1

local drawn = nil
local held = nil
local reported = 0
local magazines = {}

--- Empties the character's hands, whatever put something in them.
---@return nil
local function clearHands()
  local ped <const> = PlayerPedId()

  RemoveAllPedWeapons(ped, true)
  SetCurrentPedWeapon(ped, UNARMED, true)
end

--- Bolts onto a weapon every component an instance carries.
---@param ped number The character ped.
---@param hash number The weapon hash.
---@param components table The components fitted to the instance, keyed by slot.
---@return nil
local function fitComponents(ped, hash, components)
  for _, item in pairs(components) do
    local variants <const> = GetComponentVariants(item)

    for i = 1, #variants do
      local component <const> = GetHashKey(variants[i])

      if DoesWeaponTakeWeaponComponent(hash, component) then
        GiveWeaponComponentToPed(ped, hash, component)
        break
      end
    end
  end
end

--- Names a weapon together with what is bolted to it, so two instances of the
--- same model carrying different parts are two different questions.
---@param name string The name the game knows the weapon by.
---@param components table The components fitted to the instance, keyed by slot.
---@return string key The identity of that combination.
local function magazineKey(name, components)
  local parts <const> = {}

  for slot, item in pairs(components) do
    parts[#parts + 1] = ('%s=%s'):format(slot, item)
  end

  table.sort(parts)

  return ('%s|%s'):format(name, table.concat(parts, ','))
end

--- Asks the game what a weapon on the ped holds once full.
---@param ped number The character ped.
---@param hash number The weapon hash.
---@return number magazine The capacity, one at the very least.
local function measureMagazine(ped, hash)
  local measured = GetMaxAmmoInClip(ped, hash, true)

  if type(measured) ~= 'number' or measured <= 0 then
    measured = GetWeaponClipSize(hash)
  end

  return math.max(MINIMUM_MAGAZINE, type(measured) == 'number' and measured or MINIMUM_MAGAZINE)
end

--- What the parts bolted to a weapon add to its weight, in grams. A component
--- screwed onto a weapon is still being carried, which is why it counts.
---@param instance table The drawn instance.
---@return number weight The weight of the whole thing.
local function weightOf(instance)
  local total = GetItemWeight(instance.item)

  for _, item in pairs(instance.components) do
    total = total + GetItemWeight(item)
  end

  return total
end

--- The weapon currently in hand, as the interface and the loader read it.
---@return table? weapon The drawn weapon.
function GetDrawnWeapon()
  return drawn
end

--- Everything known about the weapon in the character's hands.
---
--- The round count is read off the ped rather than off the last thing the
--- server said: this side is the one watching the weapon fire, and between two
--- reports it is the only side that knows. The same number is written into the
--- metadata, so a caller reading either never gets two different answers.
---@return table? weapon The weapon in hand, nil when the hands are empty.
function GetCurrentWeapon()
  if not drawn then
    return nil
  end

  local definition <const> = GetItemDefinition(drawn.item)
  local loaded <const> = drawn.takesAmmo and GetAmmoInPedWeapon(PlayerPedId(), drawn.hash) or nil
  local metadata <const> = Siku.table.deepClone(drawn.metadata or {})

  if loaded then
    metadata.ammo = loaded
  end

  return {
    uid = drawn.uid,
    item = drawn.item,
    name = drawn.name,
    label = definition and definition.label or drawn.item,
    hash = drawn.hash,
    slot = drawn.slot,
    hotbar = drawn.slot and IsHotbarSlotNumber(drawn.slot) and GetHotbarIndexOf(drawn.slot) or nil,
    weight = weightOf(drawn),
    melee = definition ~= nil and definition.category == 'melee',
    ammoItem = drawn.takesAmmo and definition and definition.ammoType or nil,
    ammo = loaded,
    magazine = drawn.takesAmmo and drawn.magazine or nil,
    components = Siku.table.deepClone(drawn.components),
    serial = metadata.serial,
    metadata = metadata,
  }
end

exports('GetCurrentWeapon', GetCurrentWeapon)

--- Tells whoever is listening what the character is holding now.
---
--- A local event rather than a net one: another resource listens with
--- AddEventHandler and is handed the same table the export answers, so nothing
--- has to poll to find out a weapon was drawn, put away, fired or filled.
---@return nil
local function publishCurrentWeapon()
  TriggerEvent('siku_inventory:client:currentWeapon', GetCurrentWeapon())
end

--- How many rounds a weapon holds once full, with its parts fitted.
---
--- An extended magazine changes the answer and only the game knows by how
--- much, so it is measured on the ped: a weapon sitting in a bag carries no
--- component the engine can read. The measurement never yields, so nothing
--- observes the character holding something it was not given, and the result
--- is remembered because a model with a given set of parts always holds the
--- same number.
---@param name string The name the game knows the weapon by.
---@param components? table The components fitted to the instance, keyed by slot.
---@return number magazine The capacity, one at the very least.
function MagazineOf(name, components)
  local hash <const> = GetHashKey(name)

  if not IsWeaponValid(hash) then
    return MINIMUM_MAGAZINE
  end

  local fitted <const> = components or {}
  local key <const> = magazineKey(name, fitted)
  local known <const> = magazines[key]

  if known then
    return known
  end

  local ped <const> = PlayerPedId()
  local inHand <const> = drawn ~= nil and drawn.hash == hash
  local liveAmmo <const> = inHand and GetAmmoInPedWeapon(ped, hash) or 0

  if inHand then
    RemoveWeaponFromPed(ped, hash)
  end

  Siku.RequestWeaponAsset(hash)
  GiveWeaponToPed(ped, hash, MEASURE_AMMO, false, false)
  fitComponents(ped, hash, fitted)

  local measured <const> = measureMagazine(ped, hash)

  RemoveWeaponFromPed(ped, hash)

  if inHand and held then
    GiveWeaponToPed(ped, hash, liveAmmo, false, true)
    fitComponents(ped, hash, held.components or {})
    SetPedAmmo(ped, hash, liveAmmo)
    SetAmmoInClip(ped, hash, liveAmmo)
    SetCurrentPedWeapon(ped, hash, true)
  end

  magazines[key] = measured

  return measured
end

--- Puts a weapon in the character's hands, with what it is carrying and
--- whatever is bolted to it.
---
--- The parts go on before the rounds. An extended magazine raises what the
--- weapon holds and the game clamps a round count to whatever the clip accepts
--- at the moment it is written, so filling first would quietly throw away
--- everything past the base capacity.
---@param payload table|false The weapon to hold, false to hold nothing.
---@return nil
function SetDrawnWeapon(payload)
  clearHands()

  if type(payload) ~= 'table' then
    drawn = nil
    held = nil
    reported = 0

    return publishCurrentWeapon()
  end

  local ped <const> = PlayerPedId()
  local hash <const> = GetHashKey(payload.name)

  if not IsWeaponValid(hash) then
    drawn = nil
    held = nil

    return publishCurrentWeapon()
  end

  local components <const> = payload.components or {}
  local ammo <const> = payload.takesAmmo and math.max(0, payload.ammo or 0) or 1

  Siku.RequestWeaponAsset(hash)
  GiveWeaponToPed(ped, hash, ammo, false, true)
  fitComponents(ped, hash, components)

  local key <const> = magazineKey(payload.name, components)

  magazines[key] = magazines[key] or measureMagazine(ped, hash)

  SetPedAmmo(ped, hash, ammo)
  SetAmmoInClip(ped, hash, ammo)
  SetCurrentPedWeapon(ped, hash, true)

  held = payload

  drawn = {
    uid = payload.uid,
    item = payload.item,
    name = payload.name,
    hash = hash,
    slot = payload.slot,
    components = components,
    metadata = payload.metadata,
    magazine = magazines[key],
    takesAmmo = payload.takesAmmo == true,
  }

  reported = ammo

  publishCurrentWeapon()
end

--- Writes a fresh count into the weapon in hand, after a load.
---@param uid string The instance that was loaded.
---@param ammo number The rounds it now holds.
---@return nil
function ApplyLoadedAmmo(uid, ammo)
  if not drawn or drawn.uid ~= uid then
    return
  end

  local ped <const> = PlayerPedId()

  SetPedAmmo(ped, drawn.hash, ammo)
  SetAmmoInClip(ped, drawn.hash, ammo)

  reported = ammo

  publishCurrentWeapon()
end

--- Tells the server what the ped has left, whenever it went down.
---
--- Only ever downwards: the server refuses anything else, and this side has no
--- business claiming a weapon gained rounds. Reported on a beat rather than on
--- every shot, because a burst is a dozen shots and a dozen events.
---@return nil
local function reportSpent()
  if not drawn or not drawn.takesAmmo then
    return
  end

  local left <const> = GetAmmoInPedWeapon(PlayerPedId(), drawn.hash)

  if type(left) ~= 'number' or left >= reported then
    return
  end

  reported = left

  TriggerServerEvent('siku_inventory:server:reportAmmo', { uid = drawn.uid, ammo = left })
  publishCurrentWeapon()
end

Siku.SetInterval(REPORT_INTERVAL, reportSpent)

Siku.SetInterval(GUARD_INTERVAL, function()
  local ped <const> = PlayerPedId()
  local current <const> = GetSelectedPedWeapon(ped)

  if drawn then
    if current ~= drawn.hash and current ~= UNARMED then
      SetCurrentPedWeapon(ped, drawn.hash, true)
    end

    return
  end

  if current ~= UNARMED then
    clearHands()
  end
end)

RegisterNetEvent('siku_inventory:client:setDrawnWeapon', SetDrawnWeapon)

RegisterNetEvent('siku_inventory:client:weaponLoaded', function(payload)
  if type(payload) == 'table' then
    ApplyLoadedAmmo(payload.uid, payload.ammo)
  end
end)

AddEventHandler('onResourceStop', function(resource)
  if resource == GetCurrentResourceName() then
    clearHands()
  end
end)

local session = nil

--- Finds which of an item's declared game components a weapon takes.
---
--- The same part exists once per weapon family, so a suppressor lists several
--- names and only one of them fits any given model. Asking the engine is what
--- removes the need for a compatibility table nobody could keep correct — and
--- it only needs the weapon's hash, so nothing has to be spawned to ask.
---@param weaponHash number The weapon hash.
---@param item string The component identifier.
---@return boolean accepted Whether the engine takes it.
local function acceptsComponent(weaponHash, item)
  local variants <const> = GetComponentVariants(item)

  for i = 1, #variants do
    if DoesWeaponTakeWeaponComponent(weaponHash, GetHashKey(variants[i])) then
      return true
    end
  end

  return false
end

--- Sends the current state to the interface.
---@return nil
local function publish()
  SendNUIMessage({
    action = 'siku_inventory:nui:setCustomization',
    customization = session,
  })
end

--- Opens the panel on the payload the server built.
---
--- The carried components are filtered here rather than on the server: only
--- the client can ask the game what a model accepts, and a part it refuses
--- has no business being offered.
---@param payload table The customization payload.
---@return nil
function OpenCustomization(payload)
  if type(payload) ~= 'table' or type(payload.weapon) ~= 'table' then
    return
  end

  local weapon <const> = payload.weapon
  local weaponHash <const> = GetHashKey(weapon.name)

  if not IsWeaponValid(weaponHash) then
    return TriggerEvent('siku_inventory:client:actionRefused', 'unknown_weapon')
  end

  local available <const> = {}

  for i = 1, #payload.available do
    local entry <const> = payload.available[i]

    if acceptsComponent(weaponHash, entry.item) then
      available[#available + 1] = entry
    end
  end

  session = {
    weapon = weapon,
    slots = payload.slots,
    available = available,
    components = weapon.components or {},
  }

  publish()
end

--- Fits a component in a slot, replacing whatever was there.
---@param slot string The attachment slot.
---@param item string The component identifier.
---@return nil
function FitComponent(slot, item)
  if not session or not IsKnownWeaponSlot(slot) or GetComponentSlot(item) ~= slot then
    return
  end

  for i = 1, #session.available do
    if session.available[i].item == item then
      session.components[slot] = item
      publish()

      return
    end
  end
end

--- Takes whatever sits in a slot back off.
---@param slot string The attachment slot.
---@return nil
function ClearComponent(slot)
  if not session or not IsKnownWeaponSlot(slot) then
    return
  end

  session.components[slot] = nil
  publish()
end

--- Closes the panel. The state is handed to the server when asked to save;
--- the panel closes either way, because a player must never be trapped in it
--- by a refused commit.
---@param save boolean Whether the state should be committed.
---@return nil
function CloseCustomization(save)
  if not session then
    return
  end

  local current <const> = session

  session = nil

  SendNUIMessage({ action = 'siku_inventory:nui:setCustomization', customization = false })

  if save then
    TriggerServerEvent('siku_inventory:server:commitCustomization', {
      uid = current.weapon.uid,
      components = current.components,
    })
  end
end

RegisterNetEvent('siku_inventory:client:openCustomization', OpenCustomization)

AddEventHandler('onResourceStop', function(resource)
  if resource == GetCurrentResourceName() then
    session = nil
  end
end)

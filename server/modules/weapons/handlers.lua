--- Answers a refused request without saying more than a key.
---@param sessionId number The player server id.
---@param reason string The refusal key.
---@return nil
local function refuse(sessionId, reason)
  TriggerClientEvent('siku_inventory:client:actionRefused', sessionId, reason)
end

RegisterNetEvent('siku_inventory:server:openCustomization', function(payload)
  local sessionId <const> = source

  if not PassesActionCooldown(sessionId) or type(payload) ~= 'table' then
    return
  end

  local view <const>, reason <const> = BuildCustomizationPayload(sessionId, payload.uid)

  if not view then
    return refuse(sessionId, reason or 'refused')
  end

  TriggerClientEvent('siku_inventory:client:openCustomization', sessionId, view)
end)

RegisterNetEvent('siku_inventory:server:commitCustomization', function(payload)
  local sessionId <const> = source

  if not PassesActionCooldown(sessionId) or type(payload) ~= 'table' then
    return
  end

  local inventory <const> = GetSessionInventory(sessionId)
  local committed <const>, reason <const> =
    CommitCustomization(sessionId, payload.uid, payload.components)

  if committed then
    SaveInventory(inventory)
  else
    refuse(sessionId, reason or 'refused')
  end

  PushInventoryState(sessionId)
end)

--- Draws or puts away the weapon on a hotbar key.
---
--- Reached from the key itself and from the use action alike: both mean the
--- same thing, and neither spends anything. A weapon comes out of the bag
--- without leaving it.
---@param sessionId number The player server id.
---@param slot number The hotbar slot number.
---@return nil
function ToggleWeaponFromSlot(sessionId, slot)
  local drawn <const>, reason <const> = ToggleDrawnWeapon(sessionId, slot)

  if drawn == nil then
    return refuse(sessionId, reason or 'refused')
  end

  if drawn == false then
    SaveInventory(GetSessionInventory(sessionId))
  end

  TriggerClientEvent('siku_inventory:client:setDrawnWeapon', sessionId, drawn)
end

--- Offers the weapons a kind of ammunition could go into.
---@param sessionId number The player server id.
---@param ammoItem string The ammunition item identifier.
---@return nil
function OfferReloadTargets(sessionId, ammoItem)
  local payload <const>, reason <const> = BuildReloadTargets(sessionId, ammoItem)

  if not payload then
    return refuse(sessionId, reason or 'refused')
  end

  TriggerClientEvent('siku_inventory:client:openReload', sessionId, payload)
end

RegisterNetEvent('siku_inventory:server:reportAmmo', function(payload)
  local sessionId <const> = source

  if type(payload) ~= 'table' then
    return
  end

  if GetSessionDrawnWeapon(sessionId) ~= payload.uid then
    return
  end

  RecordSpentAmmo(sessionId, payload.uid, payload.ammo)
end)

RegisterNetEvent('siku_inventory:server:reload', function(payload)
  local sessionId <const> = source

  if not PassesActionCooldown(sessionId) or type(payload) ~= 'table' then
    return
  end

  local loaded <const>, reason <const> = ReloadWeapon(sessionId, payload.uid, payload.magazine)

  if not loaded then
    return refuse(sessionId, reason or 'refused')
  end

  SaveInventory(GetSessionInventory(sessionId))
  TriggerClientEvent('siku_inventory:client:weaponLoaded', sessionId, loaded)
  PushInventoryState(sessionId)
end)

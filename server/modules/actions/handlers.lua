--- Answers a refused action without leaking why it was refused beyond a key
--- the interface can translate.
---@param sessionId number The player server id.
---@param reason string The refusal key.
---@return nil
local function refuse(sessionId, reason)
  TriggerClientEvent('siku_inventory:client:actionRefused', sessionId, reason)
end

--- Pushes the fresh state of everything a session can currently see.
---@param sessionId number The player server id.
---@return nil
local function pushState(sessionId)
  local inventory <const> = GetSessionInventory(sessionId)

  if not inventory then
    return
  end

  local coords <const> = GetSessionCoords(sessionId)
  local ground <const> = coords and BuildGroundPayload(coords) or {}
  local container <const> = GetSessionContainer(sessionId)

  RecordGroundSent(sessionId, ground)

  TriggerClientEvent('siku_inventory:client:setState', sessionId, {
    inventory = inventory:toPayload(),
    ground = ground,
    container = container and BuildContainerPayload(container) or nil,
  })
end

PushInventoryState = pushState

--- Whether a slot still holds the very instance a use started on.
---@param inventory table The character inventory.
---@param slot number The slot the use named.
---@param started table The stack the use started on.
---@return table? stack The stack, or nil when it is no longer the same one.
local function stillHolds(inventory, slot, started)
  local stack <const> = inventory:getStack(slot)

  if not stack or stack.item ~= started.item or stack.uid ~= started.uid then
    return nil
  end

  if not IsItemUsable(stack.item) or IsStackSpoiled(stack) then
    return nil
  end

  return stack
end

--- Hands an item over to whoever owns its behaviour, and settles the screen.
---@param sessionId number The player server id.
---@param inventory table The character inventory.
---@param slot number The slot holding the item.
---@param stack table The stack being used.
---@return nil
local function completeUse(sessionId, inventory, slot, stack)
  RunItemUse(sessionId, inventory, slot, stack)
  SaveInventory(inventory)
  pushState(sessionId)

  if ClosesOnUse(stack.item) then
    TriggerClientEvent('siku_inventory:client:close', sessionId)
  end
end

--- Runs a use that occupies the character, and only lets it happen if the
--- character stayed with it to the end.
---
--- The bar is driven from here rather than from the client, so skipping it is
--- not something a client can decide. Everything is checked again when it
--- ends: three seconds are long enough to drop the item, hand it over, or let
--- it spoil.
---@param sessionId number The player server id.
---@param slot number The slot holding the item.
---@param stack table The stack being used.
---@param useTime number How long the character is occupied, in milliseconds.
---@return nil
local function runTimedUse(sessionId, slot, stack, useTime)
  TriggerClientEvent('siku_inventory:client:close', sessionId)

  local started <const> = Siku.ProgressBar(sessionId, {
    label = T('use_progress', GetItemDefinitionPayload(stack.item).label),
    duration = useTime,
  }, function(result)
    if result ~= 'done' then
      return
    end

    local inventory <const> = GetSessionInventory(sessionId)
    local current <const> = inventory and stillHolds(inventory, slot, stack) or nil

    if not current then
      return refuse(sessionId, 'empty_slot')
    end

    completeUse(sessionId, inventory, slot, current)
  end)

  if not started then
    local inventory <const> = GetSessionInventory(sessionId)

    if inventory then
      completeUse(sessionId, inventory, slot, stack)
    end
  end
end

RegisterNetEvent('siku_inventory:server:openScreen', function()
  local sessionId <const> = source

  if not PassesStateCooldown(sessionId) then
    return
  end

  WatchGround(sessionId)
  pushState(sessionId)
end)

RegisterNetEvent('siku_inventory:server:closeScreen', function()
  local sessionId <const> = source

  UnwatchGround(sessionId)
  CloseSessionContainer(sessionId)
end)

RegisterNetEvent('siku_inventory:server:openContainer', function(payload)
  local sessionId <const> = source

  if not PassesStateCooldown(sessionId) or type(payload) ~= 'table' then
    return
  end

  local opened <const>, reason <const> = OpenContainer(sessionId, payload.kind, payload.request)

  if not opened then
    refuse(sessionId, reason or 'refused')
  end
end)

RegisterNetEvent('siku_inventory:server:move', function(payload)
  local sessionId <const> = source

  if not PassesActionCooldown(sessionId) or type(payload) ~= 'table' then
    return
  end

  local inventory <const> = GetSessionInventory(sessionId)

  if not inventory then
    return refuse(sessionId, 'no_character')
  end

  local from <const> = payload.from
  local to <const> = payload.to

  if type(from) ~= 'table' or type(to) ~= 'table' then
    return refuse(sessionId, 'invalid_request')
  end

  local count <const> = ReadCount(payload.count)

  if not count then
    return refuse(sessionId, 'invalid_quantity')
  end

  local coords <const> = GetSessionCoords(sessionId)

  if not coords then
    return refuse(sessionId, 'invalid_request')
  end

  if from.container == 'secondary' or to.container == 'secondary' then
    if IsSessionContainerReadOnly(sessionId) then
      return refuse(sessionId, 'not_allowed')
    end
  end

  local sourceInventory, sourceSlot = ResolveContainerSlot(from, inventory, coords, sessionId)

  if not sourceInventory or not sourceSlot then
    return refuse(sessionId, 'unreachable')
  end

  if IsLooseGroundReference(to) then
    return DropFromSlot(sessionId, sourceInventory, sourceSlot, count, coords)
  end

  local targetInventory, targetSlot = ResolveContainerSlot(to, inventory, coords, sessionId)

  if not targetInventory then
    return refuse(sessionId, 'unreachable')
  end

  if to.container == 'secondary' and not AcceptsIntoOpenContainer(sessionId, sourceInventory, sourceSlot) then
    return refuse(sessionId, 'not_allowed')
  end

  local moved, reason = WithInventoryLock({ sourceInventory.id, targetInventory.id }, function()
    if targetSlot and IsHotbarSlotNumber(targetSlot) then
      if sourceInventory ~= inventory then
        return false, 'invalid_request'
      end

      return PlaceIntoHotbar(inventory, sourceSlot, targetSlot, count)
    end

    return TransferBetweenSlots(sourceInventory, sourceSlot, targetInventory, targetSlot, count)
  end)

  if moved then
    SaveInventory(sourceInventory)
    SaveInventory(targetInventory)
    DiscardDropIfEmpty(sourceInventory)
    DiscardDropIfEmpty(targetInventory)
  else
    refuse(sessionId, reason or 'refused')
  end

  pushState(sessionId)

  if not moved then
    return
  end

  if sourceInventory:isGround() or targetInventory:isGround() then
    NotifyDropsChanged(sessionId)
  end

  if sourceInventory ~= inventory then
    NotifyContainerChanged(sourceInventory.id, sessionId)
  end

  if targetInventory ~= inventory and targetInventory ~= sourceInventory then
    NotifyContainerChanged(targetInventory.id, sessionId)
  end

  if from.container == 'secondary' or to.container == 'secondary' then
    RefreshOpenContainerWeight(sessionId)
  end
end)

RegisterNetEvent('siku_inventory:server:split', function(payload)
  local sessionId <const> = source

  if not PassesActionCooldown(sessionId) or type(payload) ~= 'table' then
    return
  end

  local inventory <const> = GetSessionInventory(sessionId)

  if not inventory then
    return refuse(sessionId, 'no_character')
  end

  local slot <const> = ReadSlot(payload.slot)
  local count <const> = ReadCount(payload.count)

  if not slot or not count or not inventory:isValidSlot(slot) then
    return refuse(sessionId, 'invalid_request')
  end

  local ok, reason = WithInventoryLock({ inventory.id }, function()
    return SplitStack(inventory, slot, count)
  end)

  if ok then
    SaveInventory(inventory)
  else
    refuse(sessionId, reason or 'refused')
  end

  pushState(sessionId)
end)

--- Uses whatever sits in a slot, whoever asked.
---
--- The one path a use ever takes: a hotbar key, the context menu and another
--- resource all end up here, so none of them can skip a check the others
--- answer to.
---@param sessionId number The player server id.
---@param slot any The slot to use.
---@return boolean used, string? reason Whether the use was accepted, and why it was not.
function PerformItemUse(sessionId, slot)
  local inventory <const> = GetSessionInventory(sessionId)

  if not inventory then
    return false, 'no_character'
  end

  local wanted <const> = ReadSlot(slot)

  if not wanted or not inventory:isValidSlot(wanted) then
    return false, 'invalid_request'
  end

  local stack <const> = inventory:getStack(wanted)

  if not stack then
    return false, 'empty_slot'
  end

  if not IsItemUsable(stack.item) then
    return false, 'not_usable'
  end

  if IsStackSpoiled(stack) then
    return false, 'spoiled'
  end

  if IsWeaponItem(stack.item) then
    ToggleWeaponFromSlot(sessionId, wanted)

    return true
  end

  if IsAmmoItem(stack.item) then
    OfferReloadTargets(sessionId, stack.item)

    return true
  end

  if IsContainerItem(stack.item) then
    return OpenItemContainer(sessionId, stack.uid)
  end

  if not AllowsItemUse(sessionId, wanted, stack) then
    return false, 'not_usable'
  end

  local useTime <const> = GetItemUseTime(stack.item)

  if useTime then
    runTimedUse(sessionId, wanted, stack, useTime)

    return true
  end

  completeUse(sessionId, inventory, wanted, stack)

  return true
end

RegisterNetEvent('siku_inventory:server:use', function(payload)
  local sessionId <const> = source

  if not PassesActionCooldown(sessionId) or type(payload) ~= 'table' then
    return
  end

  local used <const>, reason <const> = PerformItemUse(sessionId, payload.slot)

  if not used then
    refuse(sessionId, reason or 'refused')
  end
end)

RegisterNetEvent('siku_inventory:server:give', function(payload)
  local sessionId <const> = source

  if not PassesActionCooldown(sessionId) or type(payload) ~= 'table' then
    return
  end

  local slot <const> = ReadSlot(payload.slot)
  local targetId <const> = ReadSlot(payload.target)
  local count <const> = payload.count ~= nil and ReadCount(payload.count) or nil

  if not slot or not targetId then
    return refuse(sessionId, 'invalid_request')
  end

  if payload.count ~= nil and not count then
    return refuse(sessionId, 'invalid_quantity')
  end

  GiveToSession(sessionId, targetId, slot, count)
  pushState(sessionId)
end)

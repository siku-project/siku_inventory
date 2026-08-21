local GUARD_INTERVAL <const> = 1500

local kinds <const> = {}
local opened <const> = {}
local viewers <const> = {}

--- Declares a family of secondary containers.
---
--- A stash is one family; a trunk, a shop reserve and a body search will be
--- others. What every family owes the interface is the same: an inventory to
--- show, and an answer to whether the character may still be looking at it a
--- second from now.
---@param kind string The family name.
---@param behaviour table `resolve` returns the inventory, `validate` says whether the view may stay open.
---@return boolean registered Whether the family was accepted.
function RegisterContainerKind(kind, behaviour)
  if type(kind) ~= 'string' or kind == '' or type(behaviour) ~= 'table' then
    return false
  end

  if not _SikuInternal.IsCallable(behaviour.resolve) then
    return false
  end

  if behaviour.validate ~= nil and not _SikuInternal.IsCallable(behaviour.validate) then
    return false
  end

  kinds[kind] = {
    resolve = behaviour.resolve,
    validate = behaviour.validate,
  }

  return true
end

--- Takes note that a session is looking at a container.
---@param sessionId number The player server id.
---@param descriptor table The container being watched.
---@return nil
local function watch(sessionId, descriptor)
  opened[sessionId] = descriptor

  local seats <const> = viewers[descriptor.inventoryId] or {}

  seats[sessionId] = true
  viewers[descriptor.inventoryId] = seats
end

--- Takes note that a session stopped looking.
---@param sessionId number The player server id.
---@return table? descriptor What the session was looking at.
local function unwatch(sessionId)
  local descriptor <const> = opened[sessionId]

  if not descriptor then
    return nil
  end

  opened[sessionId] = nil

  local seats <const> = viewers[descriptor.inventoryId]

  if seats then
    seats[sessionId] = nil

    if next(seats) == nil then
      viewers[descriptor.inventoryId] = nil
    end
  end

  return descriptor
end

--- What a session is looking at, when it is looking at anything.
---@param sessionId number The player server id.
---@return table? descriptor The open container.
function GetSessionContainer(sessionId)
  return opened[sessionId]
end

--- The inventory behind what a session is looking at.
---@param sessionId number The player server id.
---@return table? inventory The container inventory.
function GetSessionContainerInventory(sessionId)
  local descriptor <const> = opened[sessionId]

  return descriptor and GetInventoryById(descriptor.inventoryId) or nil
end

--- Whether what a session is looking at may only be looked at.
---
--- Searching somebody shows what they are carrying and stops there. The
--- interface is told so it does not offer a gesture that would be refused, and
--- the answer is asked again where the gesture would land, because what a
--- screen offers is never what decides.
---@param sessionId number The player server id.
---@return boolean readOnly Whether nothing may move in or out.
function IsSessionContainerReadOnly(sessionId)
  local descriptor <const> = opened[sessionId]

  return descriptor ~= nil and descriptor.readOnly == true
end

--- Builds what the interface reads of a container. The row identifier never
--- leaves the server: a client names the container it is looking at, never
--- one it could have guessed.
---@param descriptor table The open container.
---@return table? payload The container as the interface reads it.
function BuildContainerPayload(descriptor)
  local inventory <const> = descriptor and GetInventoryById(descriptor.inventoryId) or nil

  if not inventory then
    return nil
  end

  local stacks <const> = {}

  for slot, stack in pairs(inventory.stacks) do
    stacks[tostring(slot)] = BuildStackPayload(stack, slot)
  end

  return {
    kind = descriptor.kind,
    id = descriptor.id,
    label = descriptor.label,
    icon = descriptor.icon,
    readOnly = descriptor.readOnly == true,
    slots = inventory.slots,
    maxWeight = inventory.maxWeight,
    weight = inventory:getWeight(),
    stacks = stacks,
  }
end

--- Tells everyone else looking at a container that its content moved.
---
--- Two players standing at the same locker are looking at one inventory, and
--- what one of them takes has to leave the other's screen at that moment
--- rather than the next time they open it.
---@param inventoryId number The container inventory identifier.
---@param except? number A session that was already told, usually the actor.
---@return nil
function NotifyContainerChanged(inventoryId, except)
  local seats <const> = viewers[inventoryId]

  if not seats then
    return
  end

  for sessionId in pairs(seats) do
    if sessionId ~= except then
      PushInventoryState(sessionId)
    end
  end
end

--- Closes whatever a session had open, telling it why when it did not ask.
---@param sessionId number The player server id.
---@param reason? string The refusal key to show.
---@return nil
function CloseSessionContainer(sessionId, reason)
  local descriptor <const> = unwatch(sessionId)

  if not descriptor then
    return
  end

  TriggerClientEvent('siku_inventory:client:setContainer', sessionId, nil)

  if reason then
    TriggerClientEvent('siku_inventory:client:actionRefused', sessionId, reason)
  end
end

--- Closes every view of one named container, whichever inventory each of them
--- ended up on. A personal container resolves to one inventory per character,
--- so the one that is going away is rarely the only one being watched.
---@param kind string The family name.
---@param id string The container identifier within its family.
---@param reason? string The refusal key to show.
---@return nil
function CloseContainersOf(kind, id, reason)
  local watchers <const> = {}

  for sessionId, descriptor in pairs(opened) do
    if descriptor.kind == kind and descriptor.id == id then
      watchers[#watchers + 1] = sessionId
    end
  end

  for i = 1, #watchers do
    CloseSessionContainer(watchers[i], reason)
    PushInventoryState(watchers[i])
  end
end

--- Opens a container for a session, replacing whatever it had open.
---
--- The family is asked to resolve it every single time rather than the caller
--- handing an inventory over: that is what keeps the access rules in one
--- place, whether the request came from a key, from an export or from a
--- player who walked back into range.
---@param sessionId number The player server id.
---@param kind string The family name.
---@param request table What the family needs to find the container.
---@return boolean opened, string? reason Whether the container opened, and why it did not.
function OpenSessionContainer(sessionId, kind, request)
  local family <const> = kinds[kind]

  if not family then
    return false, 'invalid_request'
  end

  local descriptor <const>, reason <const> = family.resolve(sessionId, request)

  if not descriptor then
    return false, reason or 'refused'
  end

  descriptor.kind = kind

  if opened[sessionId] then
    unwatch(sessionId)
  end

  watch(sessionId, descriptor)

  TriggerClientEvent('siku_inventory:client:openContainer', sessionId)
  PushInventoryState(sessionId)

  return true
end

--- Whether a session may still be looking at what it opened.
---@param sessionId number The player server id.
---@param descriptor table The open container.
---@return boolean allowed, string? reason Whether the view may stay, and why it may not.
local function stillAllowed(sessionId, descriptor)
  local family <const> = kinds[descriptor.kind]

  if not family then
    return false, 'invalid_request'
  end

  if not GetInventoryById(descriptor.inventoryId) then
    return false, 'unreachable'
  end

  if not family.validate then
    return true
  end

  return family.validate(sessionId, descriptor)
end

Siku.SetInterval(GUARD_INTERVAL, function()
  for sessionId, descriptor in pairs(opened) do
    local allowed <const>, reason <const> = stillAllowed(sessionId, descriptor)

    if not allowed then
      CloseSessionContainer(sessionId, reason or 'unreachable')
      PushInventoryState(sessionId)
    end
  end
end)

--- Opens a container on somebody's screen, whatever family it belongs to.
---
--- One door for every kind rather than one export per kind: a family declares
--- itself with RegisterContainerKind and is reachable the same day, without a
--- new name to learn or a new function that would only pass a constant along.
--- What each family needs to find its container is what goes in `request`.
---
---     OpenContainer(src, 'stash',   { name = 'policelocker', owner = 77 })
---     OpenContainer(src, 'item',    { uid = box.uid })
---     OpenContainer(src, 'inspect', { target = 12 })
---
--- Nothing is trusted from the caller: the family is asked to resolve it, and
--- every rule it names — jobs, distance, instance, whoever is holding what —
--- is checked here and again while the view stays up.
---@param sessionId number The player server id.
---@param kind string The family name.
---@param request? table What that family needs to find the container.
---@return boolean opened, string? reason Whether it opened, and why it did not.
function OpenContainer(sessionId, kind, request)
  if type(sessionId) ~= 'number' or type(kind) ~= 'string' then
    return false, 'invalid_request'
  end

  return OpenSessionContainer(sessionId, kind, request or {})
end

exports('OpenContainer', OpenContainer)

--- Closes whatever somebody has open beside their bag.
---@param sessionId number The player server id.
---@return boolean closed Whether anything was open.
function CloseContainer(sessionId)
  if type(sessionId) ~= 'number' or not GetSessionContainer(sessionId) then
    return false
  end

  CloseSessionContainer(sessionId)
  PushInventoryState(sessionId)

  return true
end

exports('CloseContainer', CloseContainer)

AddEventHandler('playerDropped', function()
  unwatch(source)
end)

local ICON <const> = 'mdi-package-variant-closed'

--- Finds the instance a session is holding, wherever it sits in their bag.
---@param sessionId number The player server id.
---@param uid any The instance identifier.
---@return table? inventory, number? slot The bag holding it, and where.
local function findHeld(sessionId, uid)
  local inventory <const> = GetSessionInventory(sessionId)

  if not inventory or type(uid) ~= 'string' then
    return nil, nil
  end

  local slot <const> = inventory:findByUid(uid)

  return slot and inventory or nil, slot
end

--- Reads the inventory inside an instance, opening it on first use.
---
--- It is keyed by the instance rather than by the kind, which is what makes
--- one box different from the next. The key travels with the instance: hand
--- the box over, drop it, lock it in a stash, and what is inside goes with it
--- without anything being moved.
---@param stack table The container instance.
---@return table? inventory The inventory inside it.
function GetItemContainerInventory(stack)
  local properties <const> = GetContainerProperties(stack.item)

  if not properties or type(stack.uid) ~= 'string' then
    return nil
  end

  return GetKeyedInventory('container', stack.uid, properties.slots, properties.maxWeight)
end

--- Writes what a container is holding onto the instance that carries it.
---
--- Without this a bag never gets heavier however much is stuffed into the box
--- inside it. The number is written where the instance lives, so the character
--- carrying it feels the weight straight away.
---@param sessionId number The player server id.
---@param uid string The container instance.
---@return nil
function RecordContainerWeight(sessionId, uid)
  local inventory <const>, slot <const> = findHeld(sessionId, uid)

  if not inventory or not slot then
    return
  end

  local stack <const> = inventory:getStack(slot)
  local contents <const> = GetItemContainerInventory(stack)

  if not contents then
    return
  end

  SetContainedWeight(stack, contents:getWeight())
  inventory:touch()
  SaveInventory(inventory)
end

--- Writes the weight of whatever box a session has open, when it is a box.
---@param sessionId number The player server id.
---@return nil
function RefreshOpenContainerWeight(sessionId)
  local descriptor <const> = GetSessionContainer(sessionId)

  if descriptor and descriptor.kind == 'item' then
    RecordContainerWeight(sessionId, descriptor.id)
    PushInventoryState(sessionId)
  end
end

--- Whether something may go into the container a session has open.
---
--- Only a container made out of an item has anything to say here: a stash
--- takes whatever fits. What a box takes is what it was declared to take, and
--- never another box.
---@param sessionId number The player server id.
---@param source table The inventory the stack is leaving.
---@param slot number The slot it is leaving.
---@return boolean allowed Whether it may go in.
function AcceptsIntoOpenContainer(sessionId, source, slot)
  local descriptor <const> = GetSessionContainer(sessionId)

  if not descriptor or descriptor.kind ~= 'item' then
    return true
  end

  local stack <const> = source and source:getStack(slot) or nil

  return stack ~= nil and AcceptsInContainer(descriptor.item, stack.item)
end

--- Finds the container behind an open request.
---@param sessionId number The player server id.
---@param request table What was asked for: the instance to open.
---@return table? descriptor, string? reason The container to show, and why the request was refused otherwise.
local function resolveItem(sessionId, request)
  if type(request) ~= 'table' then
    return nil, 'invalid_request'
  end

  local inventory <const>, slot <const> = findHeld(sessionId, request.uid)

  if not inventory or not slot then
    return nil, 'unreachable'
  end

  local stack <const> = inventory:getStack(slot)

  if not IsContainerItem(stack.item) then
    return nil, 'not_a_container'
  end

  local contents <const> = GetItemContainerInventory(stack)

  if not contents then
    return nil, 'refused'
  end

  return {
    id = stack.uid,
    label = GetItemDefinitionPayload(stack.item).label,
    icon = ICON,
    item = stack.item,
    inventoryId = contents.id,
  }
end

--- Whether a container may stay open: only while it is still being carried.
--- Handing the box to somebody else closes it on whoever was looking inside.
---@param sessionId number The player server id.
---@param descriptor table The open container.
---@return boolean allowed, string? reason Whether the view may stay, and why it may not.
local function validateItem(sessionId, descriptor)
  local inventory <const>, slot <const> = findHeld(sessionId, descriptor.id)

  if not inventory or not slot then
    return false, 'unreachable'
  end

  return IsContainerItem(inventory:getStack(slot).item), 'not_a_container'
end

RegisterContainerKind('item', {
  resolve = resolveItem,
  validate = validateItem,
})

--- Opens what an instance is carrying inside it.
---
--- The instance is named rather than a slot, because a box is the same box
--- wherever it has been moved to since. It has to be in the hands of whoever
--- is opening it: a box in somebody else's bag is not one you can look into.
---@param sessionId number The player server id.
---@param uid string The container instance.
---@return boolean opened, string? reason Whether it opened, and why it did not.
function OpenItemContainer(sessionId, uid)
  if type(sessionId) ~= 'number' then
    return false, 'invalid_request'
  end

  return OpenSessionContainer(sessionId, 'item', { uid = uid })
end

exports('RegisterContainer', RegisterContainer)
exports('UnregisterContainer', UnregisterContainer)

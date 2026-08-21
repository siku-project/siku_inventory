--- Walks everything the character is carrying, in slot order.
---
--- The hotbar is walked with the rest: a key holds a stack like any other, and
--- what comes back is the real slot number rather than the rank, so a slot
--- this hands over can be given, used or moved without translating anything.
---@param visit function Called with each slot number and the stack sitting in it.
---@return boolean read Whether there was an inventory to walk at all.
local function eachCarriedStack(visit)
  local inventory <const> = GetInventoryState().inventory

  if type(inventory) ~= 'table' then
    return false
  end

  local found <const> = {}

  for key, stack in pairs(inventory.stacks or {}) do
    local slot <const> = tonumber(key)

    if slot and type(stack) == 'table' then
      found[#found + 1] = { slot = slot, stack = stack }
    end
  end

  for index, stack in pairs(inventory.hotbar or {}) do
    local rank <const> = tonumber(index)

    if rank and type(stack) == 'table' then
      found[#found + 1] = { slot = GetHotbarSlotNumber(rank), stack = stack }
    end
  end

  table.sort(found, function(a, b)
    return a.slot < b.slot
  end)

  for i = 1, #found do
    visit(found[i].slot, found[i].stack)
  end

  return true
end

--- Reads one stack the way every read on this side answers with.
---
--- A copy, so rewriting it changes nothing: the next state the server pushes
--- would overwrite it anyway.
---@param slot number The slot it sits in.
---@param stack table The stack.
---@return table instance The instance as a caller reads it.
local function describe(slot, stack)
  local instance <const> = Siku.table.deepClone(stack)

  instance.slot = slot

  return instance
end

--- How many slots the character is not using.
---@param inventory table The carried inventory.
---@return number free The free slot count.
local function freeSlotsOf(inventory)
  local used = 0

  for _ in pairs(inventory.stacks or {}) do
    used = used + 1
  end

  return math.max(0, (inventory.slots or 0) - used)
end

--- Everything the character is carrying, and what the bag holding it is.
---
--- The same question the server answers for any container, asked of the one
--- this player is walking around with. The fields carry the same names, so a
--- script reading a bag on one side and a stash on the other reads the same
--- shape twice.
---@return table? inventory What the bag is and what it holds.
function GetInventory()
  local inventory <const> = GetInventoryState().inventory

  if type(inventory) ~= 'table' then
    return nil
  end

  local items <const> = {}

  eachCarriedStack(function(slot, stack)
    items[#items + 1] = describe(slot, stack)
  end)

  return {
    type = inventory.ownerType or 'character',
    slots = inventory.slots or 0,
    maxWeight = inventory.maxWeight or InventoryConfig.maxWeight,
    weight = inventory.weight or 0,
    freeSlots = freeSlotsOf(inventory),
    items = items,
  }
end

exports('GetInventory', GetInventory)

--- Where an item sits, how much of it there is, and what room is left over.
---
--- The server answers the same question under the same name for any container.
--- The slots come back in order, each carrying its own instance, so one of
--- them can be handed straight to UseSlot or GiveItemToTarget.
---@param item string The item identifier.
---@param metadata? table The properties an instance must carry to be counted.
---@param strict? boolean Whether the whole metadata must be identical.
---@return table answer `slots` holding it, the total `count`, and `freeSlots` left.
function GetItemSlots(item, metadata, strict)
  local inventory <const> = GetInventoryState().inventory
  local empty <const> = { slots = {}, count = 0, freeSlots = 0 }

  if type(inventory) ~= 'table' or type(item) ~= 'string' or item == '' then
    return empty
  end

  if metadata ~= nil and type(metadata) ~= 'table' then
    return empty
  end

  local slots <const> = {}
  local count = 0

  eachCarriedStack(function(slot, stack)
    if stack.item == item and MetadataMatches(stack.metadata, metadata, strict) then
      count = count + (stack.count or 0)
      slots[#slots + 1] = describe(slot, stack)
    end
  end)

  return { slots = slots, count = count, freeSlots = freeSlotsOf(inventory) }
end

exports('GetItemSlots', GetItemSlots)

--- How much of an item the character is carrying, hotbar included.
---
--- A count is always a number: an item nobody has and a question that made no
--- sense both answer zero, because there is no third thing a count can be.
---@param item string The item identifier.
---@param metadata? table The properties an instance must carry to be counted.
---@param strict? boolean Whether the whole metadata must be identical.
---@return number count The quantity held.
function GetItemCount(item, metadata, strict)
  return GetItemSlots(item, metadata, strict).count
end

exports('GetItemCount', GetItemCount)

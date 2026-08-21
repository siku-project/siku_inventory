local HOLDING <const> = 'confiscated'

--- Declares the container a confiscation is kept in, once.
---
--- It is a stash like any other, which is what makes everything already
--- written work on it: it can be read, counted, added to and opened by a
--- script naming it. What it has not got is coords, so nobody opens it by
--- walking up to anything.
---
--- Declared on first use rather than at load, because the stash registry is
--- read later than this file is.
---@return table? definition The holding definition.
local function holdingDefinition()
  local declared <const> = GetStashDefinition(HOLDING)

  if declared then
    return declared
  end

  return RegisterStashDefinition({
    name = HOLDING,
    label = T('confiscated_label'),
    slots = InventoryConfig.slots + HOTBAR_SLOTS,
    maxWeight = 0,
    owner = true,
  })
end

--- The container holding what was taken from a character.
---@param characterId number The character id.
---@return table? inventory The holding inventory.
local function holdingFor(characterId)
  local definition <const> = holdingDefinition()

  return definition and GetStashInventory(definition, tostring(characterId)) or nil
end

--- Moves everything out of one container and into another.
---
--- Whatever the destination could not take goes straight back where it came
--- from. A confiscation that half happened would be worse than one that did
--- not: the point of taking someone's things is being able to give them back.
---@param from table The container being emptied.
---@param to table The container being filled.
---@return number moved The quantity that changed hands.
local function transferAll(from, to)
  local slots <const> = {}

  for slot in pairs(from.stacks) do
    slots[#slots + 1] = slot
  end

  table.sort(slots)

  local moved = 0

  for i = 1, #slots do
    local taken <const> = from:takeFromSlot(slots[i], math.maxinteger)

    if taken then
      local placed <const> = to:addItem(taken, taken.count)

      moved = moved + placed

      if placed < taken.count then
        from:addItem({
          item = taken.item,
          metadata = taken.metadata,
          uid = taken.uid,
          expiresAt = taken.expiresAt,
          uses = taken.uses,
        }, taken.count - placed)
      end
    end
  end

  return moved
end

--- Settles both sides of a confiscation once it happened.
---@param sessionId number The player server id.
---@param inventory table The character inventory.
---@param holding table The holding container.
---@return nil
local function settle(sessionId, inventory, holding)
  SaveInventory(inventory)
  SaveInventory(holding)
  NotifyInventoryChanged(inventory)
  NotifyContainerChanged(holding.id)
  PushInventoryState(sessionId)
end

--- Takes everything a character is carrying and keeps it aside.
---
--- Nothing is destroyed and nothing is copied: the instances move, so a weapon
--- comes back with the serial it left with, its rounds and whatever was bolted
--- to it. The hotbar is emptied with the rest, and its arrangement is not kept
--- — a key holds a slot, and the slot is what is being taken away.
---
--- Confiscating twice adds to what is already held rather than replacing it.
---@param sessionId number The player server id.
---@return number moved, string? reason The quantity taken, and why none was otherwise.
function ConfiscateInventory(sessionId)
  local inventory <const>, character <const> = GetSessionInventory(sessionId)

  if not inventory or not character then
    return 0, 'no_character'
  end

  local holding <const> = holdingFor(character.id)

  if not holding then
    return 0, 'invalid_inventory'
  end

  local moved <const> = WithInventoryLock({ inventory.id, holding.id }, function()
    return transferAll(inventory, holding)
  end) or 0

  if moved <= 0 then
    return 0, 'empty_slot'
  end

  settle(sessionId, inventory, holding)

  return moved
end

exports('ConfiscateInventory', ConfiscateInventory)

--- Gives back everything that was taken from a character.
---
--- What the character has no room for stays held rather than falling on the
--- floor: they picked things up since, and the answer to a bag that is too
--- full is to come back for the rest, not to lose it.
---@param sessionId number The player server id.
---@return number moved, string? reason The quantity returned, and why none was otherwise.
function ReturnInventory(sessionId)
  local inventory <const>, character <const> = GetSessionInventory(sessionId)

  if not inventory or not character then
    return 0, 'no_character'
  end

  local holding <const> = holdingFor(character.id)

  if not holding then
    return 0, 'invalid_inventory'
  end

  if holding:isEmpty() then
    return 0, 'empty_slot'
  end

  local moved <const> = WithInventoryLock({ inventory.id, holding.id }, function()
    return transferAll(holding, inventory)
  end) or 0

  if moved <= 0 then
    return 0, 'no_room'
  end

  settle(sessionId, inventory, holding)

  return moved
end

exports('ReturnInventory', ReturnInventory)

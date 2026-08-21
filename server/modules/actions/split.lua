--- Detaches part of a stack into a slot of its own. The original keeps its
--- place and the remainder opens a free carried slot: this is deliberately
--- not a move, because handing the quantity back to the inventory at large
--- would merge it straight into the stack it just came from.
---
--- Everything is checked before anything is taken, so a refusal leaves the
--- inventory exactly as it was rather than halfway through.
---@param inventory table The character inventory.
---@param slot number The slot holding the stack to split.
---@param count number The quantity to detach.
---@return boolean split, string? reason Whether the stack was split, and why it was not otherwise.
function SplitStack(inventory, slot, count)
  if IsHotbarSlot(slot) then
    return false, 'invalid_slot'
  end

  local stack <const> = inventory:getStack(slot)

  if not stack then
    return false, 'empty_slot'
  end

  if stack.uid or not IsItemStackable(stack.item) then
    return false, 'not_stackable'
  end

  if count < 1 or count >= stack.count then
    return false, 'invalid_quantity'
  end

  local destination <const> = inventory:getFirstFreeSlot()

  if not destination then
    return false, 'no_free_slot'
  end

  local taken <const> = inventory:takeFromSlot(slot, count)

  if not taken then
    return false, 'empty_slot'
  end

  inventory:setStack(destination, {
    item = taken.item,
    count = taken.count,
    metadata = taken.metadata and Siku.table.deepClone(taken.metadata) or nil,
    expiresAt = taken.expiresAt,
    uses = taken.uses,
  })

  return true
end

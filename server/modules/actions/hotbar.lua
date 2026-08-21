--- Puts a quantity on a hotbar slot, evicting whatever was there back into
--- the carried grid. The eviction is checked before anything is committed:
--- either the whole exchange happens, or the inventory is left exactly as it
--- was. Nothing is ever destroyed to make room for the incoming stack.
---@param inventory table The character inventory.
---@param fromSlot number The carried slot the stack comes from.
---@param hotbarSlot number The hotbar slot number to fill.
---@param count number The quantity to place.
---@return boolean placed, string? reason Whether the hotbar slot was filled, and why nothing was placed otherwise.
function PlaceIntoHotbar(inventory, fromSlot, hotbarSlot, count)
  if fromSlot == hotbarSlot then
    return false, 'same_slot'
  end

  local source <const> = inventory:getStack(fromSlot)

  if not source then
    return false, 'empty_slot'
  end

  local occupant <const> = inventory:getStack(hotbarSlot)

  if occupant and CanStack(occupant, source) then
    return TransferBetweenSlots(inventory, fromSlot, inventory, hotbarSlot, count)
  end

  local taken <const> = inventory:takeFromSlot(fromSlot, math.min(count, source.count))

  if not taken then
    return false, 'empty_slot'
  end

  local evicted <const> = occupant and inventory:takeFromSlot(hotbarSlot, occupant.count) or nil

  if evicted then
    local room <const> = inventory:getAcceptedQuantity(evicted, evicted.count)

    if room < evicted.count then
      inventory:setStack(hotbarSlot, evicted)
      inventory:addItem(taken, taken.count)

      return false, 'no_room'
    end
  end

  inventory:setStack(hotbarSlot, taken)

  if evicted then
    inventory:addItem(evicted, evicted.count)
  end

  return true
end

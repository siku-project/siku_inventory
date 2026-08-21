--- Moves a quantity from one slot to another, across inventories or inside
--- one. Everything is recomputed here: the caller only names slots, never
--- quantities of anything it already believes it holds.
---
--- Whatever the destination refuses goes back to the very slot it came from,
--- which is always able to take it again. Handing it to the inventory at
--- large instead would destroy it the day that inventory is full.
---@param source table The inventory to draw from.
---@param fromSlot number The slot to draw from.
---@param destination table The inventory to fill.
---@param toSlot? number The wanted slot, or nil to let the destination choose.
---@param count number The quantity to move.
---@return boolean moved, string? reason Whether anything moved, and why nothing did otherwise.
function TransferBetweenSlots(source, fromSlot, destination, toSlot, count)
  local stack <const> = source:getStack(fromSlot)

  if not stack then
    return false, 'empty_slot'
  end

  local wanted <const> = math.min(count, stack.count)

  if toSlot and not destination:isValidSlot(toSlot) then
    return false, 'invalid_slot'
  end

  local target <const> = toSlot and destination:getStack(toSlot) or nil

  if source == destination and fromSlot == toSlot then
    return false, 'same_slot'
  end

  if target and not CanStack(target, stack) then
    if wanted < stack.count then
      return false, 'occupied_slot'
    end

    return SwapSlots(source, fromSlot, destination, toSlot)
  end

  local accepted = wanted

  if source ~= destination then
    accepted = destination:getAcceptedQuantity(stack, wanted)

    if accepted <= 0 then
      return false, 'no_room'
    end
  end

  local taken <const> = source:takeFromSlot(fromSlot, accepted)

  if not taken then
    return false, 'empty_slot'
  end

  local placed = 0

  if toSlot then
    placed = PlaceInSlot(destination, toSlot, taken)
  else
    placed = destination:addItem(taken, taken.count)
  end

  if placed < taken.count then
    PlaceInSlot(source, fromSlot, {
      item = taken.item,
      count = taken.count - placed,
      metadata = taken.metadata,
      uid = taken.uid,
      expiresAt = taken.expiresAt,
      uses = taken.uses,
    })
  end

  return placed > 0, placed > 0 and nil or 'no_room'
end

--- Places an instance in a precise slot, merging when the slot already holds
--- a compatible stack.
---@param inventory table The destination inventory.
---@param slot number The destination slot.
---@param instance table The instance to place.
---@return number placed The quantity actually placed.
function PlaceInSlot(inventory, slot, instance)
  local existing <const> = inventory:getStack(slot)

  if not existing then
    local unitWeight <const> = GetItemWeight(instance.item) + GetFittedWeight(instance)
    local free <const> = inventory:getFreeWeight()
    local byWeight = instance.count

    if unitWeight > 0 and free ~= math.huge then
      byWeight = free // unitWeight
    end

    local perSlot <const> = GetItemMaxStack(instance.item)
    local placed <const> = math.min(instance.count, byWeight, perSlot == math.huge and instance.count or perSlot)

    if placed <= 0 then
      return 0
    end

    inventory:setStack(slot, {
      item = instance.item,
      count = placed,
      metadata = instance.metadata,
      uid = instance.uid,
      expiresAt = instance.expiresAt,
      uses = instance.uses,
    })

    return placed
  end

  if not CanStack(existing, instance) then
    return 0
  end

  local unitWeight <const> = GetItemWeight(instance.item) + GetFittedWeight(instance)
  local free <const> = inventory:getFreeWeight()
  local byWeight = instance.count

  if unitWeight > 0 and free ~= math.huge then
    byWeight = free // unitWeight
  end

  local room <const> = GetStackRoom(existing)
  local placed <const> = math.min(instance.count, byWeight, room == math.huge and instance.count or room)

  if placed <= 0 then
    return 0
  end

  existing.count = existing.count + placed
  existing.expiresAt = MergedExpiry(existing, instance)
  inventory:touch()

  return placed
end

--- Exchanges the whole content of two slots, weight permitting on both sides.
---@param source table The first inventory.
---@param fromSlot number The first slot.
---@param destination table The second inventory.
---@param toSlot number The second slot.
---@return boolean swapped, string? reason Whether the exchange happened, and why it did not otherwise.
function SwapSlots(source, fromSlot, destination, toSlot)
  local first <const> = source:getStack(fromSlot)
  local second <const> = destination:getStack(toSlot)

  if not first or not second then
    return false, 'empty_slot'
  end

  if source ~= destination then
    local outgoing <const> = GetInstanceWeight(first)
    local incoming <const> = GetInstanceWeight(second)

    if destination:getFreeWeight() + incoming < outgoing then
      return false, 'no_room'
    end

    if source:getFreeWeight() + outgoing < incoming then
      return false, 'no_room'
    end
  end

  source:setStack(fromSlot, second)
  destination:setStack(toSlot, first)

  return true
end

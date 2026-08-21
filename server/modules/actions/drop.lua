--- Takes a quantity out of an inventory and leaves it on the ground at the
--- character's own position. Nothing is removed before the drop is written: a
--- failure puts the stack straight back where it came from rather than
--- letting it vanish.
---
--- The source is named rather than assumed: what a player throws down came
--- from their bag most of the time, and out of the locker they are standing
--- at the rest of it.
---@param sessionId number The player server id.
---@param source table The inventory to draw from.
---@param slot number The slot to draw from.
---@param count number The quantity to drop.
---@param coords vector3 The live position of the character.
---@return nil
function DropFromSlot(sessionId, source, slot, count, coords)
  if source:isGround() then
    return TriggerClientEvent('siku_inventory:client:actionRefused', sessionId, 'invalid_request')
  end

  local inventory <const> = source
  local held <const> = GetNearbyDropIds(coords)

  held[#held + 1] = inventory.id

  local dropped <const> = WithInventoryLock(held, function()
    local taken <const> = inventory:takeFromSlot(slot, count)

    if not taken then
      return false
    end

    --- Written before the ground is, and that order is not cosmetic: an
    --- instance is unique in database, so it may never be recorded in two
    --- places — not even for the moment between two transactions. Writing the
    --- arrival first is what makes the database refuse the departure.
    SaveInventory(inventory)

    local drop <const> = CreateDrop(coords, taken)

    if not drop then
      inventory:addItem(taken, taken.count)
      SaveInventory(inventory)

      return false
    end

    return true
  end)

  if dropped then
    NotifyDropsChanged(sessionId)
    NotifyContainerChanged(inventory.id, sessionId)
  else
    TriggerClientEvent('siku_inventory:client:actionRefused', sessionId, 'refused')
  end

  PushInventoryState(sessionId)
end

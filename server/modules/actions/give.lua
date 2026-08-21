--- Hands a quantity from one character to another. The receiver is checked
--- for room before anything leaves the giver, and whatever the receiver could
--- not take falls to the ground rather than disappearing.
---
--- Naming no quantity hands over the whole stack. The slot is read here, under
--- the lock, rather than trusted from whoever asked: a caller that believed
--- the slot held four and finds six hands over six, and one that believed six
--- and finds four hands over four.
---@param sessionId number The giver session.
---@param targetId number The receiver session.
---@param slot number The slot to draw from.
---@param count? number The quantity to hand over, nil for the whole stack.
---@return nil
function GiveToSession(sessionId, targetId, slot, count)
  local function refuse(reason)
    TriggerClientEvent('siku_inventory:client:actionRefused', sessionId, reason)
  end

  if targetId == sessionId then
    return refuse('invalid_target')
  end

  local giver <const> = GetSessionInventory(sessionId)
  local receiver <const>, receiverCharacter <const> = GetSessionInventory(targetId)

  if not giver then
    return refuse('no_character')
  end

  if not receiver or not receiverCharacter then
    return refuse('target_unavailable')
  end

  local distance <const> = GetSessionDistance(sessionId, targetId)

  if not distance or distance > InventoryConfig.giveDistance then
    return refuse('target_too_far')
  end

  local coords <const> = GetSessionCoords(sessionId)

  if not coords then
    return refuse('invalid_request')
  end

  local held <const> = GetNearbyDropIds(coords)

  held[#held + 1] = giver.id
  held[#held + 1] = receiver.id

  local outcome <const> = WithInventoryLock(held, function()
    local stack <const> = giver:getStack(slot)

    if not stack then
      return { ok = false, reason = 'empty_slot' }
    end

    local wanted <const> = count and math.min(count, stack.count) or stack.count
    local accepted <const> = receiver:getAcceptedQuantity(stack, wanted)

    if accepted <= 0 then
      return { ok = false, reason = 'target_full' }
    end

    local taken <const> = giver:takeFromSlot(slot, wanted)

    if not taken then
      return { ok = false, reason = 'empty_slot' }
    end

    local given <const> = receiver:addItem(taken, accepted)
    local leftover <const> = taken.count - given

    if leftover > 0 then
      CreateDrop(coords, {
        item = taken.item,
        count = leftover,
        metadata = taken.metadata,
        uid = given > 0 and nil or taken.uid,
        expiresAt = taken.expiresAt,
        uses = taken.uses,
      })
    end

    return { ok = true, given = given, leftover = leftover, item = taken.item }
  end)

  if not outcome or not outcome.ok then
    return refuse(outcome and outcome.reason or 'refused')
  end

  SaveInventory(giver)
  SaveInventory(receiver)

  local label <const> = GetItemDefinitionPayload(outcome.item).label

  Siku.Notification(targetId, {
    type = 'success',
    title = T('notify_title'),
    description = T('notify_received', outcome.given, label),
  })

  if outcome.leftover > 0 then
    NotifyDropsChanged()

    Siku.Notification(sessionId, {
      type = 'warning',
      title = T('notify_title'),
      description = T('notify_partial_give', outcome.leftover),
    })
  end

  PushInventoryState(targetId)
end

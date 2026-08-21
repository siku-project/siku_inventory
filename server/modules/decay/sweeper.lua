local SWEEP_INTERVAL <const> = 60000

--- Throws away what has spoiled past its life, in every inventory currently
--- held in memory. Only the kinds that asked to be removed disappear; the
--- others stay where they are and are simply refused when used, which is what
--- lets a server keep rotten food as something a player has to deal with.
---@return number removed The number of stacks thrown away.
local function sweepSpoiled()
  local removed = 0
  local touched <const> = {}

  ForEachCachedInventory(function(inventory)
    local expired <const> = {}

    for slot, stack in pairs(inventory.stacks) do
      if RemovesOnDecay(stack.item) and IsStackSpoiled(stack) then
        expired[#expired + 1] = slot
      end
    end

    for i = 1, #expired do
      inventory:takeFromSlot(expired[i], inventory:getStack(expired[i]).count)
      removed = removed + 1
    end

    if #expired > 0 then
      touched[#touched + 1] = inventory
    end
  end)

  local onGround = false

  for i = 1, #touched do
    local inventory <const> = touched[i]

    onGround = onGround or inventory:isGround()

    SaveInventory(inventory)
    DiscardDropIfEmpty(inventory)
    NotifyInventoryChanged(inventory)
  end

  if onGround then
    NotifyDropsChanged()
  end

  return removed
end

Siku.SetInterval(SWEEP_INTERVAL, function()
  local removed <const> = sweepSpoiled()

  if removed > 0 then
    Siku.print.debug(('Swept %d spoiled stack(s)'):format(removed))
  end
end)

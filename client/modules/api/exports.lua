--- Uses whatever sits in a slot.
---
--- What happens next is not this side's business: the server re-reads the
--- slot, asks the item whether the use makes sense, occupies the character for
--- as long as the item says, and hands over to whoever owns the behaviour. A
--- refusal comes back as a notification like any other.
---@param slot number The slot to use, hotbar slots included.
---@return boolean asked Whether the request was sent.
function UseSlot(slot)
  if type(slot) ~= 'number' or slot % 1 ~= 0 or slot < 1 then
    return false
  end

  TriggerServerEvent('siku_inventory:server:use', { slot = slot })

  return true
end

exports('UseSlot', UseSlot)

--- Finds where an item is carried, favouring the place it can be used from.
---
--- A weapon is only usable from a hotbar key, so it is looked for there and
--- nowhere else — pointing at the copy buried in the grid would only earn a
--- refusal. Anything else is taken from the lowest carried slot, then from the
--- hotbar.
---@param item string The item identifier.
---@return number? slot The slot holding it, nil when the character has none.
local function findSlotHolding(item)
  local inventory <const> = GetInventoryState().inventory

  if type(inventory) ~= 'table' then
    return nil
  end

  if not IsWeaponItem(item) then
    local lowest = nil

    for slot, stack in pairs(inventory.stacks or {}) do
      local number <const> = tonumber(slot)

      if stack.item == item and number and (not lowest or number < lowest) then
        lowest = number
      end
    end

    if lowest then
      return lowest
    end
  end

  local rank = nil

  for index, stack in pairs(inventory.hotbar or {}) do
    local position <const> = tonumber(index)

    if stack.item == item and position and (not rank or position < rank) then
      rank = position
    end
  end

  return rank and GetHotbarSlotNumber(rank) or nil
end

--- Uses an item by name, wherever the character is carrying it.
---
--- Use this when a script knows what it wants rather than where it is. When
--- the instance matters — a particular weapon, a stack with its own metadata —
--- name the slot instead.
---@param item string The item identifier.
---@return boolean asked Whether the request was sent.
function UseItem(item)
  if type(item) ~= 'string' then
    return false
  end

  local slot <const> = findSlotHolding(item)

  return slot ~= nil and UseSlot(slot)
end

exports('UseItem', UseItem)

--- Asks for a container to be opened beside the bag.
---
--- The same door the server has, from this side: a family and whatever that
--- family needs to find the thing.
---
---     OpenContainer('stash', { name = 'policelocker' })
---     OpenContainer('item',  { uid = box.uid })
---
--- Nothing is decided here. Whether this character may open that container —
--- the jobs, the distance, the instance, who is holding what — is the server's
--- to answer, and the screen only comes up once it agreed. A refusal arrives
--- as a notification like any other.
---@param kind string The container family.
---@param request? table What that family needs to find the container.
---@return boolean asked Whether the request was sent.
function OpenContainer(kind, request)
  if type(kind) ~= 'string' or kind == '' or not CanOpenInventory() then
    return false
  end

  TriggerServerEvent('siku_inventory:server:openContainer', {
    kind = kind,
    request = type(request) == 'table' and request or {},
  })

  return true
end

exports('OpenContainer', OpenContainer)

--- Hands part of a slot to somebody standing nearby.
---
--- This is the give dialog without the dialog, for an interaction that already
--- knows who it is pointing at. Nothing about it is settled here: the server
--- re-reads the slot, measures the distance between the two peds, and refuses
--- a receiver who cannot carry it — and what they could not take falls to the
--- ground rather than vanishing.
---
--- Naming no quantity hands over the whole stack. Zero is not a way of saying
--- that: a quantity that came out of a calculation and landed on zero is a
--- mistake, and giving everything away is too final to be what a mistake does.
---@param serverId number The receiving player server id.
---@param slot number The slot to draw from.
---@param count? number The quantity, nil for the whole stack.
---@return boolean asked Whether the request was sent.
function GiveItemToTarget(serverId, slot, count)
  if type(serverId) ~= 'number' or serverId % 1 ~= 0 or serverId < 1 then
    return false
  end

  if type(slot) ~= 'number' or slot % 1 ~= 0 or slot < 1 then
    return false
  end

  if count ~= nil and (type(count) ~= 'number' or count % 1 ~= 0 or count < 1) then
    return false
  end

  if serverId == GetPlayerServerId(PlayerId()) then
    return false
  end

  TriggerServerEvent('siku_inventory:server:give', {
    target = serverId,
    slot = slot,
    count = count,
  })

  return true
end

exports('GiveItemToTarget', GiveItemToTarget)

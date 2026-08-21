--- Whether a reference means "loose on the ground, wherever there is room"
--- rather than a precise drop. That case creates a new drop instead of
--- targeting an existing inventory, so it never reaches the resolver.
---@param reference table The reference the client sent.
---@return boolean loose Whether the reference means a fresh drop.
function IsLooseGroundReference(reference)
  return type(reference) == 'table'
    and reference.container == 'ground'
    and reference.dropId == nil
end

--- Turns a container reference sent by a client into a real inventory and
--- slot. A client only ever names what it is looking at — never an inventory
--- identifier it could have guessed. The ground is resolved against the live
--- ped position, so a distant drop is unreachable whatever the payload says.
---@param reference table The reference the client sent.
---@param inventory table The character inventory of the requesting session.
---@param coords vector3 The live position of the requesting session.
---@param sessionId? number The requesting session, needed to name what it has open.
---@return table? resolved, number? slot The inventory the reference points at, and the slot within it when one was named.
function ResolveContainerSlot(reference, inventory, coords, sessionId)
  if type(reference) ~= 'table' then
    return nil, nil
  end

  local container <const> = reference.container

  if container == 'player' then
    local slot <const> = reference.slot ~= nil and ReadSlot(reference.slot) or nil

    if reference.slot ~= nil and (not slot or not inventory:isValidSlot(slot)) then
      return nil, nil
    end

    if slot and IsHotbarSlotNumber(slot) then
      return nil, nil
    end

    return inventory, slot
  end

  if container == 'hotbar' then
    local index <const> = ReadSlot(reference.slot)

    if not index or not IsValidHotbarIndex(index) then
      return nil, nil
    end

    return inventory, GetHotbarSlotNumber(index)
  end

  if container == 'secondary' then
    local open <const> = sessionId and GetSessionContainerInventory(sessionId) or nil

    if not open then
      return nil, nil
    end

    local slot <const> = reference.slot ~= nil and ReadSlot(reference.slot) or nil

    if reference.slot ~= nil and (not slot or not open:isValidSlot(slot)) then
      return nil, nil
    end

    return open, slot
  end

  if container ~= 'ground' then
    return nil, nil
  end

  local dropId <const> = ReadSlot(reference.dropId)

  if not dropId then
    return nil, nil
  end

  local drop <const> = GetDrop(dropId)

  if not drop or not IsDropReachable(drop, coords) then
    return nil, nil
  end

  local slot <const> = reference.slot ~= nil and ReadSlot(reference.slot) or nil

  return drop, slot
end

local drawnBySession <const> = {}

--- The weapon a session currently has in hand.
---@param sessionId number The player server id.
---@return string? uid The drawn instance, nil when hands are empty.
function GetSessionDrawnWeapon(sessionId)
  return drawnBySession[sessionId]
end

--- Finds a weapon a character has on a hotbar key.
---
--- The key is what makes a weapon usable, not the bag: something buried in the
--- grid is owned and nothing more. That rule lives here rather than in the
--- interface, so a client asking to draw a rifle from the grid is refused.
---@param inventory table The character inventory.
---@param slot number The slot the client named.
---@return table? stack, string? reason The weapon stack, and why it cannot be drawn otherwise.
local function readHotbarWeapon(inventory, slot)
  if not IsHotbarSlotNumber(slot) then
    return nil, 'not_on_hotbar'
  end

  local stack <const> = inventory:getStack(slot)

  if not stack then
    return nil, 'empty_slot'
  end

  if not IsWeaponItem(stack.item) then
    return nil, 'not_a_weapon'
  end

  return stack, nil
end

--- Builds what the client needs to put a weapon in the character's hands.
---
--- The metadata travels filtered, exactly as the interface receives it: what a
--- weapon is willing to show is a property of the weapon, not of the door the
--- answer left by.
---@param stack table The weapon stack.
---@param slot number The slot the weapon was drawn from.
---@return table payload The weapon as the client draws it.
local function drawPayload(stack, slot)
  return {
    uid = stack.uid,
    item = stack.item,
    name = GetItemDefinition(stack.item).name,
    slot = slot,
    ammo = GetLoadedAmmo(stack),
    takesAmmo = DoesWeaponTakeAmmo(stack.item),
    components = GetFittedComponents(stack),
    metadata = FilterPublicMetadata(stack.item, stack.metadata),
  }
end

--- Writes a round count back onto the instance that fired them.
---
--- The client is the only side that watches the ped fire, so it is the only
--- side that can say a round was spent — but it is never believed upwards.
--- What it reports may lower the count and never raise it: a client claiming
--- a full magazine after emptying one is simply told no.
---@param sessionId number The player server id.
---@param uid string The instance that fired.
---@param remaining any The rounds the client says are left.
---@return boolean written Whether the count moved.
function RecordSpentAmmo(sessionId, uid, remaining)
  local inventory <const> = GetSessionInventory(sessionId)

  if not inventory or type(uid) ~= 'string' or type(remaining) ~= 'number' then
    return false
  end

  if remaining ~= remaining or remaining < 0 or remaining % 1 ~= 0 then
    return false
  end

  return WithInventoryLock({ inventory.id }, function()
    local slot <const> = inventory:findByUid(uid)
    local stack <const> = slot and inventory:getStack(slot) or nil

    if not stack or not IsWeaponItem(stack.item) then
      return false
    end

    local loaded <const> = GetLoadedAmmo(stack)

    if remaining >= loaded then
      return false
    end

    local metadata <const> = stack.metadata and Siku.table.deepClone(stack.metadata) or {}

    metadata.ammo = remaining
    stack.metadata = metadata
    inventory:touch()

    return true
  end) == true
end

--- Takes note that a session put its weapon away, or lost it.
---@param sessionId number The player server id.
---@return nil
function ForgetDrawnWeapon(sessionId)
  drawnBySession[sessionId] = nil
end

--- Answers a request to draw or put away the weapon sitting on a hotbar key.
---
--- The same key does both: what the client asks for is a key, and what it gets
--- back is the state that key leads to. Pressing the key of the weapon already
--- in hand puts it away; pressing another one swaps.
---@param sessionId number The player server id.
---@param slot number The hotbar slot number.
---@return table? payload, string? reason What the client should hold, false to hold nothing, and why nothing happened otherwise.
function ToggleDrawnWeapon(sessionId, slot)
  local inventory <const> = GetSessionInventory(sessionId)

  if not inventory then
    return nil, 'no_character'
  end

  local stack <const>, reason <const> = readHotbarWeapon(inventory, slot)

  if not stack then
    return nil, reason
  end

  if drawnBySession[sessionId] == stack.uid then
    drawnBySession[sessionId] = nil

    return false, nil
  end

  drawnBySession[sessionId] = stack.uid

  return drawPayload(stack, slot), nil
end

AddEventHandler('playerDropped', function()
  ForgetDrawnWeapon(source)
end)

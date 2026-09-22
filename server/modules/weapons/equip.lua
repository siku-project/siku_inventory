local drawnBySession <const> = {}

--- The weapon a session currently has in hand, as this side remembers it.
---
--- An instance is remembered by its uid. A thrown weapon is a pile with no
--- uid, so it is remembered by the slot it sits on and what it is: the pile
--- shrinks with every throw but stays the same pile.
---@param sessionId number The player server id.
---@return table? drawn { uid?, slot, item }, nil when hands are empty.
function GetSessionDrawnRecord(sessionId)
  return drawnBySession[sessionId]
end

--- The instance a session currently has in hand.
---@param sessionId number The player server id.
---@return string? uid The drawn instance, nil when hands are empty or hold a pile.
function GetSessionDrawnWeapon(sessionId)
  local drawn <const> = drawnBySession[sessionId]

  return drawn and drawn.uid or nil
end

--- Where the drawn weapon sits right now, if it is still there.
---@param sessionId number The player server id.
---@param inventory table The character inventory.
---@return number? slot The slot holding it, nil when it left.
function FindDrawnSlot(sessionId, inventory)
  local drawn <const> = drawnBySession[sessionId]

  if not drawn then
    return nil
  end

  if drawn.uid then
    return inventory:findByUid(drawn.uid)
  end

  local stack <const> = inventory:getStack(drawn.slot)

  if not stack or stack.item ~= drawn.item then
    return nil
  end

  return drawn.slot
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
  if not IsHotbarSlot(slot) then
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
    throwable = IsThrowableWeapon(stack.item),
    count = stack.count or 1,
    components = GetFittedComponents(stack),
    metadata = FilterPublicMetadata(stack.item, stack.metadata),
  }
end

--- Whether a stack is the one a session holds.
---@param drawn table The remembered record.
---@param stack table The stack on a hotbar key.
---@param slot number Its slot.
---@return boolean same Whether they are the same weapon.
local function isDrawn(drawn, stack, slot)
  if drawn.uid then
    return drawn.uid == stack.uid
  end

  return drawn.slot == slot and drawn.item == stack.item
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

--- Puts away a weapon that is no longer on a hotbar key.
---
--- What makes a weapon usable is the key it sits on, and drawing it is not a
--- moment that settles the question once and for all — the key has to keep
--- holding it. Taking it off the key while it is out, dropping it, handing it
--- over: each of those ends with a weapon in hands that no longer own it.
---
--- Asked again on every state a session is sent, so whatever moved the
--- instance did not have to know a weapon was concerned.
---@param sessionId number The player server id.
---@param inventory table The character inventory.
---@return boolean holstered Whether a weapon was put away.
function HolsterUnreachableWeapon(sessionId, inventory)
  if not drawnBySession[sessionId] then
    return false
  end

  local slot <const> = FindDrawnSlot(sessionId, inventory)

  if slot and IsHotbarSlot(slot) then
    return false
  end

  drawnBySession[sessionId] = nil

  TriggerClientEvent('siku_inventory:client:setDrawnWeapon', sessionId, false)

  return true
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

  local drawn <const> = drawnBySession[sessionId]

  if drawn and isDrawn(drawn, stack, slot) then
    drawnBySession[sessionId] = nil

    return false, nil
  end

  drawnBySession[sessionId] = { uid = stack.uid, slot = slot, item = stack.item }

  return drawPayload(stack, slot), nil
end

--- Spends one of the thrown weapon in hand, after the client saw it leave.
---
--- The client watches the throw; this side checks the claim against what
--- it remembers: a thrown weapon in hand, on that key, with something left
--- on the pile. One goes; the next one comes back into the hand when the
--- pile is not empty, the hands empty otherwise.
---@param sessionId number The player server id.
---@param slot any The slot the client says it threw from.
---@return table|false|nil next, string? reason The next one to hold, false for empty hands, nil and why when nothing was thrown.
function ThrowDrawnWeapon(sessionId, slot)
  local inventory <const> = GetSessionInventory(sessionId)
  local drawn <const> = drawnBySession[sessionId]

  if not inventory or not drawn then
    return nil, 'not_drawn'
  end

  if drawn.uid or drawn.slot ~= slot or not IsThrowableWeapon(drawn.item) then
    return nil, 'not_throwable'
  end

  return WithInventoryLock({ inventory.id }, function()
    local stack <const> = inventory:getStack(slot)

    if not stack or stack.item ~= drawn.item then
      drawnBySession[sessionId] = nil

      return false, nil
    end

    inventory:takeFromSlot(slot, 1)

    local remaining <const> = inventory:getStack(slot)

    if not remaining or remaining.item ~= drawn.item then
      drawnBySession[sessionId] = nil

      return false, nil
    end

    return drawPayload(remaining, slot), nil
  end)
end

AddEventHandler('playerDropped', function()
  ForgetDrawnWeapon(source)
end)

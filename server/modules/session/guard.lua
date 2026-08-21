local MAX_COUNT <const> = 1000000
local STATE_COOLDOWN <const> = 200

local lastAction <const> = {}
local lastState <const> = {}

--- Rejects bursts a human hand cannot produce. This is a spam guard, not a
--- gameplay cooldown.
---@param sessionId number The player server id.
---@return boolean allowed Whether the action may proceed.
function PassesActionCooldown(sessionId)
  local now <const> = GetGameTimer()
  local previous <const> = lastAction[sessionId]

  if previous and now - previous < InventoryConfig.actionCooldown then
    return false
  end

  lastAction[sessionId] = now

  return true
end

--- Bounds how often a session may ask for a fresh state. Reading is counted
--- apart from acting: opening the inventory asks for a state, and that must
--- never eat the allowance of the action the player performs right after.
---@param sessionId number The player server id.
---@return boolean allowed Whether the state may be sent.
function PassesStateCooldown(sessionId)
  local now <const> = GetGameTimer()
  local previous <const> = lastState[sessionId]

  if previous and now - previous < STATE_COOLDOWN then
    return false
  end

  lastState[sessionId] = now

  return true
end

--- Reads a quantity a client sent, refusing anything that is not a sane
--- positive integer.
---@param value any The value received.
---@return number? count The accepted quantity.
function ReadCount(value)
  if type(value) ~= 'number' then
    return nil
  end

  if value ~= value or value % 1 ~= 0 then
    return nil
  end

  if value <= 0 or value > MAX_COUNT then
    return nil
  end

  return value
end

--- Reads a slot number a client sent.
---@param value any The value received.
---@return number? slot The accepted slot.
function ReadSlot(value)
  if type(value) ~= 'number' or value % 1 ~= 0 or value < 1 then
    return nil
  end

  return value
end

AddEventHandler('playerDropped', function()
  lastAction[source] = nil
  lastState[source] = nil
end)

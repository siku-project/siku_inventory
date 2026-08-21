local SWEEP_INTERVAL <const> = 2000

local watching <const> = {}

--- Sums up what a character can see on the ground, closely enough that any
--- change to it changes the answer.
---@param entries table The ground payload.
---@return string signature What the character is looking at.
local function signatureOf(entries)
  local parts <const> = {}

  for i = 1, #entries do
    local entry <const> = entries[i]

    parts[i] = ('%d:%d:%s:%d:%s'):format(
      entry.dropId,
      entry.slot,
      entry.item,
      entry.count,
      entry.uid or ''
    )
  end

  table.sort(parts)

  return table.concat(parts, '|')
end

--- Sends a watcher what lies around them, when it is not what they already
--- have. Comparing first is what keeps the interface from redrawing the
--- ground on every beat for a world that did not move.
---@param sessionId number The player server id.
---@return nil
local function refresh(sessionId)
  local coords <const> = GetSessionCoords(sessionId)

  if not coords then
    return
  end

  local entries <const> = BuildGroundPayload(coords)
  local signature <const> = signatureOf(entries)

  if watching[sessionId] == signature then
    return
  end

  watching[sessionId] = signature

  TriggerClientEvent('siku_inventory:client:setGround', sessionId, entries)
end

--- Takes note that a character is looking at the ground.
---@param sessionId number The player server id.
---@return nil
function WatchGround(sessionId)
  watching[sessionId] = false
end

--- Takes note that a character stopped looking.
---@param sessionId number The player server id.
---@return nil
function UnwatchGround(sessionId)
  watching[sessionId] = nil
end

--- Records what a watcher was just sent, so the next check does not send it
--- again. Used by the full state push, which already carries the ground.
---@param sessionId number The player server id.
---@param entries table The ground payload that was sent.
---@return nil
function RecordGroundSent(sessionId, entries)
  if watching[sessionId] ~= nil then
    watching[sessionId] = signatureOf(entries)
  end
end

--- Tells every watcher that something on the ground moved.
---
--- Every one of them is re-checked rather than only those near the change:
--- there are never many, and the comparison above means only those whose view
--- actually differs are written to. Working out who was in range of what would
--- be more code for a wrong answer at the edges.
---@param except? number A session that was already told, usually the actor.
---@return nil
function NotifyDropsChanged(except)
  for sessionId in pairs(watching) do
    if sessionId ~= except then
      refresh(sessionId)
    end
  end
end

Siku.SetInterval(SWEEP_INTERVAL, function()
  for sessionId in pairs(watching) do
    refresh(sessionId)
  end
end)

AddEventHandler('playerDropped', function()
  UnwatchGround(source)
end)

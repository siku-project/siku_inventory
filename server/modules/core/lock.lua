local LOCK_TIMEOUT <const> = 5000
local LOCK_POLL <const> = 5

local held <const> = {}

--- Runs a routine while holding the lock of every inventory it touches, so
--- two actions can never interleave around a database yield and observe a
--- half-applied state. Identifiers are locked in a stable order, which is
--- what keeps two concurrent transfers from deadlocking against each other.
---@param ids table The inventory identifiers to hold.
---@param routine function The routine to run while holding them.
---@return any ... Whatever the routine returned, every value of it.
function WithInventoryLock(ids, routine)
  local ordered <const> = {}
  local seen <const> = {}

  for i = 1, #ids do
    local id <const> = ids[i]

    if id and not seen[id] then
      seen[id] = true
      ordered[#ordered + 1] = id
    end
  end

  table.sort(ordered)

  local deadline <const> = GetGameTimer() + LOCK_TIMEOUT

  for i = 1, #ordered do
    local id <const> = ordered[i]

    while held[id] do
      if GetGameTimer() > deadline then
        for j = 1, i - 1 do
          held[ordered[j]] = nil
        end

        Siku.print.warn(T('lock_timeout', id))

        return nil
      end

      Wait(LOCK_POLL)
    end

    held[id] = true
  end

  local returned <const> = table.pack(pcall(routine))

  for i = 1, #ordered do
    held[ordered[i]] = nil
  end

  if not returned[1] then
    Siku.print.error(T('action_failed', tostring(returned[2])))

    return nil
  end

  return table.unpack(returned, 2, returned.n)
end

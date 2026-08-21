--- Resolves the character behind a session. Everything the resource does is
--- attached to a character, never to the raw player id: a session that has
--- not picked a character yet owns no inventory.
---@param sessionId number The player server id.
---@return table? character The active character.
function GetSessionCharacter(sessionId)
  local character <const> = Siku.cache.getCurrentCharacter(sessionId)

  if type(character) ~= 'table' or type(character.id) ~= 'number' then
    return nil
  end

  return character
end

--- Resolves the inventory of the character behind a session.
---@param sessionId number The player server id.
---@return table? inventory, table? character The character inventory and the character it belongs to.
function GetSessionInventory(sessionId)
  local character <const> = GetSessionCharacter(sessionId)

  if not character then
    return nil, nil
  end

  local inventory <const> = GetOwnedInventory('character', character.id)

  return inventory, character
end

--- Reads the live position of a session, from the ped rather than from
--- anything the client claimed.
---@param sessionId number The player server id.
---@return vector3? coords The position, or nil when the ped is gone.
function GetSessionCoords(sessionId)
  local ped <const> = GetPlayerPed(tostring(sessionId))

  if not ped or ped == 0 then
    return nil
  end

  return GetEntityCoords(ped)
end

--- Distance between two sessions, in metres.
---@param a number The first session.
---@param b number The second session.
---@return number? distance The distance, or nil when a ped is missing.
function GetSessionDistance(a, b)
  local first <const> = GetSessionCoords(a)
  local second <const> = GetSessionCoords(b)

  if not first or not second then
    return nil
  end

  return #(first - second)
end

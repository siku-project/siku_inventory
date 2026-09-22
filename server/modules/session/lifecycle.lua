--- Writes back and drops the inventory of a character that left play. Who
--- was playing it is not kept here: the core announces the character id
--- itself, before its cache forgets the player.
---@param characterId number The character id.
---@return nil
local function releaseCharacter(characterId)
  local inventory <const> = GetOwnedInventory('character', characterId)

  if inventory then
    ReleaseInventory(inventory)
  end
end

--- The name of the character a session is playing, read from the core's
--- character, which carries the whole identity.
---@param sessionId number The player server id.
---@return table? identity { firstName, lastName }, nil when no character is in play.
function GetSessionIdentity(sessionId)
  local character <const> = GetSessionCharacter(sessionId)

  if not character then
    return nil
  end

  return { firstName = character.firstName, lastName = character.lastName }
end

--- Pushes a fresh state to whoever is currently holding an inventory, so an
--- item handed over by another resource shows up without the player doing
--- anything.
---@param inventory table The inventory that changed.
---@return nil
function NotifyInventoryChanged(inventory)
  if not inventory or not inventory:isCharacter() then
    return
  end

  local sessionId <const> = Siku.cache.getSessionByCharacter(inventory.ownerId)

  if sessionId then
    PushInventoryState(sessionId)
  end
end

--- The session a character is being played on, answered by the core cache.
---@param characterId any The character id.
---@return number? sessionId The player server id, nil when nobody is playing it.
function GetSessionOfCharacter(characterId)
  return Siku.cache.getSessionByCharacter(characterId)
end

--- Tells a client who it is, for the screens that show a name.
---@param sessionId number The player server id.
---@return nil
local function pushIdentity(sessionId)
  local identity <const> = GetSessionIdentity(sessionId)

  if identity then
    TriggerClientEvent('siku_inventory:client:setIdentity', sessionId, identity)
  end
end

--- Loads the inventory of a character as soon as the core made it active, so
--- the first interaction does not pay for a database round trip.
---@param sessionId number The player server id.
---@param characterData table The character row.
---@return nil
local function handleCharacterReady(sessionId, characterData)
  if type(sessionId) ~= 'number' or type(characterData) ~= 'table' then
    return
  end

  if type(characterData.id) ~= 'number' then
    return
  end

  pushIdentity(sessionId)
  PublishStashPoints(sessionId)
  PublishMetadataDisplay(sessionId)

  local inventory <const> = GetOwnedInventory('character', characterData.id)

  if not inventory then
    Siku.print.error(T('inventory_load_failed', characterData.id, sessionId))

    return
  end

  PushInventoryState(sessionId)

  Siku.print.debug(('Inventory %d ready for character %d'):format(inventory.id, characterData.id))
end

--- Writes back the inventory of a character the core took out of play, on
--- a switch as on a disconnect.
---@param _ number The player server id.
---@param characterId number The character id.
---@return nil
local function handleCharacterReleased(_, characterId)
  if type(characterId) ~= 'number' then
    return
  end

  releaseCharacter(characterId)
end

--- Pushes what a restart erased to the players already in the world.
---
--- A character becomes active once, and everyone playing when this resource
--- restarts already went through that moment. Nothing replays it, so the
--- open screens are fed again from the core's cache, which kept every
--- character.
---@return nil
function RestoreConnectedSessions()
  local restored = 0

  Siku.cache.forEach(function(sessionId)
    if GetSessionCharacter(sessionId) then
      restored = restored + 1

      pushIdentity(sessionId)
      PushInventoryState(sessionId)
    end
  end)

  if restored > 0 then
    Siku.print.debug(('Restored %d session(s) after restart'):format(restored))
  end
end

AddEventHandler('siku:server:createCharacterInstance', handleCharacterReady)
AddEventHandler('siku:server:releaseCharacterInstance', handleCharacterReleased)

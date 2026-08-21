local sessionByCharacter <const> = {}
local characterBySession <const> = {}
local identityBySession <const> = {}

--- Forgets the character a session was playing, releasing its inventory from
--- the cache. Both directions of the mapping are kept here rather than asked
--- back from the core: by the time a player drops, the core may already have
--- cleared its own cache, and an inventory nobody can name is an inventory
--- nobody writes back.
---@param sessionId number The player server id.
---@param persist boolean Whether the inventory should be written before it goes.
---@return nil
local function forgetSession(sessionId, persist)
  local characterId <const> = characterBySession[sessionId]

  if not characterId then
    return
  end

  characterBySession[sessionId] = nil
  identityBySession[sessionId] = nil

  if sessionByCharacter[characterId] == sessionId then
    sessionByCharacter[characterId] = nil
  end

  if not persist then
    return
  end

  local inventory <const> = GetOwnedInventory('character', characterId)

  if inventory then
    ReleaseInventory(inventory)
  end
end

--- Reads the name of the character a session is playing. The core keeps the
--- character but not its civil identity, so the row handed over when the
--- character became active is remembered here.
---@param sessionId number The player server id.
---@return table? identity The first and last name of the character.
function GetSessionIdentity(sessionId)
  return identityBySession[sessionId]
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

  local sessionId <const> = sessionByCharacter[inventory.ownerId]

  if sessionId then
    PushInventoryState(sessionId)
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

  forgetSession(sessionId, true)

  sessionByCharacter[characterData.id] = sessionId
  characterBySession[sessionId] = characterData.id

  local identity <const> = {
    firstName = characterData.first_name,
    lastName = characterData.last_name,
  }

  identityBySession[sessionId] = identity

  TriggerClientEvent('siku_inventory:client:setIdentity', sessionId, identity)
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

--- Rebuilds what a restart erased, for the players already in the world.
---
--- A character becomes active once, and everyone playing when this resource
--- restarts already went through that moment. Nothing replays it: the core
--- keeps the character but not its civil identity, so the names cannot be
--- asked back from it and are read from where they came from instead.
---
--- Without this the resource looks fine and quietly is not: the give dialog
--- lists nobody, because a session with no remembered name is skipped, and an
--- item handed over by another resource never reaches an open screen, because
--- the character behind it maps to no session.
---@return nil
function RestoreConnectedSessions()
  local wanted <const> = {}

  Siku.cache.forEach(function(sessionId)
    local character <const> = GetSessionCharacter(sessionId)

    if character then
      sessionByCharacter[character.id] = sessionId
      characterBySession[sessionId] = character.id
      wanted[#wanted + 1] = character.id
    end
  end)

  if #wanted == 0 then
    return
  end

  local rows <const> = MySQL.query.await(
    ('SELECT id, first_name, last_name FROM characters WHERE id IN (%s)')
      :format(string.rep('?', #wanted, ',')),
    wanted
  ) or {}

  for i = 1, #rows do
    local sessionId <const> = sessionByCharacter[rows[i].id]

    if sessionId then
      local identity <const> = {
        firstName = rows[i].first_name,
        lastName = rows[i].last_name,
      }

      identityBySession[sessionId] = identity

      TriggerClientEvent('siku_inventory:client:setIdentity', sessionId, identity)
      PushInventoryState(sessionId)
    end
  end

  Siku.print.debug(('Restored %d session(s) after restart'):format(#rows))
end

AddEventHandler('siku:server:createCharacterInstance', handleCharacterReady)

AddEventHandler('playerDropped', function()
  forgetSession(source, true)
end)

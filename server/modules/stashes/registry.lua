local TEMPORARY_PREFIX <const> = 'temp'

local definitions = {}

--- Remembers a stash definition, replacing whatever went by that name.
---
--- Re-registering is deliberate rather than refused: a resource restarting
--- declares its stashes again, and the second declaration is the one that
--- describes the world as it is now. The content is untouched — it lives in
--- database under the same name.
---@param declaration table The declaration to register.
---@return table? definition, string? reason The registered definition, and why it was refused otherwise.
function RegisterStashDefinition(declaration)
  local definition <const>, reason <const> = NormaliseStash(declaration)

  if not definition then
    local named <const> = type(declaration) == 'table' and declaration.name or declaration

    Siku.print.warn(T('stash_invalid', tostring(named), reason))

    return nil, reason
  end

  definitions[definition.name] = definition

  return definition
end

--- Forgets a stash definition. Its content stays in database: a stash nobody
--- declares is a stash nobody can open, not a stash that was emptied.
---@param name string The stash identifier.
---@return boolean removed Whether a definition went by that name.
function UnregisterStashDefinition(name)
  if type(name) ~= 'string' or not definitions[name] then
    return false
  end

  definitions[name] = nil

  return true
end

--- Reads a stash definition.
---@param name any The stash identifier.
---@return table? definition The definition, or nil when nothing goes by that name.
function GetStashDefinition(name)
  if type(name) == 'number' then
    name = tostring(name)
  end

  return type(name) == 'string' and definitions[name] or nil
end

--- Every stash currently declared.
---@return table definitions The definitions, keyed by name.
function GetStashDefinitions()
  return definitions
end

--- Builds a name for a temporary stash, unique for as long as it lives.
---@return string name The generated identifier.
function BuildTemporaryStashName()
  return ('%s:%s'):format(TEMPORARY_PREFIX, Siku.math.randomUUIDv7())
end

--- Whether a stash is one of the temporary ones.
---
--- Being temporary is about who declared it, not about when it goes: one asked
--- to last as long as the resource runs has no expiry and is still not
--- something anybody wrote down, so it can still be taken away by hand.
---@param definition table The stash definition.
---@return boolean temporary Whether it exists only because a script asked.
function IsTemporaryStash(definition)
  return definition.temporary == true
end

--- Works out who a stash belongs to for a given request.
---
--- A shared stash belongs to nobody and answers nil. A personal one belongs
--- to whoever is asking, unless the caller named somebody else — which is how
--- a supervisor opens a colleague's locker. One bound to a fixed name always
--- answers that name, whoever asks.
---@param sessionId number The player server id.
---@param definition table The stash definition.
---@param requested? string|number The owner the caller named.
---@return string? owner The owner the stash should resolve for.
function ResolveStashOwner(sessionId, definition, requested)
  if not definition.owner then
    return nil
  end

  if type(definition.owner) == 'string' then
    return definition.owner
  end

  if type(requested) == 'string' and requested ~= '' then
    return requested
  end

  if type(requested) == 'number' then
    return tostring(requested)
  end

  local character <const> = GetSessionCharacter(sessionId)

  return character and tostring(character.id) or nil
end

--- The name a stash inventory is stored under. A shared stash is stored under
--- its own name; a personal one under its name and its owner, which is what
--- makes two lockers of the same kind two different containers.
---@param definition table The stash definition.
---@param owner? string The owner the stash resolved for.
---@return string key The name addressing the inventory.
function BuildStashKey(definition, owner)
  if not owner then
    return definition.name
  end

  return ('%s:%s'):format(definition.name, owner)
end

--- Reads the inventory behind a stash, creating it on first access.
---@param definition table The stash definition.
---@param owner? string The owner the stash resolved for.
---@return table? inventory The stash inventory.
function GetStashInventory(definition, owner)
  local expiresAt <const> = definition.lifetime and (os.time() * 1000 + definition.lifetime) or nil

  return GetKeyedInventory(
    'stash',
    BuildStashKey(definition, owner),
    definition.slots,
    definition.maxWeight,
    expiresAt
  )
end

--- The stashes a character could walk up to, as the client needs them to
--- watch for a player standing close. Only what a client has to know travels:
--- where it is, how close is close enough, and what to call it.
---@return table points The reachable stash declarations.
function BuildStashPoints()
  local points <const> = {}

  for name, definition in pairs(definitions) do
    if definition.coords then
      points[#points + 1] = {
        name = name,
        label = definition.label,
        icon = definition.icon,
        coords = definition.coords,
        distance = GetStashDistance(definition),
        instance = definition.instance,
      }
    end
  end

  table.sort(points, function(a, b)
    return a.name < b.name
  end)

  return points
end

--- Tells every client where the stashes are.
---@param sessionId? number A single session, or nil for everyone.
---@return nil
function PublishStashPoints(sessionId)
  TriggerClientEvent('siku_inventory:client:setStashPoints', sessionId or -1, BuildStashPoints())
end

--- Loads the stashes written in shared/stashes.lua.
---@return number loaded The number of stashes declared in the file.
function LoadDeclaredStashes()
  local declared <const> = GetDeclaredStashes()
  local loaded = 0

  for name, definition in pairs(declared) do
    definitions[name] = definition
    loaded = loaded + 1
  end

  return loaded
end

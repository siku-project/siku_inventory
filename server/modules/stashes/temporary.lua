local SWEEP_INTERVAL <const> = 30000

--- Reads the starting content of a temporary stash. Every entry is a name, a
--- quantity and, when the instance has one, its metadata — the shape a caller
--- writes by hand rather than one built out of the database.
---@param inventory table The stash inventory.
---@param items any The declared content.
---@return nil
local function fill(inventory, items)
  if type(items) ~= 'table' then
    return
  end

  for i = 1, #items do
    local entry <const> = items[i]

    if type(entry) == 'table' and type(entry[1]) == 'string' then
      local count <const> = type(entry[2]) == 'number' and entry[2] or 1
      local metadata <const> = type(entry[3]) == 'table' and entry[3] or nil

      inventory:addItem({ item = entry[1], metadata = metadata }, count)
    end
  end
end

--- Creates a stash that removes itself.
---
--- Nothing about it is declared anywhere: it exists because a script asked
--- for it, under a name only that script knows, and it takes whatever is left
--- in it with it when it goes. Handing out a loot crate, a search result or
--- the contents of a body is what this is for.
---
--- Asking for one copy per character and for it to start with something in it
--- is refused rather than half honoured: there is no answer to which copy the
--- content would land in, and quietly seeding one nobody opens loses it.
---@param properties table The stash properties, content included.
---@return string? name The identifier the stash answers to.
function CreateTemporaryStash(properties)
  if type(properties) ~= 'table' then
    return nil
  end

  local lifetime <const> = type(properties.lifetime) == 'number'
    and properties.lifetime
    or InventoryConfig.temporaryStashLifetime

  if type(lifetime) ~= 'number' or lifetime < 0 then
    return nil
  end

  local seeded <const> = type(properties.items) == 'table' and #properties.items > 0

  if seeded and properties.owner == true then
    return nil
  end

  local name <const> = BuildTemporaryStashName()
  local definition <const> = RegisterStashDefinition({
    name = name,
    label = properties.label,
    slots = properties.slots,
    maxWeight = properties.maxWeight,
    owner = properties.owner,
    groups = properties.groups,
    coords = properties.coords,
    distance = properties.distance,
    instance = properties.instance,
    icon = properties.icon,
  })

  if not definition then
    return nil
  end

  definition.temporary = true
  definition.lifetime = lifetime > 0 and lifetime or nil
  definition.expiresAt = lifetime > 0 and (os.time() * 1000 + lifetime) or nil

  local inventory <const> = GetStashInventory(definition, ResolveStashOwner(0, definition, nil))

  if not inventory then
    UnregisterStashDefinition(name)

    return nil
  end

  fill(inventory, properties.items)
  SaveInventory(inventory)

  if definition.coords then
    PublishStashPoints()
  end

  return name
end

--- Removes a stash and everything left in it, closing it on whoever is
--- looking at it right now.
---@param name string The stash identifier.
---@return boolean removed Whether a stash went by that name.
function RemoveTemporaryStash(name)
  local definition <const> = GetStashDefinition(name)

  if not definition or not IsTemporaryStash(definition) then
    return false
  end

  UnregisterStashDefinition(definition.name)
  CloseContainersOf('stash', definition.name, 'unreachable')
  DeleteKeyedInventories('stash', definition.name)

  if definition.coords then
    PublishStashPoints()
  end

  return true
end

exports('CreateTemporaryStash', CreateTemporaryStash)
exports('RemoveTemporaryStash', RemoveTemporaryStash)

--- Removes the temporary stashes a previous run left behind.
---
--- One of them only ever existed because a script asked for it, and no script
--- asks again after a restart: what is left in database is a container nobody
--- can name, so it goes rather than sitting there forever.
---@return number removed The number of rows deleted.
function DiscardOrphanTemporaryStashes()
  local removed <const> = MySQL.update.await(
    "DELETE FROM inventories WHERE owner_type = 'stash' AND expires_at IS NOT NULL"
  ) or 0

  if removed > 0 then
    Siku.print.debug(('Discarded %d temporary stash(es) left by a previous run'):format(removed))
  end

  return removed
end

--- Sweeps the temporary stashes whose time ran out.
---@return number removed The number of stashes removed.
function SweepExpiredStashes()
  local now <const> = os.time() * 1000
  local expired <const> = {}

  for name, definition in pairs(GetStashDefinitions()) do
    if definition.expiresAt and definition.expiresAt <= now then
      expired[#expired + 1] = name
    end
  end

  for i = 1, #expired do
    RemoveTemporaryStash(expired[i])
  end

  return #expired
end

Siku.SetInterval(SWEEP_INTERVAL, function()
  SweepExpiredStashes()
end)

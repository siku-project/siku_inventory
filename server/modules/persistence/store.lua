local cache <const> = {}
local byOwner <const> = {}

--- Reads an inventory row and its stacks, building the object.
---@param row table The `inventories` row.
---@return table inventory The inventory instance.
local function hydrate(row)
  local items <const> = MySQL.query.await(
    'SELECT slot, item, count, metadata, uid, expires_at, uses FROM inventory_items WHERE inventory_id = ?',
    { row.id }
  ) or {}

  return SikuInventoryClass.new(row, items)
end

--- Remembers an inventory so the next lookup does not hit the database.
---@param inventory table The inventory to keep.
---@return table inventory The very same inventory.
local function remember(inventory)
  cache[inventory.id] = inventory

  if inventory.ownerId then
    byOwner[inventory.ownerType .. ':' .. inventory.ownerId] = inventory.id
  end

  if inventory.ownerKey then
    byOwner[inventory.ownerType .. ':' .. inventory.ownerKey] = inventory.id
  end

  return inventory
end

--- Forgets the ways an inventory could be looked up.
---@param inventory table The inventory leaving the cache.
---@return nil
local function forget(inventory)
  cache[inventory.id] = nil

  if inventory.ownerId then
    byOwner[inventory.ownerType .. ':' .. inventory.ownerId] = nil
  end

  if inventory.ownerKey then
    byOwner[inventory.ownerType .. ':' .. inventory.ownerKey] = nil
  end
end

--- Reads an inventory by its identifier, from cache when possible.
---@param id number The inventory identifier.
---@return table? inventory The inventory, or nil when it does not exist.
function GetInventoryById(id)
  if type(id) ~= 'number' then
    return nil
  end

  if cache[id] then
    return cache[id]
  end

  local row <const> = MySQL.single.await('SELECT * FROM inventories WHERE id = ?', { id })

  if not row then
    return nil
  end

  return remember(hydrate(row))
end

--- Reads the inventory of an owner, creating it on first access.
---@param ownerType string The owner kind, 'character' for a player.
---@param ownerId number The owner identifier.
---@param slots? number The slot count to create it with.
---@param maxWeight? number The weight cap to create it with.
---@return table? inventory The inventory, or nil when creation failed.
function GetOwnedInventory(ownerType, ownerId, slots, maxWeight)
  if type(ownerId) ~= 'number' then
    return nil
  end

  local key <const> = ownerType .. ':' .. ownerId
  local cachedId <const> = byOwner[key]

  if cachedId and cache[cachedId] then
    return cache[cachedId]
  end

  local row = MySQL.single.await(
    'SELECT * FROM inventories WHERE owner_type = ? AND owner_id = ?',
    { ownerType, ownerId }
  )

  if not row then
    local id <const> = MySQL.insert.await(
      'INSERT INTO inventories (owner_type, owner_id, slots, max_weight) VALUES (?, ?, ?, ?)',
      { ownerType, ownerId, slots or InventoryConfig.slots, maxWeight or InventoryConfig.maxWeight }
    )

    if not id then
      Siku.print.error(T('inventory_create_failed', ownerType, ownerId))

      return nil
    end

    row = MySQL.single.await('SELECT * FROM inventories WHERE id = ?', { id })
  end

  if not row then
    return nil
  end

  return remember(hydrate(row))
end

--- Reads the inventory addressed by a name rather than by a row identifier,
--- creating it on first access. A stash is found this way: what names it is
--- what the script that declared it chose, and, when it is personal, whoever
--- it belongs to.
---
--- The declared size is applied on every read, not only at creation: raising
--- the slots of a stash people already use gives them more room instead of
--- leaving the old shape frozen in database.
---@param ownerType string The owner kind.
---@param ownerKey string The name addressing the inventory.
---@param slots number The slot count it should have.
---@param maxWeight number The weight cap it should have.
---@param expiresAt? number When it should vanish, in epoch ms.
---@return table? inventory The inventory, or nil when creation failed.
function GetKeyedInventory(ownerType, ownerKey, slots, maxWeight, expiresAt)
  if type(ownerKey) ~= 'string' or ownerKey == '' then
    return nil
  end

  local key <const> = ownerType .. ':' .. ownerKey
  local cachedId <const> = byOwner[key]
  local cached <const> = cachedId and cache[cachedId] or nil

  if cached then
    if cached.slots ~= slots or cached.maxWeight ~= maxWeight then
      cached.slots = slots
      cached.maxWeight = maxWeight

      cached:touch()
    end

    return cached
  end

  local row = MySQL.single.await(
    'SELECT * FROM inventories WHERE owner_type = ? AND owner_key = ?',
    { ownerType, ownerKey }
  )

  if not row then
    local id <const> = MySQL.insert.await(
      'INSERT INTO inventories (owner_type, owner_key, slots, max_weight, expires_at) VALUES (?, ?, ?, ?, ?)',
      { ownerType, ownerKey, slots, maxWeight, expiresAt }
    )

    if not id then
      Siku.print.error(T('inventory_create_failed', ownerType, ownerKey))

      return nil
    end

    row = MySQL.single.await('SELECT * FROM inventories WHERE id = ?', { id })
  end

  if not row then
    return nil
  end

  local inventory <const> = remember(hydrate(row))

  if inventory.slots ~= slots or inventory.maxWeight ~= maxWeight then
    inventory.slots = slots
    inventory.maxWeight = maxWeight

    inventory:touch()
  end

  return inventory
end

--- Creates a standalone inventory with no owner, used for ground drops.
---@param coords vector3 Where the drop sits.
---@param expiresAt? number When the drop should vanish, in epoch ms.
---@return table? inventory The created inventory.
function CreateLooseInventory(coords, expiresAt)
  local id <const> = MySQL.insert.await(
    'INSERT INTO inventories (owner_type, slots, max_weight, x, y, z, expires_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
    { 'ground', 0, 0, coords.x, coords.y, coords.z, expiresAt }
  )

  if not id then
    Siku.print.error(T('inventory_create_failed', 'ground', 0))

    return nil
  end

  local row <const> = MySQL.single.await('SELECT * FROM inventories WHERE id = ?', { id })

  return row and remember(hydrate(row)) or nil
end

--- Writes an inventory back, replacing its stacks in one transaction so a
--- half-written inventory is never observable. The dirty flag is cleared
--- before the transaction is awaited: a change landing during the write
--- raises it again and is caught by the next save, whereas a second save
--- entering meanwhile finds nothing to do and cannot commit a staler
--- snapshot over a fresher one.
---@param inventory table The inventory to persist.
---@return nil
function SaveInventory(inventory)
  if not inventory or not inventory.dirty then
    return
  end

  inventory.dirty = false

  local queries <const> = {
    {
      query = 'UPDATE inventories SET slots = ?, max_weight = ? WHERE id = ?',
      values = { inventory.slots, inventory.maxWeight, inventory.id },
    },
    {
      query = 'DELETE FROM inventory_items WHERE inventory_id = ?',
      values = { inventory.id },
    },
  }

  for slot, stack in pairs(inventory.stacks) do
    queries[#queries + 1] = {
      query = 'INSERT INTO inventory_items (inventory_id, slot, item, count, metadata, uid, expires_at, uses) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      values = {
        inventory.id,
        tostring(slot),
        stack.item,
        stack.count,
        stack.metadata and json.encode(stack.metadata) or nil,
        stack.uid,
        stack.expiresAt,
        stack.uses,
      },
    }
  end

  local ok <const> = MySQL.transaction.await(queries)

  if not ok then
    inventory.dirty = true

    Siku.print.error(T('inventory_save_failed', inventory.id))
  end
end

--- Removes an inventory and everything it held.
---@param inventory table The inventory to delete.
---@return nil
function DeleteInventory(inventory)
  if not inventory then
    return
  end

  MySQL.update.await('DELETE FROM inventories WHERE id = ?', { inventory.id })

  forget(inventory)
end

--- Removes every inventory a name addresses, its personal copies included.
---
--- A container declared once resolves to one inventory when it is shared and
--- to one per owner when it is not, all of them stored under the same name.
--- Taking the container away has to take all of them, or the day the name is
--- used again its content comes back from the dead.
---@param ownerType string The owner kind.
---@param name string The name addressing the inventories.
---@return number removed The number of inventories deleted.
function DeleteKeyedInventories(ownerType, name)
  if type(name) ~= 'string' or name == '' then
    return 0
  end

  local prefix <const> = name .. ':'
  local doomed <const> = {}

  for _, inventory in pairs(cache) do
    if inventory.ownerType == ownerType and inventory.ownerKey then
      if inventory.ownerKey == name or inventory.ownerKey:sub(1, #prefix) == prefix then
        doomed[#doomed + 1] = inventory
      end
    end
  end

  for i = 1, #doomed do
    forget(doomed[i])
  end

  return MySQL.update.await(
    'DELETE FROM inventories WHERE owner_type = ? AND (owner_key = ? OR owner_key LIKE ?)',
    { ownerType, name, prefix .. '%' }
  ) or 0
end

--- Drops an inventory from the cache after writing it, when its owner leaves.
---@param inventory table The inventory to release.
---@return nil
function ReleaseInventory(inventory)
  if not inventory then
    return
  end

  SaveInventory(inventory)

  forget(inventory)
end

--- Walks every cached inventory.
---@param visitor function Called with each inventory.
---@return nil
function ForEachCachedInventory(visitor)
  for _, inventory in pairs(cache) do
    visitor(inventory)
  end
end

--- Writes every cached inventory that changed.
---@return number saved The number of inventories written.
function SaveAllInventories()
  local saved = 0

  for _, inventory in pairs(cache) do
    if inventory.dirty then
      SaveInventory(inventory)
      saved = saved + 1
    end
  end

  return saved
end

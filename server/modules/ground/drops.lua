local drops <const> = {}

--- Registers a drop so proximity lookups stay in memory rather than hitting
--- the database on every move.
---@param inventory table The drop inventory.
---@return nil
local function track(inventory)
  drops[inventory.id] = inventory
end

--- Forgets a drop.
---@param id number The drop identifier.
---@return nil
local function untrack(id)
  drops[id] = nil
end

--- Loads the drops left by a previous session, so a resource restart does not
--- swallow what was lying on the ground.
---@return nil
function LoadPersistedDrops()
  local rows <const> = MySQL.query.await(
    "SELECT id FROM inventories WHERE owner_type = 'ground'"
  ) or {}

  for i = 1, #rows do
    local inventory <const> = GetInventoryById(rows[i].id)

    if inventory then
      track(inventory)
    end
  end

  if #rows > 0 then
    Siku.print.debug(('Restored %d ground drop(s)'):format(#rows))
  end
end

--- Merges an instance into the drops already lying within reach, so that six
--- bottles put down one after another read as one stack rather than six.
--- Compatibility is asked of the same rule the inventory uses, which is what
--- keeps two different bank cards from ever becoming a stack of two.
---@param coords vector3 Where the stack lands.
---@param instance table The instance being dropped.
---@param count number The quantity still looking for a home.
---@return number merged The quantity absorbed by existing drops.
local function mergeIntoNearby(coords, instance, count)
  local nearby <const> = GetDropsNear(coords)
  local touched <const> = {}
  local remaining = count

  for i = 1, #nearby do
    if remaining <= 0 then
      break
    end

    local drop <const> = nearby[i]

    for slot, stack in pairs(drop.stacks) do
      if remaining <= 0 then
        break
      end

      if CanStack(stack, instance) then
        local room <const> = GetStackRoom(stack)
        local moved <const> = room == math.huge and remaining or math.min(room, remaining)

        if moved > 0 then
          stack.count = stack.count + moved
          stack.expiresAt = MergedExpiry(stack, instance)
          drop:setStack(slot, stack)
          touched[drop.id] = drop
          remaining = remaining - moved
        end
      end
    end
  end

  for _, drop in pairs(touched) do
    SaveInventory(drop)
  end

  return count - remaining
end

--- Puts an instance on the ground at a position, joining a compatible stack
--- already lying there when there is one and opening a new drop for whatever
--- is left over.
---@param coords vector3 Where the stack lands.
---@param instance table The instance to drop.
---@return boolean landed Whether the whole quantity found a place on the ground.
function CreateDrop(coords, instance)
  local merged <const> = mergeIntoNearby(coords, instance, instance.count)
  local remaining <const> = instance.count - merged

  if remaining <= 0 then
    return true
  end

  local lifetime <const> = InventoryConfig.dropLifetime
  local expiresAt <const> = lifetime > 0 and (os.time() * 1000 + lifetime) or nil
  local inventory <const> = CreateLooseInventory(coords, expiresAt)

  if not inventory then
    return false
  end

  inventory:setStack(1, {
    item = instance.item,
    count = remaining,
    metadata = instance.metadata,
    uid = instance.uid,
    expiresAt = instance.expiresAt,
    uses = instance.uses,
  })

  SaveInventory(inventory)
  track(inventory)

  return true
end

--- Removes a drop that has nothing left in it.
---@param inventory table The drop inventory.
---@return nil
function DiscardDropIfEmpty(inventory)
  if not inventory:isGround() or not inventory:isEmpty() then
    return
  end

  untrack(inventory.id)
  DeleteInventory(inventory)
  NotifyDropsChanged()
end

--- Lists the drops a position can reach.
---@param coords vector3 The position looking around.
---@return table found The drops within reach.
function GetDropsNear(coords)
  local radius <const> = InventoryConfig.groundDistance
  local found <const> = {}

  for _, inventory in pairs(drops) do
    if inventory.coords and #(inventory.coords - coords) <= radius then
      found[#found + 1] = inventory
    end
  end

  table.sort(found, function(a, b)
    return a.id < b.id
  end)

  return found
end

--- The identifiers of the drops a position can reach.
---
--- Putting something down may merge it into any of them, so a caller about to
--- do that takes their locks along with its own — in one call, so they are
--- all ordered together and two players dropping on the same spot queue
--- behind each other instead of deadlocking.
---@param coords vector3 The position looking around.
---@return table ids The reachable drop identifiers.
function GetNearbyDropIds(coords)
  local nearby <const> = GetDropsNear(coords)
  local ids <const> = {}

  for i = 1, #nearby do
    ids[i] = nearby[i].id
  end

  return ids
end

--- Whether a position may reach a given drop.
---@param inventory table The drop inventory.
---@param coords vector3 The position looking.
---@return boolean reachable Whether the drop is within reach.
function IsDropReachable(inventory, coords)
  if not inventory or not inventory.coords then
    return false
  end

  local radius <const> = InventoryConfig.groundDistance

  return #(inventory.coords - coords) <= radius
end

--- Reads a tracked drop.
---@param id number The drop identifier.
---@return table? drop The drop, or nil when it no longer exists.
function GetDrop(id)
  return drops[id]
end

--- Builds the ground payload a character sees: every reachable stack, flattened
--- into entries the interface can lay out in a grid.
---@param coords vector3 The position looking around.
---@return table entries The reachable stacks.
function BuildGroundPayload(coords)
  local nearby <const> = GetDropsNear(coords)
  local entries <const> = {}

  for i = 1, #nearby do
    local inventory <const> = nearby[i]

    for slot, stack in pairs(inventory.stacks) do
      local exposed <const> = BuildStackPayload(stack, slot)

      exposed.dropId = inventory.id
      entries[#entries + 1] = exposed
    end
  end

  return entries
end

--- Sweeps drops whose lifetime ran out.
---@return number removed The number of drops deleted.
function SweepExpiredDrops()
  if InventoryConfig.dropLifetime <= 0 then
    return 0
  end

  local now <const> = os.time() * 1000
  local expired <const> = {}

  for id, inventory in pairs(drops) do
    if inventory.expiresAt and inventory.expiresAt <= now then
      expired[#expired + 1] = id
    end
  end

  for i = 1, #expired do
    local inventory <const> = drops[expired[i]]

    untrack(expired[i])
    DeleteInventory(inventory)
  end

  if #expired > 0 then
    NotifyDropsChanged()
  end

  return #expired
end

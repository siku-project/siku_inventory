local SERIAL_PATTERN <const> = 'AA-1111-A'

local Inventory <const> = CreateClass('SikuInventory')

--- Builds the instance fields a fresh unit of an item starts life with. An
--- instance carried over from somewhere else keeps its own; only something
--- appearing for the first time is stamped here.
---@param item string The internal item identifier.
---@return number? expiresAt, number? uses When it spoils and how many uses it starts with, each nil when the kind has none.
local function freshInstance(item)
  local lifetime <const> = GetItemDecayLifetime(item)
  local expiresAt <const> = lifetime and (os.time() * 1000 + lifetime) or nil

  return expiresAt, GetItemUses(item)
end

--- Builds the metadata a stack starts life with. A kind that carries a serial
--- is stamped here, once, and never again: an instance arriving with one
--- already keeps it, which is what lets a weapon or a component change hands
--- and come back as the same object.
---@param item string The internal item identifier.
---@param metadata table? The metadata the incoming instance carried.
---@return table? metadata The metadata to store.
local function freshMetadata(item, metadata)
  if not IsItemSerialised(item) then
    return metadata
  end

  if type(metadata) == 'table' and metadata.serial then
    return metadata
  end

  local stamped <const> = metadata and Siku.table.merge({}, metadata) or {}

  stamped.serial = Siku.math.randomPattern(SERIAL_PATTERN)

  return stamped
end

--- Builds an inventory from a database row and its stacks.
---@param row table The `inventories` row.
---@param items table The `inventory_items` rows belonging to it.
---@return nil
function Inventory:constructor(row, items)
  self.id = row.id
  self.ownerType = row.owner_type
  self.ownerId = row.owner_id
  self.ownerKey = row.owner_key
  self.slots = row.slots
  self.maxWeight = row.max_weight
  self.expiresAt = row.expires_at
  self.coords = row.x and vector3(row.x, row.y, row.z) or nil
  self.stacks = {}
  self.dirty = false

  for i = 1, #items do
    local stored <const> = items[i]

    local slot <const> = tonumber(stored.slot) or stored.slot

    self.stacks[slot] = {
      item = stored.item,
      count = stored.count,
      metadata = stored.metadata and json.decode(stored.metadata) or nil,
      uid = stored.uid,
      expiresAt = stored.expires_at,
      uses = stored.uses,
    }
  end
end

--- Marks the inventory as needing a write.
---@return nil
function Inventory:touch()
  self.dirty = true
end

--- Total weight currently carried, in grams.
---@return number weight The carried weight.
function Inventory:getWeight()
  local total = 0

  for _, stack in pairs(self.stacks) do
    total = total + GetInstanceWeight(stack)
  end

  return total
end

--- Weight left before the inventory refuses more, in grams.
---@return number free The remaining capacity, math.huge when uncapped.
function Inventory:getFreeWeight()
  if self.maxWeight <= 0 then
    return math.huge
  end

  return math.max(0, self.maxWeight - self:getWeight())
end

--- Reads the stack sitting in a slot.
---@param slot number The slot number.
---@return table? stack The stack, or nil when the slot is empty.
function Inventory:getStack(slot)
  return self.stacks[slot]
end

--- Whether a slot identifier belongs to this inventory. Hotbar keys count as
--- part of it, but only for an inventory a character actually carries: a
--- stack lying on the ground has no hotbar to sit in.
---@param slot any The slot identifier.
---@return boolean valid Whether the slot exists.
function Inventory:isValidSlot(slot)
  if IsHotbarSlot(slot) then
    return self:isCharacter() and GetHotbarIndexOf(slot) ~= nil
  end

  if type(slot) ~= 'number' or slot % 1 ~= 0 then
    return false
  end

  if self.slots <= 0 then
    return slot >= 1
  end

  return slot >= 1 and slot <= self.slots
end

--- First slot holding nothing.
---@return number? slot The free slot, or nil when the inventory is full.
function Inventory:getFirstFreeSlot()
  local limit <const> = self.slots > 0 and self.slots or math.huge
  local slot = 1

  while slot <= limit do
    if not self.stacks[slot] then
      return slot
    end

    slot = slot + 1
  end

  return nil
end

--- Number of carried slots holding nothing. The hotbar is left out: it is
--- filled by a deliberate gesture, never by something dropping into the
--- inventory on its own.
---@return number count The free slot count.
function Inventory:getFreeSlotCount()
  if self.slots <= 0 then
    return math.huge
  end

  local used = 0

  for slot in pairs(self.stacks) do
    if not IsHotbarSlot(slot) then
      used = used + 1
    end
  end

  return self.slots - used
end

--- Finds the carried stacks an instance could merge into, nearest slot first.
--- Hotbar stacks are not candidates, so picking something up never silently
--- tops up what the player put on a key.
---@param instance table The incoming instance.
---@return table slots The candidate slot numbers.
function Inventory:findMergeableSlots(instance)
  local found <const> = {}

  for slot, stack in pairs(self.stacks) do
    local usable <const> = not IsHotbarSlot(slot)

    if usable and CanStack(stack, instance) and GetStackRoom(stack) > 0 then
      found[#found + 1] = slot
    end
  end

  SortSlots(found)

  return found
end

--- What taking something out would give back: the weight it was using, the
--- slots it would empty, and how much of it is actually there to take.
---
--- This is what makes an exchange answerable. Asking whether something fits
--- while what it replaces is still inside answers the wrong question: the room
--- being asked about is the room that is about to be freed.
---@param item string The internal item identifier.
---@param count number The quantity that would leave.
---@param metadata? table Restricts it to instances carrying these properties.
---@param strict? boolean Whether the whole metadata must be identical.
---@return number weight, number slots, number available The grams freed, the slots emptied, and the quantity actually there.
function Inventory:getRemovalRelief(item, count, metadata, strict)
  if not IsKnownItem(item) or type(count) ~= 'number' or count <= 0 then
    return 0, 0, 0
  end

  local matching <const> = {}

  for slot, stack in pairs(self.stacks) do
    if stack.item == item and MetadataMatches(stack.metadata, metadata, strict) then
      matching[#matching + 1] = slot
    end
  end

  SortSlots(matching)

  local unitWeight <const> = GetItemWeight(item)
  local remaining = count
  local weight = 0
  local slots = 0

  for i = 1, #matching do
    if remaining <= 0 then
      break
    end

    local slot <const> = matching[i]
    local stack <const> = self.stacks[slot]
    local taken <const> = math.min(remaining, stack.count)

    weight = weight + unitWeight * taken
    remaining = remaining - taken

    if taken >= stack.count then
      weight = weight + GetFittedWeight(stack)

      if not IsHotbarSlot(slot) then
        slots = slots + 1
      end
    end
  end

  return weight, slots, count - remaining
end

--- How much of an instance the inventory could actually take, weight and
--- slots and stack caps all considered.
---
--- The relief is what something on its way out would give back, for the
--- question of whether one thing fits once another has left.
---@param instance table The incoming instance, carrying at least its item.
---@param count number The wanted quantity.
---@param relief? table `weight` and `slots` freed by something leaving first.
---@return number accepted The quantity that fits, 0 when nothing does.
function Inventory:getAcceptedQuantity(instance, count, relief)
  if not IsKnownItem(instance.item) or type(count) ~= 'number' or count <= 0 then
    return 0
  end

  local freedWeight <const> = relief and relief.weight or 0
  local freedSlots <const> = relief and relief.slots or 0
  local unitWeight <const> = GetItemWeight(instance.item) + GetFittedWeight(instance)
  local byWeight = count

  if unitWeight > 0 then
    local free <const> = self:getFreeWeight() + freedWeight
    byWeight = free == math.huge and count or free // unitWeight
  end

  if byWeight <= 0 then
    return 0
  end

  local room = 0
  local mergeable <const> = self:findMergeableSlots(instance)

  for i = 1, #mergeable do
    local stackRoom <const> = GetStackRoom(self.stacks[mergeable[i]])

    if stackRoom == math.huge then
      return math.min(count, byWeight)
    end

    room = room + stackRoom
  end

  local freeSlots <const> = self:getFreeSlotCount() + freedSlots

  if freeSlots == math.huge then
    return math.min(count, byWeight)
  end

  local perSlot <const> = GetItemMaxStack(instance.item)
  room = room + freeSlots * (perSlot == math.huge and count or perSlot)

  return math.min(count, byWeight, room)
end

--- Whether the whole quantity fits.
---@param instance table The incoming instance.
---@param count number The wanted quantity.
---@return boolean fits Whether everything fits.
function Inventory:canCarry(instance, count)
  return self:getAcceptedQuantity(instance, count) >= count
end

--- Puts a quantity into one named slot, merging when it already holds
--- something compatible and opening it fresh when it is empty.
---
--- Kept apart from placing an instance that came from somewhere else: what
--- lands here is new to the world, so it is stamped — a serial, an identifier,
--- a shelf life — the same way it would be anywhere else in this inventory.
---@param slot number The slot to fill.
---@param instance table The incoming instance, carrying at least its item.
---@param count number The quantity wanted.
---@return number placed The quantity that went in.
function Inventory:fillSlot(slot, instance, count)
  local item <const> = instance.item
  local unitWeight <const> = GetItemWeight(item) + GetFittedWeight(instance)
  local free <const> = self:getFreeWeight()
  local byWeight = count

  if unitWeight > 0 and free ~= math.huge then
    byWeight = free // unitWeight
  end

  if byWeight <= 0 then
    return 0
  end

  local existing <const> = self.stacks[slot]

  if existing then
    if not CanStack(existing, instance) then
      return 0
    end

    local room <const> = GetStackRoom(existing)
    local merged <const> = math.min(count, byWeight, room == math.huge and count or room)

    if merged <= 0 then
      return 0
    end

    existing.count = existing.count + merged
    existing.expiresAt = MergedExpiry(existing, instance)

    self:touch()

    return merged
  end

  local perSlot <const> = GetItemMaxStack(item)
  local placed <const> = math.min(count, byWeight, perSlot == math.huge and count or perSlot)

  if placed <= 0 then
    return 0
  end

  local defaultExpiry <const>, defaultUses <const> = freshInstance(item)

  self.stacks[slot] = {
    item = item,
    count = placed,
    metadata = freshMetadata(item, instance.metadata),
    uid = instance.uid or (IsItemUnique(item) and Siku.math.randomUUIDv7() or nil),
    expiresAt = instance.expiresAt or defaultExpiry,
    uses = instance.uses or defaultUses,
  }

  self:touch()

  return placed
end

--- Puts a quantity in, merging into compatible stacks before opening new
--- slots. The instance passed in is the template: whatever identity,
--- freshness or remaining uses it carries follows it into its new home, and
--- only a stack with none of them is stamped as brand new.
---
--- Naming a slot asks for that one first. What it cannot take goes wherever it
--- would have gone anyway, so naming a slot is a preference rather than a
--- condition — a full slot never turns the whole thing into a refusal.
---@param instance table The incoming instance, carrying at least its item.
---@param count number The quantity to add.
---@param slot? number A slot to try before any other.
---@return number added The quantity actually stored.
function Inventory:addItem(instance, count, slot)
  if not IsKnownItem(instance.item) or type(count) ~= 'number' or count <= 0 then
    return 0
  end

  local placed <const> = slot ~= nil and self:isValidSlot(slot) and self:fillSlot(slot, instance, count) or 0
  local wanted <const> = count - placed

  if wanted <= 0 then
    return placed
  end

  local accepted <const> = self:getAcceptedQuantity(instance, wanted)

  if accepted <= 0 then
    return placed
  end

  local item <const> = instance.item
  local remaining = accepted

  if IsItemStackable(item) then
    local mergeable <const> = self:findMergeableSlots(instance)

    for i = 1, #mergeable do
      if remaining <= 0 then
        break
      end

      local stack <const> = self.stacks[mergeable[i]]
      local room <const> = GetStackRoom(stack)
      local moved <const> = room == math.huge and remaining or math.min(room, remaining)

      stack.count = stack.count + moved
      stack.expiresAt = MergedExpiry(stack, instance)
      remaining = remaining - moved
    end
  end

  local perSlot <const> = GetItemMaxStack(item)
  local defaultExpiry <const>, defaultUses <const> = freshInstance(item)
  local carried = placed > 0 and nil or instance.uid

  while remaining > 0 do
    local slot <const> = self:getFirstFreeSlot()

    if not slot then
      break
    end

    local portion <const> = perSlot == math.huge and remaining or math.min(perSlot, remaining)

    self.stacks[slot] = {
      item = item,
      count = portion,
      metadata = freshMetadata(item, instance.metadata),
      uid = carried or (IsItemUnique(item) and Siku.math.randomUUIDv7() or nil),
      expiresAt = instance.expiresAt or defaultExpiry,
      uses = instance.uses or defaultUses,
    }

    remaining = remaining - portion
    carried = nil
  end

  self:touch()

  return placed + accepted - remaining
end

--- Takes a quantity out of one slot. What comes back is a whole instance,
--- freshness and uses included, so it can be put down elsewhere unchanged.
---@param slot number The slot to draw from.
---@param count number The quantity to remove.
---@return table? taken The removed instance, or nil when nothing was taken.
function Inventory:takeFromSlot(slot, count)
  local stack <const> = self.stacks[slot]

  if not stack or type(count) ~= 'number' or count <= 0 then
    return nil
  end

  local moved <const> = math.min(count, stack.count)
  local taken <const> = {
    item = stack.item,
    count = moved,
    metadata = stack.metadata,
    uid = stack.uid,
    expiresAt = stack.expiresAt,
    uses = stack.uses,
  }

  if moved >= stack.count then
    self.stacks[slot] = nil
  else
    stack.count = stack.count - moved
  end

  self:touch()

  return taken
end

--- Takes a quantity of an item wherever it sits, nearest slot first.
---
--- A named slot is emptied before any other, and what it could not cover comes
--- from the rest — naming a slot says where to start, not where to stop.
---
--- Whatever is there is taken, up to the quantity asked for. Refusing to take
--- anything at all when there is not enough is a decision for the caller, not
--- for the primitive.
---@param item string The internal item identifier.
---@param count number The quantity to remove.
---@param metadata? table Restricts the removal to instances carrying it.
---@param strict? boolean Whether the whole metadata must be identical.
---@param slot? number A slot to empty before any other.
---@return number removed The quantity actually removed.
function Inventory:removeItem(item, count, metadata, strict, slot)
  if not IsKnownItem(item) or type(count) ~= 'number' or count <= 0 then
    return 0
  end

  local slots <const> = self:findSlots(item, metadata, strict)

  for i = 1, #slots do
    if slots[i] == slot then
      table.remove(slots, i)
      table.insert(slots, 1, slot)

      break
    end
  end

  local remaining = count

  for i = 1, #slots do
    if remaining <= 0 then
      break
    end

    local taken <const> = self:takeFromSlot(slots[i], remaining)

    if taken then
      remaining = remaining - taken.count
    end
  end

  return count - remaining
end

--- Total quantity of an item held.
---@param item string The internal item identifier.
---@param metadata? table Restricts the count to instances carrying it.
---@param strict? boolean Whether the whole metadata must be identical.
---@return number count The quantity held.
function Inventory:countItem(item, metadata, strict)
  local total = 0

  for _, stack in pairs(self.stacks) do
    if stack.item == item and MetadataMatches(stack.metadata, metadata, strict) then
      total = total + stack.count
    end
  end

  return total
end

--- Every slot holding an item, in slot order.
---
--- The hotbar is walked with the rest: a key holds a stack like any other, and
--- what comes back is the identifier it actually sits under, so a slot this
--- hands over can be read or emptied without translating anything.
---@param item string The internal item identifier.
---@param metadata? table Restricts it to instances carrying these properties.
---@param strict? boolean Whether the whole metadata must be identical.
---@return table slots The slot identifiers, in order.
function Inventory:findSlots(item, metadata, strict)
  local found <const> = {}

  for slot, stack in pairs(self.stacks) do
    if stack.item == item and MetadataMatches(stack.metadata, metadata, strict) then
      found[#found + 1] = slot
    end
  end

  SortSlots(found)

  return found
end

--- Finds the slot holding a unique instance.
---@param uid string The instance identifier.
---@return number? slot The slot, or nil when the instance is elsewhere.
function Inventory:findByUid(uid)
  for slot, stack in pairs(self.stacks) do
    if stack.uid == uid then
      return slot
    end
  end

  return nil
end

--- Drops a stack straight into a slot, without merging. Used when moving an
--- instance between inventories so its identity and metadata survive.
---@param slot number The destination slot.
---@param instance table The instance to place.
---@return nil
function Inventory:setStack(slot, instance)
  self.stacks[slot] = instance
  self:touch()
end

--- Whether the inventory is a character one.
---@return boolean owned Whether the inventory belongs to a character.
function Inventory:isCharacter()
  return self.ownerType == 'character'
end

--- Whether the inventory is a ground drop.
---@return boolean ground Whether the inventory is a drop.
function Inventory:isGround()
  return self.ownerType == 'ground'
end

--- Whether the inventory is a stash.
---@return boolean stash Whether the inventory is a stash.
function Inventory:isStash()
  return self.ownerType == 'stash'
end

--- Whether the inventory holds nothing.
---@return boolean empty Whether every slot is free.
function Inventory:isEmpty()
  return next(self.stacks) == nil
end

--- Builds the payload the interface reads. Metadata keys the catalogue does
--- not declare public never make it out of this function.
---@return table payload The inventory as the interface reads it.
function Inventory:toPayload()
  local stacks <const> = {}
  local hotbar <const> = {}

  for slot, stack in pairs(self.stacks) do
    local exposed <const> = BuildStackPayload(stack, slot)

    if IsHotbarSlot(slot) then
      hotbar[tostring(GetHotbarIndexOf(slot))] = exposed
    else
      stacks[tostring(slot)] = exposed
    end
  end

  return {
    id = self.id,
    ownerType = self.ownerType,
    slots = self.slots,
    maxWeight = self.maxWeight,
    weight = self:getWeight(),
    hotbar = hotbar,
    stacks = stacks,
  }
end

_G.SikuInventoryClass = Inventory

--- Resolves the inventory of a character. A character is named, never a
--- session: a behaviour that owns an item keeps working across a reconnection,
--- and nothing here depends on who happens to be online.
---@param characterId number The character id.
---@return table? inventory The inventory.
local function resolve(characterId)
  if type(characterId) ~= 'number' then
    return nil
  end

  return GetOwnedInventory('character', characterId)
end

--- Resolves whatever a caller named into a real inventory.
---
--- A number is a character, which is the only thing it has ever meant here.
--- Anything else says what it is out loud, because a container that is not a
--- character has no single number that could stand for it: a stash is named by
--- the script that declared it and, when it is personal, by whoever it belongs
--- to.
---@param target number|table The character id, or a table naming a container.
---@return table? inventory, string? reason The inventory, and why it was not found otherwise.
local function resolveTarget(target)
  local named = nil

  if type(target) == 'number' then
    named = resolve(target)
  elseif type(target) ~= 'table' then
    return nil, 'invalid_inventory'
  elseif type(target.character) == 'number' then
    named = resolve(target.character)
  else
    local definition <const> = GetStashDefinition(target.stash)

    if not definition then
      return nil, 'invalid_inventory'
    end

    local owner <const> = target.owner ~= nil and tostring(target.owner) or nil

    if definition.owner and not owner then
      return nil, 'invalid_owner'
    end

    named = GetStashInventory(definition, owner)
  end

  if not named then
    return nil, 'invalid_inventory'
  end

  return named
end

--- Reads one slot as an instance a caller can work with.
---
--- The one shape an instance leaves this file in, so a stack found by slot, by
--- name or by identifier always reads the same. The weight is the instance's
--- own — what this stack actually weighs, parts bolted to it included — rather
--- than what one unit of its kind weighs.
---
--- The metadata is a copy: rewriting it changes nothing, which is what
--- SetItemMetadata is for.
---@param inventory table? The container to read from.
---@param slot any The slot to read.
---@return table? instance The instance, or nil when the slot holds nothing.
local function describeSlot(inventory, slot)
  local stack <const> = inventory and inventory:getStack(slot) or nil

  if not stack then
    return nil
  end

  return {
    slot = slot,
    item = stack.item,
    count = stack.count,
    weight = GetInstanceWeight(stack),
    uid = stack.uid,
    uses = stack.uses,
    expiresAt = stack.expiresAt,
    metadata = stack.metadata and Siku.table.deepClone(stack.metadata) or nil,
  }
end

--- Reads a whole container: what it is, how big it is, and everything in it.
---
--- The contents come back as one list in slot order, hotbar included, each
--- entry the same instance shape every other read answers with. The interface
--- reads a different shape — keyed by slot, with the hotbar split out — and
--- that one stays the interface's, because a script walking a container wants
--- a list rather than a map with string keys.
---
--- `id` is what a caller would pass back here: the character id for a bag, the
--- stash name for a stash. The row identifier it happens to have in database
--- is nobody's business and stays where it is.
---@param target number|table The character id, or `{ stash = name, owner = ? }`.
---@return table? inventory What the container is and what it holds.
function GetInventory(target)
  local inventory <const> = resolveTarget(target)

  if not inventory then
    return nil
  end

  local ordered <const> = {}

  for slot in pairs(inventory.stacks) do
    ordered[#ordered + 1] = slot
  end

  SortSlots(ordered)

  local items <const> = {}

  for i = 1, #ordered do
    items[i] = describeSlot(inventory, ordered[i])
  end

  local answer <const> = {
    id = inventory.ownerId,
    type = inventory.ownerType,
    owner = inventory.ownerId,
    slots = inventory.slots,
    maxWeight = inventory.maxWeight,
    weight = inventory:getWeight(),
    freeSlots = inventory:getFreeSlotCount(),
    items = items,
  }

  if type(target) == 'table' and target.stash ~= nil then
    local definition <const> = GetStashDefinition(target.stash)

    if definition then
      answer.id = definition.name
      answer.label = definition.label
      answer.owner = target.owner
    end
  end

  return answer
end

--- Counts how much of an item a container holds.
---
--- The properties are matched partially: naming one of them counts every
--- instance carrying it, whatever else it carries. Asking strictly counts only
--- the instances whose whole metadata is that and nothing else — rarely what a
--- caller means, since a real instance carries more than the one line they
--- were thinking of. Removing answers the same way, so counting and then
--- taking never disagree.
---@param target number|table The character id, or `{ stash = name, owner = ? }`.
---@param item string The internal item identifier.
---@param metadata? table The properties an instance must carry to be counted.
---@param strict? boolean Whether the whole metadata must be identical.
---@return number count The quantity held.
function GetItemCount(target, item, metadata, strict)
  local inventory <const> = resolveTarget(target)

  return inventory and inventory:countItem(item, metadata, strict) or 0
end

--- Where an item sits in a container, how much of it there is, and what room
--- is left over.
---
--- Three answers a caller usually wants together, in one table rather than
--- three returns nobody remembers the order of. The slots come back in order,
--- each carrying its own instance, so one of them can be handed straight to
--- AddItem or RemoveItem.
---
--- The hotbar is walked with the rest, and the slot numbers are real ones.
---@param target number|table The character id, or `{ stash = name, owner = ? }`.
---@param item string The internal item identifier.
---@param metadata? table Restricts it to instances carrying these properties.
---@param strict? boolean Whether the whole metadata must be identical.
---@return table answer `slots` holding it, the total `count`, and `freeSlots` left.
function GetItemSlots(target, item, metadata, strict)
  local inventory <const> = resolveTarget(target)

  if not inventory or not IsKnownItem(item) then
    return { slots = {}, count = 0, freeSlots = 0 }
  end

  local found <const> = inventory:findSlots(item, metadata, strict)
  local slots <const> = {}
  local count = 0

  for i = 1, #found do
    local instance <const> = describeSlot(inventory, found[i])

    count = count + instance.count
    slots[i] = instance
  end

  return {
    slots = slots,
    count = count,
    freeSlots = inventory:getFreeSlotCount(),
  }
end

--- Reads whatever sits in a slot.
---
--- Nil when the slot holds nothing, and nil just the same when what was named
--- is not a slot this container has: a caller asking about it is asking about
--- somewhere nothing can be, and both answers are the same answer.
---@param target number|table The character id, or `{ stash = name, owner = ? }`.
---@param slot number|string The slot to read, a hotbar key included.
---@return table? instance The instance, or nil when the slot is empty.
function GetSlot(target, slot)
  return describeSlot(resolveTarget(target), slot)
end

--- What a container still has room for.
---
--- One question, asked three ways, answered the same way every time. Naming an
--- item and a quantity asks whether that fits; naming an item alone asks how
--- many of it would; naming a weight asks whether those grams fit; naming
--- nothing just reads what is left. Whatever was asked, what comes back is the
--- same table, so a caller reads the field they care about instead of
--- remembering which shape this call answers in.
---
--- Weight and slots are both accounted for, not just weight: a bag with room
--- to spare and nowhere to put anything cannot take a thing.
---
--- One item at a time. Whether a whole batch fits is a different question —
--- the weight of each one eats into what is left for the next — and answering
--- it item by item would say yes to a batch that does not fit.
---
--- `without` asks the question an exchange needs: whether something fits once
--- what it replaces has left. A craft turning ten pieces of iron into a sword
--- does not fit in a full bag until the iron is gone, and asking while it is
--- still there answers about room that is about to be freed. What could not be
--- taken out is answered as `removable`, and an exchange that cannot take out
--- what it promised does not fit whatever the weight says.
---
--- An uncapped container answers math.huge for its free weight, because it has
--- none to name: comparing against it still reads correctly, and capping a
--- quantity with it gives the quantity back untouched.
---@param target number|table The character id, or `{ stash = name, owner = ? }`.
---@param request? table `item` and `count`, or `metadata`, or `weight`, or `without`.
---@return table answer `fits`, `freeWeight`, `freeSlots`, plus `room` and `removable` when asked.
function CanCarryItem(target, request)
  local inventory <const> = resolveTarget(target)

  if not inventory then
    return { fits = false, freeWeight = 0, freeSlots = 0 }
  end

  local wanted <const> = type(request) == 'table' and request or {}
  local leaving <const> = type(wanted.without) == 'table' and wanted.without or nil
  local relief = nil

  local answer <const> = {
    fits = true,
    freeWeight = inventory:getFreeWeight(),
    freeSlots = inventory:getFreeSlotCount(),
  }

  if leaving then
    local asked <const> = type(leaving.count) == 'number' and leaving.count or 1
    local weight <const>, slots <const>, available <const> = inventory:getRemovalRelief(
      leaving.item,
      asked,
      leaving.metadata,
      leaving.strict
    )

    relief = { weight = weight, slots = slots }
    answer.freeWeight = answer.freeWeight + weight
    answer.freeSlots = answer.freeSlots + slots
    answer.removable = available

    if available < asked then
      answer.fits = false
    end
  end

  if type(wanted.weight) == 'number' then
    answer.fits = answer.fits and wanted.weight <= answer.freeWeight
  end

  if wanted.item == nil then
    return answer
  end

  if not IsKnownItem(wanted.item) then
    answer.fits = false
    answer.room = 0

    return answer
  end

  local count <const> = type(wanted.count) == 'number' and wanted.count or 1

  answer.room = inventory:getAcceptedQuantity(
    { item = wanted.item, metadata = wanted.metadata },
    math.maxinteger,
    relief
  )
  answer.fits = answer.fits and answer.room >= count

  return answer
end

--- Changes how much a container may hold, in grams.
---
--- Zero means no cap at all, which is what a container holding anything at any
--- weight is declared with.
---
--- Lowering it below what is already inside destroys nothing. The container
--- simply refuses more until enough has been taken out — the same way lowering
--- a slot count leaves what sits beyond the new limit where it is.
---
--- A stash is sized by its declaration, and its inventory is re-sized from it
--- every time it is read. Naming one here rewrites the declaration too, or the
--- new weight would be undone by the next thing that opened it. That lasts as
--- long as the resource runs; changing it for good means changing the
--- declaration, in shared/stashes.lua or through RegisterStash.
---@param target number|table The character id, or `{ stash = name, owner = ? }`.
---@param maxWeight number The cap in grams, zero for none.
---@return boolean set, string? reason Whether the cap changed, and why it did not.
function SetMaxWeight(target, maxWeight)
  if type(maxWeight) ~= 'number' or maxWeight % 1 ~= 0 or maxWeight < 0 then
    return false, 'invalid_weight'
  end

  local inventory <const>, reason <const> = resolveTarget(target)

  if not inventory then
    return false, reason
  end

  if type(target) == 'table' and target.stash ~= nil then
    local definition <const> = GetStashDefinition(target.stash)

    if definition then
      definition.maxWeight = maxWeight
    end
  end

  inventory.maxWeight = maxWeight

  inventory:touch()
  SaveInventory(inventory)
  NotifyInventoryChanged(inventory)
  NotifyContainerChanged(inventory.id)

  return true
end

--- Puts a quantity of an item into a container.
---
--- What comes back is how much actually went in, which is not always what was
--- asked for: a bag with room for two of the four takes two. Zero comes with
--- the reason, so a caller can tell an item nobody declared from a container
--- that has nothing left in it.
---
--- Naming a slot asks for that one first; whatever it cannot take goes
--- wherever it would have gone anyway, so a full slot is a preference ignored
--- rather than a refusal.
---@param target number|table The character id, or `{ stash = name, owner = ? }`.
---@param item string The internal item identifier.
---@param count number The quantity.
---@param metadata? table The metadata the instance carries.
---@param slot? number A slot to try before any other.
---@return number added, string? reason The quantity stored, and why none was otherwise.
function AddItem(target, item, count, metadata, slot)
  local inventory <const>, reason <const> = resolveTarget(target)

  if not inventory then
    return 0, reason
  end

  if not IsKnownItem(item) then
    return 0, 'invalid_item'
  end

  if type(count) ~= 'number' or count % 1 ~= 0 or count < 1 then
    return 0, 'invalid_count'
  end

  if metadata ~= nil and type(metadata) ~= 'table' then
    return 0, 'invalid_metadata'
  end

  local added <const> = WithInventoryLock({ inventory.id }, function()
    return inventory:addItem({ item = item, metadata = metadata }, count, slot)
  end) or 0

  if added <= 0 then
    return 0, 'no_room'
  end

  SaveInventory(inventory)
  NotifyInventoryChanged(inventory)
  NotifyContainerChanged(inventory.id)

  return added
end

--- Takes a quantity of an item out of a container.
---
--- All of it or none of it. A caller taking payment for something wants five
--- hundred or a refusal, never three hundred and a half-finished transaction —
--- so a container holding less than what was asked for keeps everything, and
--- says so. `partial` is how a caller asks for whatever is there instead.
---
--- The properties are matched the way they are matched everywhere else in this
--- resource: partially unless told otherwise. Naming one property removes an
--- instance carrying it, whatever else it carries — which is what a caller who
--- just counted the same way expects to happen next.
---
--- Naming a slot empties that one first; what it could not cover comes from
--- wherever else the item sits.
---@param target number|table The character id, or `{ stash = name, owner = ? }`.
---@param item string The internal item identifier.
---@param count number The quantity.
---@param metadata? table Restricts the removal to instances carrying it.
---@param slot? number A slot to empty before any other.
---@param partial? boolean Whether taking less than asked for is acceptable.
---@param strict? boolean Whether the whole metadata must be identical.
---@return number removed, string? reason The quantity removed, and why none was otherwise.
function RemoveItem(target, item, count, metadata, slot, partial, strict)
  local inventory <const>, reason <const> = resolveTarget(target)

  if not inventory then
    return 0, reason
  end

  if not IsKnownItem(item) then
    return 0, 'invalid_item'
  end

  if type(count) ~= 'number' or count % 1 ~= 0 or count < 1 then
    return 0, 'invalid_count'
  end

  if metadata ~= nil and type(metadata) ~= 'table' then
    return 0, 'invalid_metadata'
  end

  local removed <const> = WithInventoryLock({ inventory.id }, function()
    if not partial and inventory:countItem(item, metadata, strict) < count then
      return 0
    end

    return inventory:removeItem(item, count, metadata, strict, slot)
  end) or 0

  if removed <= 0 then
    return 0, 'not_enough_items'
  end

  SaveInventory(inventory)
  NotifyInventoryChanged(inventory)
  NotifyContainerChanged(inventory.id)

  return removed
end

--- Empties a container, destroying what was in it.
---
--- This is not a confiscation and nothing comes back: what leaves here is
--- gone. ConfiscateInventory is the one that keeps things aside to be handed
--- over later.
---
--- `keep` names what survives, by item name — one name or a list of them.
--- Metadata plays no part: keeping bank cards keeps every bank card, whoever
--- they belong to.
---@param target number|table The character id, or `{ stash = name, owner = ? }`.
---@param keep? string|table The item names to leave where they are.
---@return number removed, string? reason The quantity destroyed, and why none was otherwise.
function ClearInventory(target, keep)
  local inventory <const>, reason <const> = resolveTarget(target)

  if not inventory then
    return 0, reason
  end

  local kept <const> = {}

  if type(keep) == 'string' then
    kept[keep] = true
  elseif type(keep) == 'table' then
    for i = 1, #keep do
      if type(keep[i]) == 'string' then
        kept[keep[i]] = true
      end
    end
  end

  local removed <const> = WithInventoryLock({ inventory.id }, function()
    local doomed <const> = {}

    for slot, stack in pairs(inventory.stacks) do
      if not kept[stack.item] then
        doomed[#doomed + 1] = slot
      end
    end

    SortSlots(doomed)

    local count = 0

    for i = 1, #doomed do
      local taken <const> = inventory:takeFromSlot(doomed[i], math.maxinteger)

      if taken then
        count = count + taken.count
      end
    end

    return count
  end) or 0

  if removed <= 0 then
    return 0, 'empty_slot'
  end

  SaveInventory(inventory)
  NotifyInventoryChanged(inventory)
  NotifyContainerChanged(inventory.id)

  return removed
end

--- Reads the weapon a player has in hand.
---
--- A player, not a container: a stash holds weapons but nobody is holding
--- them, and what is drawn belongs to whoever is standing there rather than to
--- the bag it came out of. Every other export here names a character because a
--- character outlives a connection — this one cannot, because putting a weapon
--- away is something that happens to a session.
---
--- Answers nil with empty hands, which is the ordinary case and not a failure.
---
--- The fields are the ones the client answers with, so a script reading either
--- side reads the same thing — with two it cannot know. There is no
--- `magazine`, because how many rounds a weapon holds is measured on the ped
--- with its parts fitted and only the client can ask. And `ammo` is the last
--- count the client reported rather than the one in the chamber this instant:
--- between two reports the client is the only side that knows.
---@param sessionId number The player server id.
---@return table? weapon The weapon in hand.
function GetCurrentWeapon(sessionId)
  local uid <const> = GetSessionDrawnWeapon(sessionId)

  if not uid then
    return nil
  end

  local inventory <const> = GetSessionInventory(sessionId)

  if not inventory then
    return nil
  end

  local slot <const> = inventory:findByUid(uid)
  local instance <const> = describeSlot(inventory, slot)

  if not instance or not IsWeaponItem(instance.item) then
    return nil
  end

  local stack <const> = inventory:getStack(slot)
  local definition <const> = GetItemDefinition(instance.item)
  local takesAmmo <const> = DoesWeaponTakeAmmo(instance.item)

  instance.name = definition and definition.name or instance.item
  instance.label = definition and definition.label or instance.item
  instance.melee = definition ~= nil and definition.category == 'melee'
  instance.ammoItem = takesAmmo and definition.ammoType or nil
  instance.ammo = takesAmmo and GetLoadedAmmo(stack) or nil
  instance.components = GetFittedComponents(stack)
  instance.serial = instance.metadata and instance.metadata.serial or nil
  instance.hotbar = IsHotbarSlot(slot) and GetHotbarIndexOf(slot) or nil

  return instance
end

--- Reads a unique instance wherever it sits in a container.
---@param target number|table The character id, or `{ stash = name, owner = ? }`.
---@param uid string The instance identifier.
---@return table? instance The instance, metadata included.
function GetItemByUid(target, uid)
  local inventory <const> = resolveTarget(target)

  if not inventory then
    return nil
  end

  return describeSlot(inventory, inventory:findByUid(uid))
end

--- Rewrites the metadata of a unique instance. This is how an instance keeps
--- its own history: the value follows the object, not its holder. A value the
--- writer could not encode is refused here rather than at save time, where a
--- failing transaction would stall every later write of that inventory.
---@param target number|table The character id, or `{ stash = name, owner = ? }`.
---@param uid string The instance identifier.
---@param metadata table The metadata to store.
---@return boolean updated, string? reason Whether the instance was rewritten, and why it was not.
function SetItemMetadata(target, uid, metadata)
  local inventory <const>, reason <const> = resolveTarget(target)

  if not inventory then
    return false, reason
  end

  if type(metadata) ~= 'table' then
    return false, 'invalid_metadata'
  end

  if not pcall(json.encode, metadata) then
    return false, 'invalid_metadata'
  end

  local updated <const> = WithInventoryLock({ inventory.id }, function()
    local slot <const> = inventory:findByUid(uid)

    if not slot then
      return false
    end

    inventory:getStack(slot).metadata = metadata
    inventory:touch()

    return true
  end)

  if not updated then
    return false, 'empty_slot'
  end

  SaveInventory(inventory)
  NotifyInventoryChanged(inventory)

  return true
end

--- Every item kind the resource knows, keyed by identifier.
---
--- This is a big table and it is rebuilt on every call, so a caller that needs
--- it more than once should hold on to what comes back rather than asking
--- again. Wanting a single kind is the common case, and GetItem answers that
--- one without building the rest.
---@return table items Every declared kind.
function GetItems()
  return GetItemCatalogue()
end

--- One item kind, as the interface reads it.
---
--- Nil when nothing goes by that name. A kind nobody declared is not an empty
--- kind: a caller asking about it asked about something that does not exist,
--- and saying so beats handing back a shape that would look real.
---@param item string The internal item identifier.
---@return table? definition The declared kind.
function GetItem(item)
  if not IsKnownItem(item) then
    return nil
  end

  return GetItemDefinitionPayload(item)
end

--- Declares a stash, or redeclares one that already exists.
---
--- The content is never touched: a stash is found in database by its
--- identifier, so declaring it again after a restart, or with more room than
--- it had yesterday, finds exactly what was left in it.
---@param id string|number The stash identifier.
---@param label string The name shown at the top of the panel.
---@param slots number How many slots it holds.
---@param maxWeight number How many grams it holds.
---@param owner? string|boolean True for one per character, a string to bind it to a name, nil to share it.
---@param groups? table The jobs allowed to open it, each mapped to a minimum grade.
---@param coords? vector3|table Where it can be opened from, one position or several.
---@param options? table `distance`, `instance` and `icon`.
---@return boolean registered, string? reason Whether the stash was accepted, and why it was not.
function RegisterStash(id, label, slots, maxWeight, owner, groups, coords, options)
  local extra <const> = type(options) == 'table' and options or {}

  local definition <const>, reason <const> = RegisterStashDefinition({
    name = type(id) == 'number' and tostring(id) or id,
    label = label,
    slots = slots,
    maxWeight = maxWeight,
    owner = owner,
    groups = groups,
    coords = coords,
    distance = extra.distance,
    instance = extra.instance,
    icon = extra.icon,
  })

  if not definition then
    return false, reason
  end

  if definition.coords then
    PublishStashPoints()
  end

  return true
end

--- Forgets a stash. What was in it stays in database: a stash nobody declares
--- is a stash nobody can open, not one that was emptied. Declaring it again
--- under the same identifier finds it as it was.
---@param id string|number The stash identifier.
---@return boolean removed Whether a stash went by that identifier.
function UnregisterStash(id)
  local definition <const> = GetStashDefinition(id)

  if not definition or not UnregisterStashDefinition(definition.name) then
    return false
  end

  CloseContainersOf('stash', definition.name, 'unreachable')

  if definition.coords then
    PublishStashPoints()
  end

  return true
end

--- Tells every client what the runtime display list holds now.
---@param sessionId? number A single session, or nil for everyone.
---@return nil
function PublishMetadataDisplay(sessionId)
  TriggerClientEvent(
    'siku_inventory:client:setMetadataDisplay',
    sessionId or -1,
    GetRegisteredMetadataDisplay()
  )
end

PublishMetadataDisplay = publishMetadataDisplay

--- Makes a metadata property visible on every item that carries one.
---
--- Nothing in this resource shows a property nobody declared, and the same
--- list decides what leaves the server at all: a property named here becomes
--- public wherever it is stored, which is why this is a server export and not
--- something a screen may decide for itself.
---
--- A property an item already declares for itself keeps that declaration.
---
--- Three shapes say it. A property and its label; a table of properties and
--- their labels, read alphabetically; or a list, which keeps the order it was
--- written in and may also say how each value should be read — `text`,
--- `number`, `percent`, `money` or `date`.
---@param source string|table The property key, or the properties to show.
---@param label? string The label, when a single property was named.
---@return boolean shown Whether anything was taken.
function DisplayMetadata(source, label)
  local fields <const> = ReadMetadataDisplay(source, label)

  if #fields == 0 then
    return false
  end

  RegisterMetadataDisplay(fields)
  PublishMetadataDisplay()

  return true
end

--- Takes a property back out of the display list, and out of what leaves the
--- server with it. What an item declares for itself is untouched.
---@param keys string|table The property key, or several of them.
---@return boolean hidden Whether anything was dropped.
function HideMetadata(keys)
  local wanted <const> = type(keys) == 'string' and { keys } or keys

  if type(wanted) ~= 'table' or HideMetadataDisplay(wanted) == 0 then
    return false
  end

  PublishMetadataDisplay()

  return true
end

exports('GetInventory', GetInventory)
exports('GetItemCount', GetItemCount)
exports('GetItemSlots', GetItemSlots)
exports('GetSlot', GetSlot)
exports('CanCarryItem', CanCarryItem)
exports('SetMaxWeight', SetMaxWeight)
exports('AddItem', AddItem)
exports('RemoveItem', RemoveItem)
exports('ClearInventory', ClearInventory)
exports('GetItemByUid', GetItemByUid)
exports('GetCurrentWeapon', GetCurrentWeapon)
exports('SetItemMetadata', SetItemMetadata)
exports('GetItems', GetItems)
exports('GetItem', GetItem)
exports('DisplayMetadata', DisplayMetadata)
exports('HideMetadata', HideMetadata)
exports('RegisterStash', RegisterStash)
exports('UnregisterStash', UnregisterStash)

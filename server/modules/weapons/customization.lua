--- Finds a weapon instance the character actually carries.
---@param inventory table The character inventory.
---@param uid string The weapon instance identifier.
---@return number? slot, table? stack The slot holding the weapon and the stack sitting in it.
local function findWeapon(inventory, uid)
  if type(uid) ~= 'string' then
    return nil, nil
  end

  local slot <const> = inventory:findByUid(uid)

  if not slot then
    return nil, nil
  end

  local stack <const> = inventory:getStack(slot)

  if not stack or not IsWeaponItem(stack.item) then
    return nil, nil
  end

  return slot, stack
end

--- Reads the wanted component map a client sent, keeping only what is shaped
--- like a real answer. A malformed payload is rejected whole rather than
--- partially understood.
---
--- Whether the game accepts a given component on a given weapon is a question
--- only the client can ask, and its answer is not trusted: what is enforced
--- here is everything that touches the economy — the item exists, it is a
--- component, it belongs in the slot it claims, and no instance is named
--- twice. A forged payload naming a part the engine will refuse costs the
--- player their own component and nothing else.
---@param payload any The value received.
---@return table? wanted The wanted components, keyed by slot.
local function readWanted(payload)
  if payload == nil then
    return {}
  end

  if type(payload) ~= 'table' then
    return nil
  end

  local wanted <const> = {}
  local seen <const> = {}

  for slot, item in pairs(payload) do
    if not IsKnownWeaponSlot(slot) or type(item) ~= 'string' then
      return nil
    end

    if not IsComponentItem(item) or GetComponentSlot(item) ~= slot then
      return nil
    end

    if seen[item] then
      return nil
    end

    seen[item] = true
    wanted[slot] = item
  end

  return wanted
end

--- Lists every component a character is carrying. The client then asks the
--- engine which of them the weapon in front of it accepts, and the ones it
--- refuses never reach the panel.
---
--- Which game components an item stands for is not sent: the client reads
--- that from the shared declarations it already has, so the list stays a
--- handful of short strings rather than every variant of every part carried.
---@param inventory table The character inventory.
---@return table available The carried components, in slot order.
local function listAvailable(inventory)
  local carried <const> = {}

  for slot, stack in pairs(inventory.stacks) do
    if not IsHotbarSlot(slot) and IsComponentItem(stack.item) then
      carried[#carried + 1] = { slot = slot, item = stack.item }
    end
  end

  table.sort(carried, function(a, b)
    return CompareSlots(a.slot, b.slot)
  end)

  local available <const> = {}

  for i = 1, #carried do
    available[i] = {
      item = carried[i].item,
      componentSlot = GetComponentSlot(carried[i].item),
    }
  end

  return available
end

--- Builds everything the customization view needs to open.
---@param sessionId number The player server id.
---@param uid string The weapon instance identifier.
---@return table? payload, string? reason The view payload, and why it could not be opened otherwise.
function BuildCustomizationPayload(sessionId, uid)
  local inventory <const> = GetSessionInventory(sessionId)

  if not inventory then
    return nil, 'no_character'
  end

  local slot <const>, stack <const> = findWeapon(inventory, uid)

  if not slot or not stack then
    return nil, 'unknown_weapon'
  end

  return {
    weapon = {
      uid = stack.uid,
      item = stack.item,
      name = GetItemDefinition(stack.item).name,
      ammoType = GetItemDefinition(stack.item).ammoType,
      metadata = FilterPublicMetadata(stack.item, stack.metadata),
      components = GetFittedComponents(stack),
    },
    slots = GetWeaponSlotPayload(),
    available = listAvailable(inventory),
  }
end

--- Applies a finished customization. Everything is checked before anything
--- moves: the components to fit have to be carried, the ones being taken off
--- have to fit back, and only then is a single atomic change written.
---
--- The weapon is rewritten before anything is handed back. A fitted part still
--- weighs on the character, so a component listed on the weapon and lying in
--- the grid at the same time would be counted twice — and the return refused
--- for a weight the character does not actually carry.
---@param sessionId number The player server id.
---@param uid string The weapon instance identifier.
---@param wantedPayload any The components the player settled on.
---@return boolean committed, string? reason Whether the change was applied, and why it was refused otherwise.
function CommitCustomization(sessionId, uid, wantedPayload)
  local inventory <const> = GetSessionInventory(sessionId)

  if not inventory then
    return false, 'no_character'
  end

  return WithInventoryLock({ inventory.id }, function()
    local slot <const>, stack <const> = findWeapon(inventory, uid)

    if not slot or not stack then
      return false, 'unknown_weapon'
    end

    local wanted <const> = readWanted(wantedPayload)

    if not wanted then
      return false, 'invalid_request'
    end

    local fitted <const> = GetFittedInstances(stack)
    local toFit <const> = {}
    local toReturn <const> = {}

    for componentSlot, item in pairs(wanted) do
      local current <const> = fitted[componentSlot]

      if not current or current.item ~= item then
        toFit[#toFit + 1] = { slot = componentSlot, item = item }
      end
    end

    for componentSlot, instance in pairs(fitted) do
      if wanted[componentSlot] ~= instance.item then
        toReturn[#toReturn + 1] = instance
      end
    end

    local reserved <const> = {}
    local claimed <const> = {}

    for i = 1, #toFit do
      local item <const> = toFit[i].item
      local found = nil

      for carriedSlot, carried in pairs(inventory.stacks) do
        local usable <const> = not IsHotbarSlot(carriedSlot) and not claimed[carriedSlot]

        if usable and carried.item == item then
          found = carriedSlot
          break
        end
      end

      if not found then
        return false, 'missing_component'
      end

      claimed[found] = true
      reserved[#reserved + 1] = found
    end

    local freed <const> = #reserved
    local room <const> = inventory:getFreeSlotCount()

    if room ~= math.huge and #toReturn > room + freed then
      return false, 'no_free_slot'
    end

    local mounted <const> = {}

    for i = 1, #reserved do
      mounted[toFit[i].slot] = inventory:takeFromSlot(reserved[i], 1)
    end

    local components = nil

    for componentSlot, item in pairs(wanted) do
      local instance <const> = mounted[componentSlot] or fitted[componentSlot]

      components = components or {}
      components[componentSlot] = {
        item = item,
        uid = instance and instance.uid or nil,
        metadata = instance and instance.metadata or nil,
      }
    end

    local metadata <const> = stack.metadata and Siku.table.deepClone(stack.metadata) or {}

    metadata.components = components
    stack.metadata = metadata

    for i = 1, #toReturn do
      if inventory:addItem(toReturn[i], 1) < 1 then
        return false, 'no_free_slot'
      end
    end

    inventory:touch()

    return true
  end)
end

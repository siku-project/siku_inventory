--- Finds a weapon instance a character actually carries.
---@param inventory table The character inventory.
---@param uid any The weapon instance identifier.
---@return number? slot, table? stack The slot holding the weapon and the stack sitting in it.
local function findWeapon(inventory, uid)
  if type(uid) ~= 'string' then
    return nil, nil
  end

  local slot <const> = inventory:findByUid(uid)
  local stack <const> = slot and inventory:getStack(slot) or nil

  if not stack or not IsWeaponItem(stack.item) then
    return nil, nil
  end

  return slot, stack
end

--- Loads a weapon from what the character is carrying.
---@param sessionId number The player server id.
---@param uid any The weapon instance identifier.
---@param magazine any The capacity the client read off the engine.
---@return table? loaded, string? reason What the weapon holds now, and why nothing moved otherwise.
function ReloadWeapon(sessionId, uid, magazine)
  local inventory <const> = GetSessionInventory(sessionId)

  if not inventory then
    return nil, 'no_character'
  end

  local capacity <const> = ReadMagazine(magazine)

  if not capacity then
    return nil, 'invalid_request'
  end

  return WithInventoryLock({ inventory.id }, function()
    local slot <const>, stack <const> = findWeapon(inventory, uid)

    if not stack then
      return nil, 'unknown_weapon'
    end

    local ammoItem <const> = GetWeaponAmmoItem(stack.item)

    if not ammoItem then
      return nil, 'takes_no_ammo'
    end

    local loaded <const> = GetLoadedAmmo(stack)
    local room <const> = capacity - loaded

    if room <= 0 then
      return nil, 'already_loaded'
    end

    local carried <const> = inventory:countItem(ammoItem)

    if carried <= 0 then
      return nil, 'no_ammo'
    end

    local moved <const> = math.min(room, carried)
    local taken <const> = inventory:removeItem(ammoItem, moved)

    if taken <= 0 then
      return nil, 'no_ammo'
    end

    local metadata <const> = stack.metadata and Siku.table.deepClone(stack.metadata) or {}

    metadata.ammo = loaded + taken
    stack.metadata = metadata
    inventory:touch()

    return { uid = stack.uid, slot = slot, ammo = metadata.ammo, item = stack.item }
  end)
end

--- Lists the weapons a character carries that a kind of ammunition fits.
---
--- What is sent back is what the bag holds and what each weapon is carrying;
--- how much each one could still take is the game's business and is worked out
--- on the client, which is the only side that can ask.
---@param sessionId number The player server id.
---@param ammoItem any The ammunition item identifier.
---@return table? payload, string? reason The weapons it fits, and why nothing was listed otherwise.
function BuildReloadTargets(sessionId, ammoItem)
  local inventory <const> = GetSessionInventory(sessionId)

  if not inventory then
    return nil, 'no_character'
  end

  if type(ammoItem) ~= 'string' or not IsAmmoItem(ammoItem) then
    return nil, 'invalid_request'
  end

  local carried <const> = inventory:countItem(ammoItem)
  local slots <const> = {}

  for slot, stack in pairs(inventory.stacks) do
    if IsWeaponItem(stack.item) and GetWeaponAmmoItem(stack.item) == ammoItem then
      slots[#slots + 1] = slot
    end
  end

  table.sort(slots)

  local weapons <const> = {}

  for i = 1, #slots do
    local stack <const> = inventory:getStack(slots[i])

    weapons[i] = {
      uid = stack.uid,
      item = stack.item,
      name = GetItemDefinition(stack.item).name,
      ammo = GetLoadedAmmo(stack),
      components = GetFittedComponents(stack),
    }
  end

  return { ammoItem = ammoItem, carried = carried, weapons = weapons }
end

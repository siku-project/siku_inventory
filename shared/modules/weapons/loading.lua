local MAX_MAGAZINE <const> = 2000

--- The rounds a weapon feeds on, as an item identifier.
---@param item string The internal item identifier.
---@return string? ammo The ammunition item, nil when it takes none.
function GetWeaponAmmoItem(item)
  local definition <const> = GetItemDefinition(item)
  local ammoType <const> = definition and definition.ammoType

  return type(ammoType) == 'string' and ammoType or nil
end

--- Whether a weapon fires anything at all. A blade, a thrown charge, a gadget
--- and an energy weapon all answer no.
---@param item string The internal item identifier.
---@return boolean fires Whether the weapon takes ammunition.
function DoesWeaponTakeAmmo(item)
  return GetWeaponAmmoItem(item) ~= nil
end

--- Whether an item is a kind of ammunition.
---@param item string The internal item identifier.
---@return boolean ammo Whether the item is a round.
function IsAmmoItem(item)
  return Ammo[item] ~= nil
end

--- How many rounds a weapon instance is currently carrying.
---@param stack? table The weapon stack.
---@return number loaded The rounds inside, zero when it carries none.
function GetLoadedAmmo(stack)
  local loaded <const> = stack and stack.metadata and stack.metadata.ammo

  return type(loaded) == 'number' and math.max(0, math.floor(loaded)) or 0
end

--- Reads a magazine size a client read off the engine.
---
--- The number comes from the game, and the game only runs on the client, so
--- it arrives with the request. Nothing about the economy rests on it: a
--- forged capacity moves a player's own rounds from their own bag into their
--- own weapon and creates none — the bound below only stops an absurd value
--- from reaching the arithmetic.
---@param value any The capacity the client reported.
---@return number? magazine The accepted capacity.
function ReadMagazine(value)
  if type(value) ~= 'number' or value ~= value or value % 1 ~= 0 then
    return nil
  end

  if value < 1 or value > MAX_MAGAZINE then
    return nil
  end

  return value
end

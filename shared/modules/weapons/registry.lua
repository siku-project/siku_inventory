local CATEGORY_THROWABLE <const> = 'throwable'

--- The properties a weapon instance may show, in reading order.
---@param ammoType any The ammunition the weapon declares.
---@return table display The metadata fields the interface is allowed to read.
local function displayFields(ammoType)
  local fields <const> = { { key = 'serial', label = 'item.meta.serial' } }

  if type(ammoType) == 'string' then
    fields[#fields + 1] = { key = 'ammo', label = 'item.meta.ammo', format = 'number' }
  end

  return fields
end

--- Whether a weapon leaves the hand when used: a grenade, a snowball, a
--- flare. Such a weapon is a pile rather than an instance: no serial, no
--- rounds, one thrown at a time.
---@param item string The item identifier.
---@return boolean throwable Whether the weapon is thrown.
function IsThrowableWeapon(item)
  local weapon <const> = Weapons[item]

  return weapon ~= nil and weapon.category == CATEGORY_THROWABLE
end

--- Expands every declared weapon into the item catalogue.
---@return nil
local function expandWeapons()
  for item, weapon in pairs(Weapons) do
    local definition <const> = Siku.table.merge({}, weapon)
    local throwable <const> = weapon.category == CATEGORY_THROWABLE

    definition.serialised = not throwable
    definition.metadata = weapon.metadata
      or { display = throwable and {} or displayFields(weapon.ammoType) }

    Items[item] = definition
  end
end

expandWeapons()

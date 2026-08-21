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

--- Expands every declared weapon into the item catalogue.
---@return nil
local function expandWeapons()
  for item, weapon in pairs(Weapons) do
    local definition <const> = Siku.table.merge({}, weapon)

    definition.serialised = true
    definition.metadata = weapon.metadata or { display = displayFields(weapon.ammoType) }

    Items[item] = definition
  end
end

expandWeapons()

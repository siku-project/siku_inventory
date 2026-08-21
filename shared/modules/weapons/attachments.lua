local SLOTS <const> = {
  { id = 'sight', label = 'weapon.slot.sight' },
  { id = 'muzzle', label = 'weapon.slot.muzzle' },
  { id = 'flashlight', label = 'weapon.slot.flashlight' },
  { id = 'magazine', label = 'weapon.slot.magazine' },
  { id = 'grip', label = 'weapon.slot.grip' },
  { id = 'barrel', label = 'weapon.slot.barrel' },
  { id = 'skin', label = 'weapon.slot.skin' },
}

--- Whether a slot identifier is one that exists.
---@param slot any The slot identifier.
---@return boolean known Whether the slot exists.
function IsKnownWeaponSlot(slot)
  if type(slot) ~= 'string' then
    return false
  end

  for i = 1, #SLOTS do
    if SLOTS[i].id == slot then
      return true
    end
  end

  return false
end

--- Builds the slot list the interface lays out around a weapon.
---@return table slots The declared slots.
function GetWeaponSlotPayload()
  local slots <const> = {}

  for i = 1, #SLOTS do
    local slot <const> = SLOTS[i]

    slots[i] = {
      id = slot.id,
      label = slot.label,
    }
  end

  return slots
end

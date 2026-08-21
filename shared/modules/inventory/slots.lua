HOTBAR_SLOT_OFFSET = 1000

HOTBAR_SLOTS = 5

--- Turns a hotbar index into the slot number it occupies.
---@param index number The hotbar index, starting at one.
---@return number slot The slot number in the inventory.
function GetHotbarSlotNumber(index)
  return HOTBAR_SLOT_OFFSET + index
end

--- Whether a slot number belongs to the hotbar rather than the carried grid.
---@param slot number The slot number.
---@return boolean hotbar Whether the slot is a hotbar one.
function IsHotbarSlotNumber(slot)
  return type(slot) == 'number' and slot > HOTBAR_SLOT_OFFSET
end

--- Turns a slot number back into the hotbar index it stands for.
---@param slot number The slot number.
---@return number index The hotbar index.
function GetHotbarIndexOf(slot)
  return slot - HOTBAR_SLOT_OFFSET
end

--- Whether a hotbar index is one the hotbar actually offers.
---@param index any The index to check.
---@return boolean valid Whether the index exists.
function IsValidHotbarIndex(index)
  if type(index) ~= 'number' or index % 1 ~= 0 then
    return false
  end

  return index >= 1 and index <= HOTBAR_SLOTS
end

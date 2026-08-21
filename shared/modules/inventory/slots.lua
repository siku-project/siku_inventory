local HOTBAR_PREFIX <const> = 'H'

HOTBAR_SLOTS = 5

--- The identifier a hotbar key stands for.
---
--- A key is named rather than numbered, so no amount of grid slots will ever
--- run into the hotbar and there is no boundary for a caller to remember.
---@param index number The hotbar index, starting at one.
---@return string slot The slot identifier.
function GetHotbarSlotId(index)
  return HOTBAR_PREFIX .. index
end

--- Whether a slot identifier names a hotbar key rather than a grid slot.
---
--- A question about shape rather than about value: a grid slot is a number, a
--- hotbar slot is not, and the two can never be mistaken for one another.
---@param slot any The slot identifier.
---@return boolean hotbar Whether it names a hotbar key.
function IsHotbarSlot(slot)
  return type(slot) == 'string' and slot:match('^' .. HOTBAR_PREFIX .. '%d+$') ~= nil
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

--- The hotbar key a slot identifier stands for.
---@param slot any The slot identifier.
---@return number? index The hotbar index, nil when the slot is not one.
function GetHotbarIndexOf(slot)
  if not IsHotbarSlot(slot) then
    return nil
  end

  local index <const> = tonumber(slot:sub(#HOTBAR_PREFIX + 1))

  return IsValidHotbarIndex(index) and index or nil
end

--- Reads a slot identifier, in whichever of the two shapes it was written.
---
--- A client sends back what it was given: a number for the grid, `H2` for a
--- key. Anything else is not a slot, and a number that could not be one is
--- refused here rather than deeper down.
---@param value any The value received.
---@return (number|string)? slot The accepted identifier.
function ReadSlotId(value)
  if IsHotbarSlot(value) then
    return GetHotbarIndexOf(value) and value or nil
  end

  if type(value) ~= 'number' or value % 1 ~= 0 or value < 1 then
    return nil
  end

  return value
end

--- Orders two slot identifiers, so a list may hold both shapes at once.
---
--- The grid comes first in its own order, then the keys in theirs. Sorting a
--- mixed list without this raises rather than misbehaves, which is the good
--- kind of failure but not one worth leaving around.
---@param a number|string The first identifier.
---@param b number|string The second identifier.
---@return boolean before Whether the first comes before the second.
function CompareSlots(a, b)
  local aHotbar <const> = IsHotbarSlot(a)
  local bHotbar <const> = IsHotbarSlot(b)

  if aHotbar ~= bHotbar then
    return bHotbar
  end

  if aHotbar then
    return (GetHotbarIndexOf(a) or 0) < (GetHotbarIndexOf(b) or 0)
  end

  return a < b
end

--- Sorts a list of slot identifiers in place, and hands it back.
---@param slots table The identifiers to order.
---@return table slots The very same list, now ordered.
function SortSlots(slots)
  table.sort(slots, CompareSlots)

  return slots
end

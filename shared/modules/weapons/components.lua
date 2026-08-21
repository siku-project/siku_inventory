local SERIAL_FIELD <const> = { { key = 'serial', label = 'item.meta.serial' } }

--- Turns every declared component into an item.
---@return nil
local function expandComponents()
  for item, component in pairs(Components) do
    local definition <const> = Siku.table.merge({}, component)

    definition.serialised = true
    definition.metadata = component.metadata or { display = SERIAL_FIELD }

    Items[item] = definition
  end
end

expandComponents()

--- Whether an item kind is a weapon.
---@param item string The internal item identifier.
---@return boolean weapon Whether the kind is a weapon.
function IsWeaponItem(item)
  return GetItemType(item) == 'weapon'
end

--- Whether an item kind is a weapon component.
---@param item string The internal item identifier.
---@return boolean component Whether the kind is a component.
function IsComponentItem(item)
  return GetItemType(item) == 'component'
end

--- The attachment slot a component occupies.
---@param item string The internal item identifier.
---@return string? slot The slot identifier.
function GetComponentSlot(item)
  local definition <const> = GetItemDefinition(item)

  return definition and definition.slot or nil
end

--- The game components an item may resolve to. The client tries them in order
--- and fits the first one the weapon in front of it accepts.
---@param item string The internal item identifier.
---@return table variants The declared game component names.
function GetComponentVariants(item)
  local definition <const> = GetItemDefinition(item)

  return definition and definition.variants or {}
end

--- Reads one entry of a weapon's fitted table as a whole instance.
---
--- A weapon written before components carried their identity stored the item
--- name alone. Such an entry is still understood, and turns into a proper
--- instance the next time the weapon is worked on.
---@param entry any The stored entry.
---@return table? instance The fitted instance, or nil when the entry is not one.
local function readFitted(entry)
  if type(entry) == 'string' then
    return IsComponentItem(entry) and { item = entry } or nil
  end

  if type(entry) ~= 'table' or not IsComponentItem(entry.item) then
    return nil
  end

  return {
    item = entry.item,
    uid = entry.uid,
    metadata = entry.metadata and Siku.table.merge({}, entry.metadata) or nil,
  }
end

--- Reads the instances bolted to a weapon, keyed by the slot they sit in.
--- What comes back is a copy, so a caller reading the current state cannot
--- quietly rewrite it.
---@param stack table The weapon stack.
---@return table instances The fitted instances, keyed by slot.
function GetFittedInstances(stack)
  local fitted <const> = {}
  local stored <const> = stack.metadata and stack.metadata.components

  if type(stored) ~= 'table' then
    return fitted
  end

  for slot, entry in pairs(stored) do
    local instance <const> = IsKnownWeaponSlot(slot) and readFitted(entry) or nil

    if instance then
      fitted[slot] = instance
    end
  end

  return fitted
end

--- What the parts bolted to an instance add to its weight, in grams.
---
--- A fitted component leaves the grid but not the character: it is still being
--- carried, on the weapon rather than beside it. Counting it here is what
--- stops a bag from getting lighter every time something is screwed on.
---@param stack table The stack.
---@return number weight The weight of what is fitted, zero when nothing is.
function GetFittedWeight(stack)
  local total = 0

  for _, instance in pairs(GetFittedInstances(stack)) do
    total = total + GetItemWeight(instance.item)
  end

  return total
end

--- Reads what a weapon is wearing, as a slot to item map. This is the view
--- the interface and the engine need: which part sits where, without the
--- identity that only the transaction cares about.
---@param stack table The weapon stack.
---@return table components The fitted component identifiers, keyed by slot.
function GetFittedComponents(stack)
  local names <const> = {}

  for slot, instance in pairs(GetFittedInstances(stack)) do
    names[slot] = instance.item
  end

  return names
end

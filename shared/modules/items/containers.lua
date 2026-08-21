local WEIGHT_FIELD <const> = 'containerWeight'

local containers = {}

--- Reads a list of item names into a set, whichever way it was written.
---
--- A list of names and a table of names to true say the same thing, and both
--- are natural to write by hand. Anything that is not a name is left out
--- rather than turning the whole declaration into a refusal.
---@param value any The declared names.
---@return table? names The names, or nil when none were declared.
local function readNames(value)
  if type(value) ~= 'table' then
    return nil
  end

  local names <const> = {}
  local found = false

  for key, entry in pairs(value) do
    local name <const> = type(key) == 'string' and key or entry

    if type(name) == 'string' and name ~= '' and entry ~= false then
      names[name] = true
      found = true
    end
  end

  return found and names or nil
end

--- Declares an item kind as something that holds other items.
---
--- Only a kind whose instances are tracked one by one may hold anything: what
--- is inside belongs to that box and not to boxes of the same sort, and
--- without an identifier of its own there is no telling one box from another.
---
--- A container may not go inside a container. There is no depth at which that
--- stops being a way to carry the world in a pocket, and refusing the first
--- step is simpler than measuring how deep is too deep.
---@param item string The internal item identifier.
---@param properties table `slots`, `maxWeight`, and `whitelist` or `blacklist`.
---@return table? properties, string? reason The declared properties, and why it was refused otherwise.
function RegisterContainer(item, properties)
  if not IsKnownItem(item) then
    return nil, 'invalid_item'
  end

  if not IsItemUnique(item) then
    return nil, 'not_unique'
  end

  if type(properties) ~= 'table' then
    return nil, 'invalid_request'
  end

  local slots <const> = properties.slots

  if type(slots) ~= 'number' or slots % 1 ~= 0 or slots <= 0 then
    return nil, 'invalid_slots'
  end

  local maxWeight <const> = properties.maxWeight

  if type(maxWeight) ~= 'number' or maxWeight % 1 ~= 0 or maxWeight < 0 then
    return nil, 'invalid_weight'
  end

  containers[item] = {
    slots = slots,
    maxWeight = maxWeight,
    whitelist = readNames(properties.whitelist),
    blacklist = readNames(properties.blacklist),
  }

  return containers[item]
end

--- Takes a kind back out of the containers. What was inside instances of it
--- stays in database: a box nobody calls a box is a box nobody opens, not one
--- that was emptied.
---@param item string The internal item identifier.
---@return boolean removed Whether the kind was one.
function UnregisterContainer(item)
  if type(item) ~= 'string' or not containers[item] then
    return false
  end

  containers[item] = nil

  return true
end

--- Whether a kind holds other items.
---@param item any The internal item identifier.
---@return boolean container Whether instances of it hold things.
function IsContainerItem(item)
  return type(item) == 'string' and containers[item] ~= nil
end

--- What a container kind was declared to be.
---@param item any The internal item identifier.
---@return table? properties The declared properties.
function GetContainerProperties(item)
  return type(item) == 'string' and containers[item] or nil
end

--- Whether something may go inside a container.
---
--- A whitelist names everything allowed and refuses the rest; a blacklist
--- names what is not, and lets everything else through. A container may never
--- hold another container, whatever either list says.
---@param container string The container kind.
---@param item any The kind trying to go in.
---@return boolean allowed Whether it may go in.
function AcceptsInContainer(container, item)
  local properties <const> = GetContainerProperties(container)

  if not properties or not IsKnownItem(item) or IsContainerItem(item) then
    return false
  end

  if properties.blacklist and properties.blacklist[item] then
    return false
  end

  if properties.whitelist then
    return properties.whitelist[item] == true
  end

  return true
end

--- What an instance is carrying inside it, in grams.
---
--- Read off the instance rather than counted from what is inside: the contents
--- live in a container of their own, and weighing a bag would mean opening
--- every box in it every time anybody picks anything up. The number is written
--- onto the instance whenever its contents move, so the bag it sits in gets
--- heavier the moment something goes into the box.
---@param stack table The stack.
---@return number weight The weight of what is inside, zero when nothing is.
function GetContainedWeight(stack)
  if type(stack) ~= 'table' or not IsContainerItem(stack.item) then
    return 0
  end

  local held <const> = stack.metadata and stack.metadata[WEIGHT_FIELD]

  return type(held) == 'number' and held > 0 and held or 0
end

--- Writes what an instance is carrying onto it.
---@param stack table The stack.
---@param weight number The weight of what is inside.
---@return nil
function SetContainedWeight(stack, weight)
  if type(stack) ~= 'table' then
    return
  end

  stack.metadata = stack.metadata or {}
  stack.metadata[WEIGHT_FIELD] = weight > 0 and weight or nil
end

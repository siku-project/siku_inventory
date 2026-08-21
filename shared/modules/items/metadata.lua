local FORMATS <const> = { text = true, number = true, percent = true, money = true, date = true }

local registered = {}
local positions = {}

--- Whether a value names a way of reading a property.
---@param format any The declared format.
---@return boolean known Whether the format is one this resource renders.
function IsKnownMetadataFormat(format)
  return FORMATS[format] == true
end

--- Reads one declared field, whichever of the accepted shapes it was written
--- in. A pair of strings and a named table say the same thing; only the named
--- one can also say how the value should be read.
---@param entry any The declared field.
---@return table? field The normalised field.
local function readField(entry)
  if type(entry) ~= 'table' then
    return nil
  end

  local key <const> = entry.key or entry[1]
  local label <const> = entry.label or entry[2]

  if type(key) ~= 'string' or key == '' or type(label) ~= 'string' or label == '' then
    return nil
  end

  return {
    key = key,
    label = label,
    format = IsKnownMetadataFormat(entry.format) and entry.format or 'text',
  }
end

--- Turns whatever a caller passed into an ordered list of fields.
---
--- Three shapes are understood, and the difference between them is order. A
--- list keeps the order it was written in; a table of key to label has none of
--- its own, so it is read alphabetically rather than differently on every
--- restart.
---@param source any The declared fields, or a single property key.
---@param label? string The label, when a single property was named.
---@return table fields The normalised fields, in the order they should read.
function ReadMetadataDisplay(source, label)
  if type(source) == 'string' then
    local field <const> = readField({ key = source, label = label })

    return field and { field } or {}
  end

  if type(source) ~= 'table' then
    return {}
  end

  local fields <const> = {}

  if #source > 0 then
    for i = 1, #source do
      fields[#fields + 1] = readField(source[i])
    end

    return fields
  end

  local keys <const> = {}

  for key in pairs(source) do
    keys[#keys + 1] = key
  end

  table.sort(keys)

  for i = 1, #keys do
    fields[#fields + 1] = readField({ key = keys[i], label = source[keys[i]] })
  end

  return fields
end

--- Adds properties to the ones every item is allowed to show.
---
--- Registering the same property again replaces what it said before, in the
--- place it already had: a label corrected at runtime does not send the row
--- jumping to the bottom of the tooltip.
---@param fields table The normalised fields.
---@return number added The number of properties taken.
function RegisterMetadataDisplay(fields)
  local added = 0

  for i = 1, #fields do
    local field <const> = fields[i]
    local at <const> = positions[field.key]

    if at then
      registered[at] = field
    else
      registered[#registered + 1] = field
      positions[field.key] = #registered
    end

    added = added + 1
  end

  return added
end

--- Takes properties back out. What an item declares for itself is untouched:
--- only what was added at runtime can be taken away at runtime.
---@param keys table The property keys to drop.
---@return number removed The number of properties dropped.
function HideMetadataDisplay(keys)
  local doomed <const> = {}
  local removed = 0

  for i = 1, #keys do
    if type(keys[i]) == 'string' and positions[keys[i]] then
      doomed[keys[i]] = true
      removed = removed + 1
    end
  end

  if removed == 0 then
    return 0
  end

  local kept <const> = {}

  positions = {}

  for i = 1, #registered do
    local field <const> = registered[i]

    if not doomed[field.key] then
      kept[#kept + 1] = field
      positions[field.key] = #kept
    end
  end

  registered = kept

  return removed
end

--- The properties added at runtime, in reading order.
---@return table fields The registered fields.
function GetRegisteredMetadataDisplay()
  return registered
end

--- Replaces the runtime properties wholesale. This is how a client is handed
--- the server's list: what may be shown is decided in one place, and every
--- screen reads the same list.
---@param fields any The fields to hold.
---@return nil
function SetRegisteredMetadataDisplay(fields)
  registered = {}
  positions = {}

  if type(fields) == 'table' then
    RegisterMetadataDisplay(ReadMetadataDisplay(fields))
  end
end

--- Serialises a metadata table into a stable string, so that two tables
--- holding the same pairs always produce the same signature whatever the
--- order Lua walked them in.
---@param metadata? table The metadata of an instance.
---@return string signature The canonical signature.
local function signature(metadata)
  if type(metadata) ~= 'table' then
    return ''
  end

  local keys <const> = {}

  for key in pairs(metadata) do
    keys[#keys + 1] = tostring(key)
  end

  table.sort(keys)

  local parts <const> = {}

  for i = 1, #keys do
    local key <const> = keys[i]
    local value <const> = metadata[key]

    if type(value) == 'table' then
      parts[#parts + 1] = key .. '=' .. signature(value)
    else
      parts[#parts + 1] = key .. '=' .. tostring(value)
    end
  end

  return '{' .. table.concat(parts, ',') .. '}'
end

--- Canonical signature of an instance metadata, used to decide stacking.
---@param metadata? table The metadata of an instance.
---@return string signature The canonical signature.
function GetMetadataSignature(metadata)
  return signature(metadata)
end

--- Whether an instance carries the properties somebody is looking for.
---
--- Two ways of asking, and the difference matters. Partially — the default —
--- every property named has to match and the rest are not looked at: asking
--- for a card that belongs to somebody finds their card, which also carries
--- its number and its expiry. Strictly, the instance must carry that and
--- nothing else, which is the question stacking asks and almost never the
--- question a caller means.
---@param held? table The metadata the instance carries.
---@param wanted? table The properties being looked for.
---@param strict? boolean Whether the whole metadata must be identical.
---@return boolean matches Whether the instance answers.
function MetadataMatches(held, wanted, strict)
  if wanted == nil then
    return true
  end

  if strict == true then
    return GetMetadataSignature(held) == GetMetadataSignature(wanted)
  end

  if type(wanted) ~= 'table' then
    return false
  end

  if type(held) ~= 'table' then
    return next(wanted) == nil
  end

  for key, value in pairs(wanted) do
    local mine <const> = held[key]

    if type(value) == 'table' and type(mine) == 'table' then
      if GetMetadataSignature(mine) ~= GetMetadataSignature(value) then
        return false
      end
    elseif mine ~= value then
      return false
    end
  end

  return true
end

--- Whether two instances may share a stack. This is the one place the rule
--- lives: the carried grid, the hotbar and the ground all ask this question
--- here, so a kind can never merge in one container and refuse in another.
---
--- Kind, identity, metadata and remaining uses all have to agree. Freshness
--- deliberately does not: two loaves spoiling at different times still stack,
--- and the merged stack inherits the earlier of the two expiries, which is
--- what keeps a full inventory from fragmenting one slot per minute.
---@param a table The first instance.
---@param b table The second instance.
---@return boolean compatible Whether the two may merge.
function CanStack(a, b)
  if type(a) ~= 'table' or type(b) ~= 'table' then
    return false
  end

  if a.item ~= b.item then
    return false
  end

  if a.uid or b.uid then
    return false
  end

  if not IsItemStackable(a.item) then
    return false
  end

  if a.uses ~= b.uses then
    return false
  end

  return GetMetadataSignature(a.metadata) == GetMetadataSignature(b.metadata)
end

--- The expiry a stack carries once two instances merge: the earlier of the
--- two, so merging never makes anything fresher than it was.
---@param a table The first instance.
---@param b table The second instance.
---@return number? expiresAt The expiry the merged stack keeps.
function MergedExpiry(a, b)
  if not a.expiresAt then
    return b.expiresAt
  end

  if not b.expiresAt then
    return a.expiresAt
  end

  return math.min(a.expiresAt, b.expiresAt)
end

--- How much more a stack can take before hitting the kind's cap.
---@param instance table The stack.
---@return number room The quantity that still fits, 0 when full.
function GetStackRoom(instance)
  if type(instance) ~= 'table' then
    return 0
  end

  local max <const> = GetItemMaxStack(instance.item)

  if max == math.huge then
    return math.huge
  end

  return math.max(0, max - (instance.count or 0))
end

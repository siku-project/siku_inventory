--- Keeps only the metadata an item declares as displayable. Anything the
--- definition does not list stays on the server, whatever it holds: the
--- allowlist is what an item says it is willing to show, not what happens to
--- be stored on the instance.
---@param item string The internal item identifier.
---@param metadata? table The full metadata of the instance.
---@return table? public The exposable subset, or nil when there is none.
function FilterPublicMetadata(item, metadata)
  if type(metadata) ~= 'table' then
    return nil
  end

  local declared <const> = GetItemDisplayFields(item)

  if not declared then
    return nil
  end

  local public = nil

  for i = 1, #declared do
    local key <const> = declared[i].key
    local value <const> = metadata[key]

    if value ~= nil then
      public = public or {}
      public[key] = value
    end
  end

  return public
end

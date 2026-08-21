--- Finds the container behind an open request, refusing it whole rather than
--- opening something the character was not allowed to see.
---@param sessionId number The player server id.
---@param request table What was asked for: a stash name and, sometimes, an owner.
---@return table? descriptor, string? reason The container to show, and why the request was refused otherwise.
local function resolveStash(sessionId, request)
  if type(request) ~= 'table' then
    return nil, 'invalid_request'
  end

  local definition <const> = GetStashDefinition(request.name)

  if not definition then
    return nil, 'invalid_request'
  end

  local owner <const> = ResolveStashOwner(sessionId, definition, request.owner)

  if definition.owner and not owner then
    return nil, 'no_character'
  end

  local allowed <const>, reason <const> = CanSessionOpenStash(sessionId, definition, owner)

  if not allowed then
    return nil, reason
  end

  local inventory <const> = GetStashInventory(definition, owner)

  if not inventory then
    return nil, 'refused'
  end

  return {
    id = definition.name,
    label = definition.label,
    icon = definition.icon,
    owner = owner,
    inventoryId = inventory.id,
  }
end

--- Whether a character may still be looking at a stash. The very rules that
--- opened it are asked again: nothing about a stash is decided once.
---@param sessionId number The player server id.
---@param descriptor table The open container.
---@return boolean allowed, string? reason Whether the view may stay, and why it may not.
local function validateStash(sessionId, descriptor)
  local definition <const> = GetStashDefinition(descriptor.id)

  if not definition then
    return false, 'unreachable'
  end

  return CanSessionOpenStash(sessionId, definition, descriptor.owner)
end

RegisterContainerKind('stash', {
  resolve = resolveStash,
  validate = validateStash,
})

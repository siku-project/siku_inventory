local ICON <const> = 'mdi-account-search-outline'

--- Reads the name to show above somebody else's bag.
---@param sessionId number The session being looked at.
---@return string label The civil identity, or a plain word when none is known.
local function nameOf(sessionId)
  local identity <const> = GetSessionIdentity(sessionId)

  if not identity then
    return T('inspect_unknown')
  end

  return ('%s %s'):format(identity.firstName or '', identity.lastName or ''):gsub('^%s+', '')
end

--- Whether one session may be searching another right now.
---
--- Within arm's reach, both playing a character, and never oneself. The reach
--- is the one a hand has — the same distance that decides whether something
--- can be handed over, because a search and a give are the same gesture from
--- opposite sides.
---@param sessionId number The session looking.
---@param targetId number The session being looked at.
---@return boolean allowed, string? reason Whether the search may go on, and why it may not.
local function canInspect(sessionId, targetId)
  if type(targetId) ~= 'number' or targetId == sessionId then
    return false, 'invalid_target'
  end

  if not GetSessionInventory(sessionId) then
    return false, 'no_character'
  end

  if not GetSessionInventory(targetId) then
    return false, 'target_unavailable'
  end

  local distance <const> = GetSessionDistance(sessionId, targetId)

  if not distance or distance > InventoryConfig.giveDistance then
    return false, 'target_too_far'
  end

  return true
end

--- Finds the bag a search is about.
---@param sessionId number The session looking.
---@param request table What was asked for: the session being searched.
---@return table? descriptor, string? reason The container to show, and why the request was refused otherwise.
local function resolveInspect(sessionId, request)
  if type(request) ~= 'table' then
    return nil, 'invalid_request'
  end

  local targetId <const> = request.target
  local allowed <const>, reason <const> = canInspect(sessionId, targetId)

  if not allowed then
    return nil, reason
  end

  local inventory <const> = GetSessionInventory(targetId)

  return {
    id = tostring(targetId),
    label = nameOf(targetId),
    icon = ICON,
    readOnly = true,
    target = targetId,
    inventoryId = inventory.id,
  }
end

--- Whether a search may stay open. Walking away ends it, and so does the other
--- one disconnecting or changing character.
---@param sessionId number The session looking.
---@param descriptor table The open container.
---@return boolean allowed, string? reason Whether the view may stay, and why it may not.
local function validateInspect(sessionId, descriptor)
  local allowed <const>, reason <const> = canInspect(sessionId, descriptor.target)

  if not allowed then
    return false, reason
  end

  local inventory <const> = GetSessionInventory(descriptor.target)

  if not inventory or inventory.id ~= descriptor.inventoryId then
    return false, 'target_unavailable'
  end

  return true
end

RegisterContainerKind('inspect', {
  resolve = resolveInspect,
  validate = validateInspect,
})

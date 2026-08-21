local ICON <const> = 'mdi-shield-account-outline'
local OPEN_PERMISSION <const> = 'inventory.staff.openInventory'

--- Reads the name to show above the bag being administered.
---@param sessionId number The session being looked at.
---@return string label The civil identity, or a plain word when none is known.
local function nameOf(sessionId)
  local identity <const> = GetSessionIdentity(sessionId)

  if not identity then
    return T('inspect_unknown')
  end

  return ('%s %s'):format(identity.firstName or '', identity.lastName or ''):gsub('^%s+', '')
end

--- Whether a member of staff may hold another player's bag open.
---
--- Nothing about distance: this is not a search, and the point of an
--- administrative view is reaching someone who is not in front of you. What is
--- asked instead is the permission — asked again while the view is up, so a
--- role taken away closes what it had opened.
---@param sessionId number The session looking.
---@param targetId any The session being administered.
---@return boolean allowed, string? reason Whether the view may go on, and why it may not.
local function canAdminister(sessionId, targetId)
  if type(targetId) ~= 'number' or targetId == sessionId then
    return false, 'invalid_target'
  end

  local character <const> = GetSessionCharacter(sessionId)

  if not character then
    return false, 'no_character'
  end

  if not Siku.permissions.hasPermission(character.id, OPEN_PERMISSION) then
    return false, 'not_allowed'
  end

  if not GetSessionInventory(targetId) then
    return false, 'target_unavailable'
  end

  return true
end

--- Finds the bag an administrative view is about.
---@param sessionId number The session looking.
---@param request table What was asked for: the session being administered.
---@return table? descriptor, string? reason The container to show, and why the request was refused otherwise.
local function resolveStaff(sessionId, request)
  if type(request) ~= 'table' then
    return nil, 'invalid_request'
  end

  local targetId <const> = request.target
  local allowed <const>, reason <const> = canAdminister(sessionId, targetId)

  if not allowed then
    return nil, reason
  end

  local inventory <const> = GetSessionInventory(targetId)

  return {
    id = tostring(targetId),
    label = nameOf(targetId),
    icon = ICON,
    target = targetId,
    inventoryId = inventory.id,
  }
end

--- Whether the view may stay open. The other one disconnecting, changing
--- character, or the permission going away all end it.
---@param sessionId number The session looking.
---@param descriptor table The open container.
---@return boolean allowed, string? reason Whether the view may stay, and why it may not.
local function validateStaff(sessionId, descriptor)
  local allowed <const>, reason <const> = canAdminister(sessionId, descriptor.target)

  if not allowed then
    return false, reason
  end

  local inventory <const> = GetSessionInventory(descriptor.target)

  if not inventory or inventory.id ~= descriptor.inventoryId then
    return false, 'target_unavailable'
  end

  return true
end

RegisterContainerKind('staff', {
  resolve = resolveStaff,
  validate = validateStaff,
})

--- Opens another player's bag beside your own, to administer it.
---
--- Not a search: what comes up is the ordinary second panel, so anything can
--- be taken out of it or put into it. That is the point — a member of staff
--- reaching this far is fixing something, and being able to look without being
--- able to act would only send them back to the other commands.
---
--- Lives here rather than beside the other staff commands because the family
--- it opens is registered here too, and a family has to be declared after the
--- layer that accepts one.
Siku.RegisterCommand('openinventorytarget', function(source, args)
  local opened <const>, reason <const> = OpenContainer(source, 'staff', { target = args.target })

  if not opened then
    NotifySession(source, 'error', T('notify_open_refused'))

    return Siku.print.debug(('/openinventorytarget refused for %d: %s'):format(source, reason or 'refused'))
  end
end, {
  permission = OPEN_PERMISSION,
  description = T('command_open_description'),
  arguments = {
    {
      name = 'target',
      type = 'player',
      help = T('command_open_target'),
    },
  },
})

DeclareStaffPermission(OPEN_PERMISSION)

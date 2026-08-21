local provider = nil
local hooks <const> = {}

--- Reads the jobs a character holds, and the grade they hold each at.
---
--- The ecosystem has no job system yet, so this reads the shapes a character
--- row is likely to carry once it does — a `groups` table, or a job and a
--- grade — and answers nothing when it finds neither. A resource that owns
--- jobs replaces the whole thing through SetGroupProvider, which is the one
--- line it takes to make every stash in the server obey it.
---@param sessionId number The player server id.
---@return table groups The jobs held, each mapped to a grade.
local function readGroups(sessionId)
  local character <const> = GetSessionCharacter(sessionId)

  if not character then
    return {}
  end

  if type(character.groups) == 'table' then
    return character.groups
  end

  if type(character.job) ~= 'string' or character.job == '' then
    return {}
  end

  local grade <const> = character.job_grade or character.grade

  return { [character.job] = type(grade) == 'number' and grade or 0 }
end

--- Replaces how the jobs of a character are read.
---@param handler? function Called with a session id, answering a table of jobs and grades.
---@return boolean accepted Whether the handler was taken.
function SetGroupProvider(handler)
  if handler == nil then
    provider = nil

    return true
  end

  if not _SikuInternal.IsCallable(handler) then
    return false
  end

  provider = handler

  return true
end

exports('SetGroupProvider', SetGroupProvider)

--- The jobs a character holds, whichever way the server reads them.
---@param sessionId number The player server id.
---@return table groups The jobs held, each mapped to a grade.
function GetSessionGroups(sessionId)
  if not provider then
    return readGroups(sessionId)
  end

  local ok <const>, held <const> = pcall(provider, sessionId)

  if not ok then
    Siku.print.error(T('stash_group_provider_failed', tostring(held)))

    return {}
  end

  return type(held) == 'table' and held or {}
end

--- Whether a character holds one of the jobs a stash asks for, at the grade
--- it asks for. A stash asking for nothing is open to everybody.
---@param sessionId number The player server id.
---@param groups? table The jobs the stash asks for.
---@return boolean allowed Whether the character qualifies.
function PassesGroupRequirement(sessionId, groups)
  if not groups then
    return true
  end

  local held <const> = GetSessionGroups(sessionId)

  for name, minimum in pairs(groups) do
    local grade <const> = held[name]

    if type(grade) == 'number' and grade >= minimum then
      return true
    end

    if grade == true and minimum == 0 then
      return true
    end
  end

  return false
end

--- Whether a character is standing in the world the stash belongs to. Two
--- instances of the same building hold two different stashes even though they
--- share a name, and neither may be opened from the other.
---@param sessionId number The player server id.
---@param definition table The stash definition.
---@return boolean allowed Whether the character is in the right instance.
function PassesInstanceRequirement(sessionId, definition)
  if not definition.instance then
    return true
  end

  return Siku.bucket.getPlayer(sessionId) == definition.instance
end

--- Puts a stash behind a rule of the caller's own.
---
--- Jobs, distance and instance answer most of it; a padlock, a warrant or a
--- rented locker do not. The handler is asked last, after everything declared
--- has already passed, and refusing is as simple as answering false.
---@param name string The stash identifier.
---@param handler? function Called with the session and what is being opened.
---@return boolean accepted Whether the handler was taken.
function SetStashAccess(name, handler)
  if type(name) ~= 'string' or name == '' then
    return false
  end

  if handler == nil then
    hooks[name] = nil

    return true
  end

  if not _SikuInternal.IsCallable(handler) then
    return false
  end

  hooks[name] = handler

  return true
end

exports('SetStashAccess', SetStashAccess)

--- Asks the rule a caller put on a stash, when there is one.
---@param sessionId number The player server id.
---@param definition table The stash definition.
---@param owner? string The owner the stash resolved for.
---@return boolean allowed Whether the handler let it through.
local function passesAccessHook(sessionId, definition, owner)
  local handler <const> = hooks[definition.name]

  if not handler then
    return true
  end

  local ok <const>, allowed <const> = pcall(handler, sessionId, {
    stash = definition.name,
    label = definition.label,
    owner = owner,
  })

  if not ok then
    Siku.print.error(T('stash_access_hook_failed', definition.name, tostring(allowed)))

    return false
  end

  return allowed ~= false
end

--- Whether a character may open a stash right now. Asked when the stash opens
--- and again while it stays open, so walking away, losing a job or changing
--- instance closes it rather than leaving a live view of something out of
--- reach.
---@param sessionId number The player server id.
---@param definition table The stash definition.
---@param owner? string The owner the stash resolved for.
---@return boolean allowed, string? reason Whether the stash may be opened, and why it may not.
function CanSessionOpenStash(sessionId, definition, owner)
  if not GetSessionInventory(sessionId) then
    return false, 'no_character'
  end

  if not PassesInstanceRequirement(sessionId, definition) then
    return false, 'unreachable'
  end

  if not PassesGroupRequirement(sessionId, definition.groups) then
    return false, 'not_allowed'
  end

  if definition.coords then
    local coords <const> = GetSessionCoords(sessionId)

    if not coords or not IsStashWithinReach(definition, coords) then
      return false, 'unreachable'
    end
  end

  if not passesAccessHook(sessionId, definition, owner) then
    return false, 'not_allowed'
  end

  return true
end

local hooks <const> = {}

--- Whether a character satisfies one job rule, asked to the core job
--- engine: a permission with its duty rule, a grade by rank, or the mere
--- membership.
---@param characterId number The character id.
---@param jobName string The job name.
---@param rule table { grade?, permission? }.
---@return boolean holds Whether the character qualifies through this job.
local function holdsJob(characterId, jobName, rule)
  if rule.permission then
    return Siku.jobs.hasPermission(characterId, jobName, rule.permission)
  end

  local membership <const> = Siku.jobs.getMembership(characterId, jobName)

  if not membership then
    return false
  end

  if not rule.grade then
    return true
  end

  local required <const> = Siku.jobs.getGrade(jobName, rule.grade)

  return required ~= nil and membership.rank >= required.rank
end

--- Whether a character holds one of the jobs a stash asks for, the way it
--- asks for it. A stash asking for nothing is open to everybody.
---@param sessionId number The player server id.
---@param jobs? table The rules by job name.
---@return boolean allowed Whether the character qualifies.
function PassesJobRequirement(sessionId, jobs)
  if not jobs then
    return true
  end

  local characterId <const> = Siku.cache.getCurrentCharacterId(sessionId)

  if not characterId then
    return false
  end

  for jobName, rule in pairs(jobs) do
    if holdsJob(characterId, jobName, rule) then
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
---@param name string|number The stash identifier.
---@param handler? function Called with the session and what is being opened.
---@return boolean accepted Whether the handler was taken.
function SetStashAccess(name, handler)
  if type(name) == 'number' then
    name = tostring(name)
  end

  if type(name) ~= 'string' or name == '' then
    return false
  end

  if handler == nil then
    hooks[name] = nil

    return true
  end

  if not Siku.isCallable(handler) then
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

  if not PassesJobRequirement(sessionId, definition.jobs) then
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

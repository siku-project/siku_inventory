local DEFAULT_ICON <const> = 'mdi-locker'

local declared = {}

--- Whether a value is a usable position, whatever built it. A real vector3
--- and the table a test hands over both answer the same three questions, and
--- reading the components rather than the type is what lets the reach rule be
--- exercised outside the game.
---@param value any The value to inspect.
---@return boolean position Whether it reads as a position.
local function isPosition(value)
  if type(value) ~= 'vector3' and type(value) ~= 'table' then
    return false
  end

  return type(value.x) == 'number' and type(value.y) == 'number' and type(value.z) == 'number'
end

--- Reads the positions a stash may be opened from. One position and a list of
--- them are both accepted; a stash without any is opened from anywhere.
---@param value any The declared coords.
---@return table? positions, string? reason The positions, and why the value was refused otherwise.
local function readPositions(value)
  if value == nil then
    return nil, nil
  end

  if isPosition(value) then
    return { value }, nil
  end

  if type(value) ~= 'table' or #value == 0 then
    return nil, 'coords must be a position or a list of positions'
  end

  local positions <const> = {}

  for i = 1, #value do
    if not isPosition(value[i]) then
      return nil, ('coords entry %d is not a position'):format(i)
    end

    positions[i] = value[i]
  end

  return positions, nil
end

--- Reads what one job rule asks for: any member, a grade by name, or a
--- permission of the job.
---@param name string The job name.
---@param value any The declared rule.
---@return table? rule { grade?, permission? }, nil when malformed.
---@return string? reason Why the rule was refused.
local function readJobRule(name, value)
  if value == true then
    return {}, nil
  end

  if type(value) == 'string' and value ~= '' then
    return { grade = value }, nil
  end

  if type(value) ~= 'table' then
    return nil, ('job %q must be true, a grade name or a rule table'):format(name)
  end

  local grade <const> = value.grade
  local permission <const> = value.permission

  if grade ~= nil and (type(grade) ~= 'string' or grade == '') then
    return nil, ('job %q names an invalid grade'):format(name)
  end

  if permission ~= nil and (type(permission) ~= 'string' or permission == '') then
    return nil, ('job %q names an invalid permission'):format(name)
  end

  if grade and permission then
    return nil, ('job %q asks for a grade and a permission at once'):format(name)
  end

  return { grade = grade, permission = permission }, nil
end

--- Reads the jobs a stash is reserved for, each with what it asks of the
--- character in that job.
---@param value any The declared jobs.
---@return table? jobs, string? reason The rules by job name, and why the value was refused otherwise.
local function readJobs(value)
  if value == nil then
    return nil, nil
  end

  if type(value) ~= 'table' then
    return nil, 'jobs must be a table of job names'
  end

  local jobs <const> = {}
  local found = false

  for name, declared in pairs(value) do
    if type(name) ~= 'string' or name == '' then
      return nil, 'a job name must be a non-empty string'
    end

    local rule <const>, reason <const> = readJobRule(name, declared)

    if not rule then
      return nil, reason
    end

    jobs[name] = rule
    found = true
  end

  if not found then
    return nil, nil
  end

  return jobs, nil
end

--- Reads who a stash belongs to. The three answers are shared, one per
--- character, and bound to a name of the caller's choosing.
---@param value any The declared owner.
---@return string|boolean? owner, string? reason The owner, and why the value was refused otherwise.
local function readOwner(value)
  if value == nil or value == false then
    return nil, nil
  end

  if value == true then
    return true, nil
  end

  if type(value) == 'string' and value ~= '' then
    return value, nil
  end

  return nil, 'owner must be true, a non-empty string, or left out'
end

--- Turns a declaration into the definition the rest of the resource reads,
--- refusing anything it cannot make sense of rather than guessing.
---@param declaration table The declaration, from the file or from an export.
---@return table? definition, string? reason The normalised definition, and why it was refused otherwise.
function NormaliseStash(declaration)
  if type(declaration) ~= 'table' then
    return nil, 'a stash declaration must be a table'
  end

  local name <const> = declaration.name

  if type(name) ~= 'string' or name == '' then
    return nil, 'name must be a non-empty string'
  end

  local label <const> = declaration.label

  if type(label) ~= 'string' or label == '' then
    return nil, 'label must be a non-empty string'
  end

  local slots <const> = declaration.slots

  if type(slots) ~= 'number' or slots % 1 ~= 0 or slots <= 0 then
    return nil, 'slots must be a whole number above zero'
  end

  local maxWeight <const> = declaration.maxWeight

  if type(maxWeight) ~= 'number' or maxWeight % 1 ~= 0 or maxWeight < 0 then
    return nil, 'maxWeight must be a whole number of grams, zero meaning uncapped'
  end

  local owner <const>, ownerReason <const> = readOwner(declaration.owner)

  if ownerReason then
    return nil, ownerReason
  end

  local jobs <const>, jobsReason <const> = readJobs(declaration.jobs)

  if jobsReason then
    return nil, jobsReason
  end

  local positions <const>, positionsReason <const> = readPositions(declaration.coords)

  if positionsReason then
    return nil, positionsReason
  end

  local distance <const> = declaration.distance

  if distance ~= nil and (type(distance) ~= 'number' or distance <= 0) then
    return nil, 'distance must be a number of metres above zero'
  end

  local instance <const> = declaration.instance

  if instance ~= nil and (type(instance) ~= 'number' or instance % 1 ~= 0 or instance < 0) then
    return nil, 'instance must be a whole routing bucket identifier'
  end

  local icon <const> = declaration.icon

  if icon ~= nil and (type(icon) ~= 'string' or icon == '') then
    return nil, 'icon must be a non-empty string'
  end

  return {
    name = name,
    label = label,
    slots = slots,
    maxWeight = maxWeight,
    owner = owner,
    jobs = jobs,
    coords = positions,
    distance = distance,
    instance = instance,
    icon = icon or DEFAULT_ICON,
  }, nil
end

--- Distance between two positions, in metres.
---@param a table The first position.
---@param b table The second position.
---@return number distance The distance.
local function distanceBetween(a, b)
  local dx <const> = a.x - b.x
  local dy <const> = a.y - b.y
  local dz <const> = a.z - b.z

  return math.sqrt(dx * dx + dy * dy + dz * dz)
end

--- How close a character has to stand to open a stash, in metres.
---@param definition table The stash definition.
---@return number distance The reach.
function GetStashDistance(definition)
  return definition.distance or InventoryConfig.stashDistance
end

--- Whether a position is close enough to open a stash. A stash that declared
--- no position is reachable from anywhere, which is what a stash opened by a
--- script rather than by walking up to it wants.
---@param definition table The stash definition.
---@param coords table The position of the character.
---@return boolean reachable Whether the stash is within reach.
function IsStashWithinReach(definition, coords)
  if not definition.coords then
    return true
  end

  if not isPosition(coords) then
    return false
  end

  local reach <const> = GetStashDistance(definition)

  for i = 1, #definition.coords do
    if distanceBetween(definition.coords[i], coords) <= reach then
      return true
    end
  end

  return false
end

--- The stashes written in shared/stashes.lua, normalised.
---@return table stashes The declared definitions, keyed by name.
function GetDeclaredStashes()
  return declared
end

--- Reads every declaration in the file, reporting by name whatever it had to
--- leave out. Called once at startup, the same way item definitions are.
---@return number faulty The number of declarations that were refused.
function ValidateStashDeclarations()
  local faulty = 0

  declared = {}

  for i = 1, #Stashes do
    local definition <const>, reason <const> = NormaliseStash(Stashes[i])

    if not definition then
      faulty = faulty + 1

      Siku.print.warn(T('stash_invalid', tostring(Stashes[i] and Stashes[i].name or i), reason))
    elseif declared[definition.name] then
      faulty = faulty + 1

      Siku.print.warn(T('stash_duplicate', definition.name))
    else
      declared[definition.name] = definition
    end
  end

  return faulty
end

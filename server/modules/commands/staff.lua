local RANDOM_PERMISSION <const> = 'inventory.staff.random'
local CLEAR_PERMISSION <const> = 'inventory.staff.clearInventory'
local GIVE_PERMISSION <const> = 'inventory.staff.giveitem'
local DEFAULT_KINDS <const> = 5
local MAX_KINDS <const> = 20
local MAX_PER_KIND <const> = 10

--- Every kind the resource declares, in a stable order.
---@return table items The item identifiers.
local function listCatalogueItems()
  local found <const> = {}

  for item in pairs(GetItemCatalogue()) do
    found[#found + 1] = item
  end

  table.sort(found)

  return found
end

--- How many of one kind to hand over.
---
--- A kind that does not stack gets exactly one, and nothing ever gets more
--- than its own stack allows: filling a bag with quantities that could not
--- exist would test the wrong thing.
---@param item string The internal item identifier.
---@return number count The quantity to give.
local function randomQuantity(item)
  local cap <const> = math.min(MAX_PER_KIND, GetItemMaxStack(item))

  return cap <= 1 and 1 or math.random(1, cap)
end

--- Draws distinct kinds, moving them to the front of the pool.
---
--- Partial Fisher-Yates: only as many positions as are being drawn get
--- settled, so drawing five kinds out of a large catalogue costs five swaps
--- rather than shuffling the whole thing.
---@param pool table The identifiers to draw from, reordered in place.
---@param wanted number How many to draw.
---@return number drawn How many sit at the front of the pool.
local function drawKinds(pool, wanted)
  local drawn <const> = math.min(wanted, #pool)

  for i = 1, drawn do
    local j <const> = math.random(i, #pool)

    pool[i], pool[j] = pool[j], pool[i]
  end

  return drawn
end

--- Fills the caller's inventory with a random assortment, for testing.
---
--- What actually lands is whatever fits: each kind is offered and the
--- inventory takes what it has room for, so a nearly full bag ends up with
--- less than was drawn rather than refusing the lot. What went in is what is
--- reported back.
Siku.RegisterCommand('randomitems', function(source, args)
  local character <const> = GetSessionCharacter(source)

  if not character then
    return NotifySession(source, 'error', T('notify_no_character'))
  end

  local pool <const> = listCatalogueItems()
  local drawn <const> = drawKinds(pool, args.count)
  local given = 0
  local kinds = 0

  for i = 1, drawn do
    local item <const> = pool[i]
    local added <const> = AddItem(character.id, item, randomQuantity(item))

    if added > 0 then
      given = given + added
      kinds = kinds + 1
    end
  end

  if given == 0 then
    return NotifySession(source, 'warning', T('notify_random_none'))
  end

  NotifySession(source, 'success', T('notify_random_given', given, kinds))
end, {
  permission = RANDOM_PERMISSION,
  description = T('command_random_description'),
  arguments = {
    {
      name = 'count',
      type = 'integer',
      optional = true,
      default = DEFAULT_KINDS,
      min = 1,
      max = MAX_KINDS,
      help = T('command_random_count'),
    },
  },
})

DeclareStaffPermission(RANDOM_PERMISSION)

--- Whether a member of staff outranks the character they are pointing at.
---
--- The permission says the command may be used; this says on whom. Without it
--- the two are the same question, and everyone holding the permission could
--- turn it on everyone else who holds it.
---@param sessionId number The player server id of whoever asked.
---@param targetCharacterId number The character being acted on.
---@return boolean allowed Whether the action may proceed.
local function outranks(sessionId, targetCharacterId)
  local character <const> = GetSessionCharacter(sessionId)

  return character ~= nil and Siku.permissions.canModify(character.id, targetCharacterId)
end

--- Names a session the way a member of staff would recognise it.
---@param sessionId number The player server id.
---@return string name The character name, falling back to the session id.
local function nameOf(sessionId)
  local identity <const> = GetSessionIdentity(sessionId)

  return identity and ('%s %s'):format(identity.firstName, identity.lastName)
    or tostring(sessionId)
end

--- Empties an inventory, destroying what was in it.
---
--- Naming nobody empties your own, which is the safe reading of a command that
--- keeps nothing back. Naming somebody demands outranking them: holding the
--- permission says the command exists, not that it may be turned on an equal.
---
--- Whoever is emptied is told by the inventory itself, so the only thing said
--- here is what the person who asked did not already know.
Siku.RegisterCommand('clearinv', function(source, args)
  local targetId <const> = args.target or source
  local character <const> = GetSessionCharacter(targetId)

  if not character then
    return NotifySession(source, 'error', T('notify_no_character'))
  end

  if targetId ~= source and not outranks(source, character.id) then
    return NotifySession(source, 'error', T('notify_outranked'))
  end

  local removed <const> = ClearInventory(character.id)

  if removed <= 0 then
    return NotifySession(source, 'warning', T('notify_clear_empty'))
  end

  if targetId ~= source then
    NotifySession(source, 'success', T('notify_clear_done', removed, nameOf(targetId)))
  end
end, {
  permission = CLEAR_PERMISSION,
  description = T('command_clear_description'),
  arguments = {
    {
      name = 'target',
      type = 'player',
      optional = true,
      help = T('command_clear_target'),
    },
  },
})

DeclareStaffPermission(CLEAR_PERMISSION)

--- Hands a quantity of any declared kind to a player.
---
--- Any kind at all: a weapon, a round, a component and a sandwich are all
--- items here, and nothing about handing one over is special-cased. A weapon
--- arrives with its own serial, a tool with its charges, a sandwich with its
--- shelf life — stamped where every other instance is stamped, on creation.
---
--- The target is named rather than assumed, because giving is what this is
--- for; only the quantity may be left out, and one is what that means.
Siku.RegisterCommand('giveitem', function(source, args)
  local character <const> = GetSessionCharacter(args.target)

  if not character then
    return NotifySession(source, 'error', T('notify_no_character'))
  end

  local added <const> = AddItem(character.id, args.item, args.count)
  local label <const> = GetItemDefinitionPayload(args.item).label

  --- The inventory says on its own what would not fit, so nothing is added
  --- here about the shortfall. What is said is what went in, to whoever asked
  --- and to whoever received — and once only when they are the same person.
  if added <= 0 then
    return NotifySession(source, 'warning', T('notify_give_none', label))
  end

  if args.target == source then
    return NotifySession(source, 'success', T('notify_received', added, label))
  end

  NotifySession(args.target, 'success', T('notify_received', added, label))
  NotifySession(source, 'success', T('notify_give_done', added, label, nameOf(args.target)))
end, {
  permission = GIVE_PERMISSION,
  description = T('command_give_description'),
  arguments = {
    {
      name = 'target',
      type = 'player',
      help = T('command_give_target'),
    },
    {
      name = 'item',
      type = 'item',
      help = T('command_give_item'),
    },
    {
      name = 'count',
      type = 'integer',
      optional = true,
      default = 1,
      min = 1,
      help = T('command_give_count'),
    },
  },
})

DeclareStaffPermission(GIVE_PERMISSION)

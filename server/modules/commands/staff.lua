local RANDOM_PERMISSION <const> = 'inventory.staff.random'
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
    return Siku.Notification(source, {
      type = 'error',
      title = T('notify_title'),
      description = T('notify_no_character'),
    })
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
    return Siku.Notification(source, {
      type = 'warning',
      title = T('notify_title'),
      description = T('notify_random_none'),
    })
  end

  Siku.Notification(source, {
    type = 'success',
    title = T('notify_title'),
    description = T('notify_random_given', given, kinds),
  })
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

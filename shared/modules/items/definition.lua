local UNKNOWN_LABEL <const> = 'item.unknown'
local TYPES <const> = { item = true, weapon = true, component = true }

--- Reads the definition of an item kind.
---@param item string The internal item identifier.
---@return table? definition The definition, or nil when the item is unknown.
function GetItemDefinition(item)
  if type(item) ~= 'string' then
    return nil
  end

  return Items[item]
end

--- Tells whether an item kind exists in the catalogue.
---@param item string The internal item identifier.
---@return boolean known Whether the item is declared.
function IsKnownItem(item)
  return GetItemDefinition(item) ~= nil
end

--- The family an item belongs to, so a behaviour can tell a firearm from a
--- consumable without matching on identifiers.
---@param item string The internal item identifier.
---@return string? kind The declared type.
function GetItemType(item)
  local definition <const> = GetItemDefinition(item)

  return definition and definition.type or nil
end

--- Weight of a single unit, in grams.
---@param item string The internal item identifier.
---@return number weight The unit weight, 0 when the item is unknown.
function GetItemWeight(item)
  local definition <const> = GetItemDefinition(item)

  return definition and definition.weight or 0
end

--- Weight of a whole stack, in grams.
---@param item string The internal item identifier.
---@param count number The quantity in the stack.
---@return number weight The stack weight.
function GetStackWeight(item, count)
  return GetItemWeight(item) * (count or 0)
end

--- What a stack weighs in full, everything it carries included.
---
--- This is the weight that counts against what a character can carry: an item
--- holding other items — a weapon wearing its parts, a box with something in
--- it — weighs itself plus them. Nothing gets lighter by being put inside
--- something else.
---@param stack table The stack.
---@return number weight The weight in grams.
function GetInstanceWeight(stack)
  return GetStackWeight(stack.item, stack.count)
    + GetFittedWeight(stack)
    + GetContainedWeight(stack)
end

--- Whether two units of this kind may ever share a slot.
---@param item string The internal item identifier.
---@return boolean stackable Whether the kind is stackable.
function IsItemStackable(item)
  local definition <const> = GetItemDefinition(item)

  return definition ~= nil and definition.stackable == true
end

--- Largest quantity a single stack may hold.
---@param item string The internal item identifier.
---@return number max The cap, or math.huge when the kind declares none.
function GetItemMaxStack(item)
  local definition <const> = GetItemDefinition(item)

  if not definition or not IsItemStackable(item) then
    return 1
  end

  return type(definition.maxStack) == 'number' and definition.maxStack or math.huge
end

--- Whether an instance of this kind carries its own identifier.
---@param item string The internal item identifier.
---@return boolean unique Whether instances are individually tracked.
function IsItemUnique(item)
  local definition <const> = GetItemDefinition(item)

  return definition ~= nil and definition.unique == true
end

--- Whether the use action should be offered for this kind.
---@param item string The internal item identifier.
---@return boolean usable Whether the item is usable.
function IsItemUsable(item)
  local definition <const> = GetItemDefinition(item)

  return definition ~= nil and definition.usable == true
end

--- Whether accepting a use should hand the screen back to the game.
---@param item string The internal item identifier.
---@return boolean close Whether the interface closes after a use.
function ClosesOnUse(item)
  local definition <const> = GetItemDefinition(item)

  return definition ~= nil and definition.closeOnUse == true
end

--- How many uses a fresh instance of this kind starts with.
---@param item string The internal item identifier.
---@return number? uses The starting uses, or nil when the kind has none.
function GetItemUses(item)
  local definition <const> = GetItemDefinition(item)

  return definition and type(definition.uses) == 'number' and definition.uses or nil
end

--- How long a fresh instance of this kind stays good, in milliseconds. The
--- speed declared on the item is read against the reference duration in the
--- configuration, so the whole economy is retuned from one place.
---@param item string The internal item identifier.
---@return number? lifetime The lifetime, or nil when the kind never spoils.
function GetItemDecayLifetime(item)
  local definition <const> = GetItemDefinition(item)
  local speed <const> = definition and definition.decay

  if type(speed) ~= 'number' or speed <= 0 then
    return nil
  end

  return InventoryConfig.decay.reference // speed
end

--- Whether every instance of this kind is stamped with its own serial number
--- the moment it comes into the world.
---@param item string The internal item identifier.
---@return boolean serialised Whether instances carry a serial.
function IsItemSerialised(item)
  local definition <const> = GetItemDefinition(item)

  return definition ~= nil and definition.serialised == true
end

--- How long using an instance of this kind occupies the character, in
--- milliseconds. Nil when the action is instant.
---@param item string The internal item identifier.
---@return number? useTime The duration, or nil when using is instant.
function GetItemUseTime(item)
  local definition <const> = GetItemDefinition(item)
  local useTime <const> = definition and definition.useTime

  return type(useTime) == 'number' and useTime > 0 and useTime or nil
end

--- Whether a spoiled instance of this kind is thrown away rather than kept.
---@param item string The internal item identifier.
---@return boolean removed Whether spoiling destroys the instance.
function RemovesOnDecay(item)
  local definition <const> = GetItemDefinition(item)

  return definition ~= nil and definition.removeOnDecay == true
end

--- The properties this kind allows out of the server, in reading order.
---
--- Two lists answer this: what the kind declares for itself, and what a script
--- added for every kind at runtime. The kind's own list comes first and wins
--- on a property both of them name — a definition that was written and
--- reviewed says more than one registered on the fly.
---
--- This is the one list, and it does two jobs at once: it says what the
--- interface shows, and it says what is allowed to leave the server at all.
--- Naming a property here is what makes it public, which is why only the
--- server side may add to it.
---@param item string The internal item identifier.
---@return table? fields The display fields, or nil when the kind shows nothing.
function GetItemDisplayFields(item)
  local definition <const> = GetItemDefinition(item)
  local declared <const> = definition and definition.metadata and definition.metadata.display
  local own <const> = type(declared) == 'table' and declared or nil
  local added <const> = GetRegisteredMetadataDisplay()

  if #added == 0 then
    return own
  end

  local fields <const> = {}
  local seen <const> = {}

  for i = 1, own and #own or 0 do
    fields[#fields + 1] = own[i]
    seen[own[i].key] = true
  end

  for i = 1, #added do
    if not seen[added[i].key] then
      fields[#fields + 1] = added[i]
    end
  end

  return #fields > 0 and fields or nil
end

--- Builds the client-facing description of an item kind. Nothing outside
--- this table is ever sent to the interface.
---@param item string The internal item identifier.
---@return table payload The kind as the interface reads it.
function GetItemDefinitionPayload(item)
  local definition <const> = GetItemDefinition(item)

  if not definition then
    return {
      id = item,
      name = item,
      label = UNKNOWN_LABEL,
      type = 'item',
      weight = 0,
      stackable = false,
      unique = false,
      usable = false,
      closeOnUse = false,
    }
  end

  local fields = nil
  local declared <const> = GetItemDisplayFields(item)

  if declared then
    fields = {}

    for i = 1, #declared do
      local field <const> = declared[i]

      fields[i] = {
        key = field.key,
        label = field.label,
        format = IsKnownMetadataFormat(field.format) and field.format or 'text',
      }
    end
  end

  return {
    id = item,
    name = definition.name,
    label = definition.label,
    description = definition.description,
    type = definition.type,
    weight = definition.weight,
    image = definition.image,
    stackable = definition.stackable == true,
    maxStack = type(definition.maxStack) == 'number' and definition.maxStack or nil,
    unique = definition.unique == true,
    usable = definition.usable == true,
    closeOnUse = definition.closeOnUse == true,
    uses = GetItemUses(item),
    decays = GetItemDecayLifetime(item) ~= nil,
    ammoType = definition.ammoType or nil,
    category = definition.category,
    slot = definition.slot,
    metadataFields = fields,
  }
end

--- Builds the whole catalogue as the interface reads it.
---@return table catalogue Every declared kind, indexed by identifier.
function GetItemCatalogue()
  local catalogue <const> = {}

  for item in pairs(Items) do
    catalogue[item] = GetItemDefinitionPayload(item)
  end

  return catalogue
end

--- Collects everything wrong with one definition. Reporting the whole list at
--- once beats stopping at the first mistake: a freshly written item usually
--- has more than one field missing, and fixing them one restart at a time is
--- what makes configuration painful.
---@param definition any The declared definition.
---@return table faults The problems found, empty when the definition is sound.
local function faultsOf(definition)
  local faults <const> = {}

  if type(definition) ~= 'table' then
    return { 'is not a table' }
  end

  local function requireString(field)
    if type(definition[field]) ~= 'string' or definition[field] == '' then
      faults[#faults + 1] = ('%s must be a non-empty string'):format(field)
    end
  end

  local function requireBoolean(field)
    if type(definition[field]) ~= 'boolean' then
      faults[#faults + 1] = ('%s must be declared true or false'):format(field)
    end
  end

  requireString('name')
  requireString('label')
  requireString('image')
  requireString('description')

  requireBoolean('stackable')
  requireBoolean('unique')
  requireBoolean('usable')
  requireBoolean('closeOnUse')

  if not TYPES[definition.type] then
    faults[#faults + 1] = ("type must be 'item', 'weapon' or 'component'")
  end

  if type(definition.weight) ~= 'number' or definition.weight < 0 then
    faults[#faults + 1] = 'weight must be a number of grams, zero or more'
  end

  if definition.stackable == true and definition.unique == true then
    faults[#faults + 1] = 'an instance tracked on its own can never share a slot: '
      .. 'stackable and unique cannot both be true'
  end

  if definition.maxStack ~= nil and definition.maxStack ~= false then
    if type(definition.maxStack) ~= 'number' or definition.maxStack < 1 then
      faults[#faults + 1] = 'maxStack must be false or a positive number'
    elseif definition.stackable ~= true then
      faults[#faults + 1] = 'maxStack only means something when stackable is true'
    end
  end

  if definition.decay ~= nil and definition.decay ~= false then
    if type(definition.decay) ~= 'number' or definition.decay < 1 or definition.decay > 10 then
      faults[#faults + 1] = 'decay must be false or a speed between 1 and 10'
    elseif type(definition.removeOnDecay) ~= 'boolean' then
      faults[#faults + 1] = 'removeOnDecay must be declared alongside decay'
    end
  end

  if definition.useTime ~= nil then
    if type(definition.useTime) ~= 'number' or definition.useTime < 1 or definition.useTime % 1 ~= 0 then
      faults[#faults + 1] = 'useTime must be a whole number of milliseconds'
    elseif definition.usable ~= true then
      faults[#faults + 1] = 'useTime only means something when usable is true'
    elseif definition.type == 'weapon' then
      faults[#faults + 1] = 'a weapon is drawn rather than used, so it takes no useTime'
    end
  end

  if definition.uses ~= nil then
    if type(definition.uses) ~= 'number' or definition.uses < 1 or definition.uses % 1 ~= 0 then
      faults[#faults + 1] = 'uses must be a positive whole number'
    elseif definition.stackable == true then
      faults[#faults + 1] = 'an item counting its uses cannot be stackable'
    end
  end

  if definition.type == 'weapon' then
    if not WeaponCategories[definition.category] then
      faults[#faults + 1] = 'a weapon must belong to a declared category'
    end

    if definition.ammoType ~= false and type(definition.ammoType) ~= 'string' then
      faults[#faults + 1] = 'ammoType must name a round, or be false when the weapon fires none'
    end

    if type(definition.ammoType) == 'string' and not Ammo[definition.ammoType] then
      faults[#faults + 1] = ('ammoType %q is not declared in ammo.lua'):format(definition.ammoType)
    end
  end

  if definition.type == 'component' then
    if not IsKnownWeaponSlot(definition.slot) then
      faults[#faults + 1] = 'a component must declare a slot the configuration knows'
    end

    if type(definition.variants) ~= 'table' or #definition.variants == 0 then
      faults[#faults + 1] = 'a component must list the game components it stands for'
    else
      for i = 1, #definition.variants do
        if type(definition.variants[i]) ~= 'string' then
          faults[#faults + 1] = ('variants[%d] is not a component name'):format(i)
        end
      end
    end
  end

  local declared <const> = definition.metadata and definition.metadata.display

  if definition.metadata ~= nil and type(declared) ~= 'table' then
    faults[#faults + 1] = 'metadata must hold a display list'
  elseif declared then
    for i = 1, #declared do
      local field <const> = declared[i]

      if type(field) ~= 'table' or type(field.key) ~= 'string' or type(field.label) ~= 'string' then
        faults[#faults + 1] = ('metadata.display[%d] needs a key and a label'):format(i)
      end
    end
  end

  return faults
end

--- Checks every declared item and reports what is wrong, by name. A bad
--- definition is a configuration mistake, not a reason to take the server
--- down: the resource keeps running and says exactly which item to fix.
---@return number faulty The number of items that failed validation.
function ValidateItemDefinitions()
  local faulty = 0

  for item, definition in pairs(Items) do
    local faults <const> = faultsOf(definition)

    if #faults > 0 then
      faulty = faulty + 1

      Siku.print.error(T('item_invalid', item, table.concat(faults, ', ')))
    end
  end

  return faulty
end

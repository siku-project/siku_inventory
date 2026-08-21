local handlers <const> = {}

--- Reads what a resource registered against an item.
---
--- A plain function is the whole behaviour and nothing more. A table may also
--- carry a `canUse`, asked before anything happens — before the progress bar
--- above all, so a bandage refused at full health costs the character no time
--- at all rather than two and a half seconds and a shrug.
---@param handler any The value the caller registered.
---@return table? behaviour The accepted behaviour, nil when the shape is wrong.
local function readBehaviour(handler)
  if IsCallable(handler) then
    return { onUse = handler }
  end

  if type(handler) ~= 'table' or not IsCallable(handler.onUse) then
    return nil
  end

  if handler.canUse ~= nil and not IsCallable(handler.canUse) then
    return nil
  end

  return { canUse = handler.canUse, onUse = handler.onUse }
end

--- Describes the instance being used, without handing over the inventory.
---@param slot number The slot holding the item.
---@param stack table The stack being used.
---@return table context What a behaviour is told about the instance.
local function describe(slot, stack)
  return {
    slot = slot,
    item = stack.item,
    count = stack.count,
    uid = stack.uid,
    uses = stack.uses,
    metadata = stack.metadata and Siku.table.deepClone(stack.metadata) or nil,
  }
end

--- Registers what happens when an item is used. Behaviour lives in the
--- resource that owns the item, not in a switch here: a medkit belongs to the
--- medical resource, a radio to the radio resource. This resource only proves
--- the player really holds the item and hands over control.
---@param name string The item identifier, the key it has in the catalogue.
---@param handler function|table The behaviour, or { canUse?, onUse }.
---@return boolean registered Whether the behaviour was stored.
function RegisterItemUse(name, handler)
  if not IsKnownItem(name) then
    Siku.print.warn(T('use_unknown_item', tostring(name)))

    return false
  end

  local behaviour <const> = readBehaviour(handler)

  if not behaviour then
    Siku.print.warn(T('use_invalid_handler', name))

    return false
  end

  handlers[name] = behaviour

  return true
end

--- Removes a use handler.
---@param name string The item identifier.
---@return boolean removed Whether a behaviour was registered.
function UnregisterItemUse(name)
  local existed <const> = handlers[name] ~= nil

  handlers[name] = nil

  return existed
end

--- Asks the behaviour whether the use should happen at all.
---
--- Only the owner of an item knows whether using it makes sense right now, and
--- it is asked before the character is occupied. Anything other than an
--- explicit refusal lets the use proceed: an item with no opinion is not an
--- item that says no.
---@param sessionId number The player server id.
---@param slot number The slot holding the item.
---@param stack table The stack being used.
---@return boolean allowed Whether the use may go ahead.
function AllowsItemUse(sessionId, slot, stack)
  local behaviour <const> = handlers[stack.item]

  if not behaviour or not behaviour.canUse then
    return true
  end

  local ok <const>, allowed <const> = pcall(behaviour.canUse, sessionId, describe(slot, stack))

  if not ok then
    Siku.print.error(T('use_handler_failed', stack.item, tostring(allowed)))

    return false
  end

  return allowed ~= false
end

--- Runs the behaviour bound to an item, if any. The context hands over a
--- consume helper rather than the inventory itself, so a behaviour can spend
--- the item without being able to rewrite everything else.
---@param sessionId number The player server id.
---@param inventory table The character inventory.
---@param slot number The slot holding the item.
---@param stack table The stack being used.
---@return nil
function RunItemUse(sessionId, inventory, slot, stack)
  local behaviour <const> = handlers[stack.item]

  if not behaviour then
    Siku.print.debug(('No use handler bound to %q'):format(stack.item))

    return
  end

  local context <const> = describe(slot, stack)

  context.consume = function(quantity)
    local current <const> = inventory:getStack(slot)

    if not current or current.item ~= stack.item or current.uid ~= stack.uid then
      return 0
    end

    local wanted <const> = ReadCount(quantity) or 1
    local taken <const> = inventory:takeFromSlot(slot, wanted)

    if not taken then
      return 0
    end

    SaveInventory(inventory)
    NotifyInventoryChanged(inventory)

    return taken.count
  end

  context.spendUse = function(quantity)
    local current <const> = inventory:getStack(slot)

    if not current or current.item ~= stack.item or current.uid ~= stack.uid then
      return nil
    end

    if type(current.uses) ~= 'number' then
      return nil
    end

    local spent <const> = ReadCount(quantity) or 1
    local left <const> = math.max(0, current.uses - spent)

    if left <= 0 then
      inventory:takeFromSlot(slot, current.count)
    else
      current.uses = left
      inventory:touch()
    end

    SaveInventory(inventory)
    NotifyInventoryChanged(inventory)

    return left > 0 and left or nil
  end

  local ok <const>, err <const> = pcall(behaviour.onUse, sessionId, context)

  if not ok then
    Siku.print.error(T('use_handler_failed', stack.item, tostring(err)))
  end
end

exports('RegisterItemUse', RegisterItemUse)
exports('UnregisterItemUse', UnregisterItemUse)

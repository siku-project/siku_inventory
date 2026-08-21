local state = {
  inventory = nil,
  ground = {},
  container = nil,
}

local identity = nil
local isOpen = false

--- Reads the last state the server pushed.
---@return table current The cached state.
function GetInventoryState()
  return state
end

--- Replaces the cached state.
---@param next table The state the server pushed.
---@return nil
function SetInventoryState(next)
  if type(next) ~= 'table' then
    return
  end

  state = {
    inventory = next.inventory,
    ground = next.ground or {},
    container = next.container,
  }
end

--- Replaces only what lies on the ground, leaving the bag untouched.
---@param entries table The ground the server pushed.
---@return nil
function SetGroundState(entries)
  state.ground = type(entries) == 'table' and entries or {}
end

--- Replaces the second container, the one shown beside the bag. Nil closes
--- it: nothing else on the screen is concerned.
---@param payload table? The container the server pushed.
---@return nil
function SetContainerState(payload)
  state.container = type(payload) == 'table' and payload or nil
end

--- Reads the identity of the character the interface belongs to.
---@return table? current The cached identity.
function GetCharacterIdentity()
  return identity
end

--- Remembers who the interface belongs to. It is kept here rather than asked
--- for when the screen opens: the name is pushed once when the character
--- becomes active, and the interface may open long before or after that.
---@param next table The identity the server pushed.
---@return nil
function SetCharacterIdentity(next)
  if type(next) ~= 'table' then
    return
  end

  identity = {
    firstName = next.firstName,
    lastName = next.lastName,
  }
end

--- Whether the interface is currently showing.
---@return boolean open Whether the inventory is open.
function IsInventoryOpen()
  return isOpen
end

exports('IsInventoryOpen', IsInventoryOpen)

--- Records whether the interface is showing.
---@param open boolean The new state.
---@return nil
function SetInventoryOpen(open)
  isOpen = open == true
end

--- Reads the slot number a hotbar index stands for, when it holds something.
--- The hotbar is a part of the inventory rather than a set of shortcuts, so
--- the answer is a real slot the server already knows about.
---@param index number The hotbar index.
---@return number? slot The inventory slot, or nil when the index is empty.
function GetHotbarSlot(index)
  local inventory <const> = state.inventory

  if type(index) ~= 'number' or not IsValidHotbarIndex(index) then
    return nil
  end

  if not inventory or type(inventory.hotbar) ~= 'table' then
    return nil
  end

  local stack <const> = inventory.hotbar[tostring(index)]

  return stack and GetHotbarSlotId(index) or nil
end

exports('GetHotbarSlot', GetHotbarSlot)

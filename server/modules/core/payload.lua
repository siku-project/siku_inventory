--- Turns a stack into what the interface is allowed to see. Everything the
--- carried grid, the hotbar and the ground show goes through here, so a field
--- can never be exposed in one place and withheld in another.
---
--- Freshness is sent as a share left rather than as a timestamp: the client
--- has no business knowing when something spoils, only how full the gauge is
--- at the moment the server answered.
---@param stack table The stored stack.
---@param slot number The slot it sits in.
---@return table payload The stack as the interface reads it.
function BuildStackPayload(stack, slot)
  return {
    slot = slot,
    item = stack.item,
    count = stack.count,
    uid = stack.uid,
    weight = GetInstanceWeight(stack),
    metadata = FilterPublicMetadata(stack.item, stack.metadata),
    uses = stack.uses,
    maxUses = GetItemUses(stack.item),
    freshness = GetStackFreshness(stack),
  }
end

--- How much of an instance's shelf life is left, between 0 and 1. Nil when
--- the kind never spoils, which is what tells the interface not to draw a
--- gauge at all.
---@param stack table The stored stack.
---@return number? freshness The share left, or nil when it never spoils.
function GetStackFreshness(stack)
  local lifetime <const> = GetItemDecayLifetime(stack.item)

  if not lifetime or not stack.expiresAt then
    return nil
  end

  local left <const> = stack.expiresAt - os.time() * 1000

  return math.max(0, math.min(1, left / lifetime))
end

--- Whether an instance has spoiled. A kind that never decays never has.
---@param stack table The stored stack.
---@return boolean spoiled Whether the instance is past its life.
function IsStackSpoiled(stack)
  local freshness <const> = GetStackFreshness(stack)

  return freshness ~= nil and freshness <= 0
end

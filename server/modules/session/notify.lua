--- Tells a player something about their inventory.
---
--- Only ever for what happens *to* them: a refused action already answers on
--- its own way back, and saying it twice is worse than not saying it at all.
--- What is left is everything nobody asked for — time passing, another
--- resource reaching in — where there is no refusal to carry the news.
---@param sessionId any The player server id.
---@param kind string The notification kind: 'success', 'warning' or 'error'.
---@param description string The line the player reads.
---@return nil
function NotifySession(sessionId, kind, description)
  if type(sessionId) ~= 'number' then
    return
  end

  Siku.Notification(sessionId, {
    type = kind,
    title = T('notify_title'),
    description = description,
  })
end

--- Tells whoever is playing the character an inventory belongs to.
---
--- Says nothing for a container nobody is carrying: a stash or a drop has no
--- one to tell, and a character nobody is playing has nobody listening.
---@param inventory any The inventory that changed.
---@param kind string The notification kind.
---@param description string The line the player reads.
---@return nil
function NotifyInventoryOwner(inventory, kind, description)
  if type(inventory) ~= 'table' or not inventory:isCharacter() then
    return
  end

  NotifySession(GetSessionOfCharacter(inventory.ownerId), kind, description)
end

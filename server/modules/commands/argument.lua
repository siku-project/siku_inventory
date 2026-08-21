--- Refuses an item nobody declared, rather than lowercasing whatever was typed.
---
--- The SDK ships a permissive `item` type and says outright that it waits for
--- this resource to replace it: the registry of declared kinds lives here, so
--- this is the only place that can answer whether a name means anything.
---
--- Refusing during parsing is what makes the answer useful. A command reaches
--- its handler with a kind that exists, and a typo comes back as a refusal
--- naming itself instead of as a request that quietly does nothing.
Siku.RegisterCommandType('item', function(raw, def)
  local item <const> = raw:lower()

  if not IsKnownItem(item) then
    return nil, ('\'%s\' is not a declared item'):format(def.name)
  end

  return item
end)

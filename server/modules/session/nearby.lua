--- Lists the characters a session may hand something to.
---
--- Who is within reach is asked of the SDK, which reads the peds the same way
--- the give itself is checked. What this adds is the part the SDK cannot know:
--- a session with no character behind it is not a recipient, and what a player
--- sees in the dialog is the civil identity the world shows rather than a
--- server id.
---@param sessionId number The player server id asking.
---@return table players The reachable characters.
function GetNearbySessions(sessionId)
  local coords <const> = GetSessionCoords(sessionId)

  if not coords then
    return {}
  end

  local nearby <const> = Siku.GetNearbyPlayers(coords, InventoryConfig.giveDistance, sessionId)
  local found <const> = {}

  for i = 1, #nearby do
    local other <const> = nearby[i]
    local identity <const> = GetSessionIdentity(other.playerId)

    if identity then
      found[#found + 1] = {
        id = other.playerId,
        name = ('%s %s'):format(identity.firstName or '', identity.lastName or ''),
        distance = Siku.math.round(other.distance, 1),
      }
    end
  end

  return found
end

Siku.RegisterCallback('siku_inventory:callback:nearbyPlayers', function(sessionId)
  return GetNearbySessions(sessionId)
end)

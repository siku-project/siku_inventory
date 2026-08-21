--- Lists the characters the player can hand something to. The answer comes
--- from the server, which is the only side that knows who is behind a ped and
--- the only side the transfer is checked against: the interface never invents
--- a target the server would not accept.
---@return table players The reachable characters.
function GetNearbyPlayerList()
  local ok <const>, players <const> = Siku.TriggerServerCallback(
    'siku_inventory:callback:nearbyPlayers'
  )

  if not ok or type(players) ~= 'table' then
    return {}
  end

  return players
end

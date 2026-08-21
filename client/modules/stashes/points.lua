local registered <const> = {}

local inside = {}
local prompted = nil
local keybind = nil

--- The name of the key that opens a stash, as it reads on this player's own
--- keyboard. Asked of the binding rather than of the config: a player who
--- rebound it is shown what they actually press.
---@return string key The key to press.
local function promptKey()
  local bound <const> = keybind and keybind.getCurrentKey() or nil

  return type(bound) == 'string' and bound ~= '' and bound or InventoryConfig.stashKey:upper()
end

--- Shows or hides the hint telling the character a stash is within reach.
---@param stash table? The stash in reach, or nil when there is none.
---@return nil
local function setPrompt(stash)
  if prompted == stash then
    return
  end

  prompted = stash

  SendNUIMessage({
    action = 'siku_inventory:nui:setPrompt',
    prompt = stash and { label = stash.label, key = promptKey() } or false,
  })
end

--- The stash a character would open by pressing the key: the nearest one they
--- are standing in.
---@return table? stash The stash in reach.
local function reachable()
  local closest = nil
  local shortest = math.huge

  for name, distance in pairs(inside) do
    if distance < shortest and registered[name] then
      closest = registered[name]
      shortest = distance
    end
  end

  return closest
end

--- Refreshes the hint after anything changed which stash is nearest.
---@return nil
local function refreshPrompt()
  setPrompt(reachable())
end

--- Drops every point being watched, so a new list replaces the old one whole
--- rather than piling up beside it.
---@return nil
local function clearPoints()
  for name, stash in pairs(registered) do
    for i = 1, #stash.handles do
      stash.handles[i].remove()
    end

    registered[name] = nil
  end

  inside = {}

  refreshPrompt()
end

--- Watches one position of one stash.
---@param stash table The stash being watched.
---@param coords vector3 The position to watch.
---@return table handle The point handle.
local function watchPosition(stash, coords)
  return Siku.AddPoint({
    coords = coords,
    radius = stash.distance,
    onEnter = function()
      inside[stash.name] = stash.distance

      refreshPrompt()
    end,
    onExit = function()
      inside[stash.name] = nil

      refreshPrompt()
    end,
    onNearby = function(_, distance)
      if inside[stash.name] then
        inside[stash.name] = distance
      end
    end,
  })
end

--- Replaces the stashes a character can walk up to.
---
--- The list is the server's, and it is sent again whenever it changes: a
--- stash created while somebody was standing where it now is starts working
--- for them without them moving.
---@param points table The stashes the server declared.
---@return nil
function SetStashPoints(points)
  clearPoints()

  if type(points) ~= 'table' then
    return
  end

  for i = 1, #points do
    local point <const> = points[i]

    if type(point) == 'table' and type(point.name) == 'string' and type(point.coords) == 'table' then
      local stash <const> = {
        name = point.name,
        label = point.label,
        distance = type(point.distance) == 'number' and point.distance or InventoryConfig.stashDistance,
        handles = {},
      }

      for index = 1, #point.coords do
        local coords <const> = point.coords[index]

        stash.handles[#stash.handles + 1] = watchPosition(stash, vector3(coords.x, coords.y, coords.z))
      end

      if #stash.handles > 0 then
        registered[point.name] = stash
      end
    end
  end
end

--- Opens whatever stash the character is standing at.
---@return boolean asked Whether a stash was in reach.
function OpenReachableStash()
  local stash <const> = reachable()

  return stash ~= nil and OpenContainer('stash', { name = stash.name })
end

keybind = Siku.AddKeybind({
  name = 'siku_inventory_stash',
  description = T('keybind_stash'),
  defaultKey = InventoryConfig.stashKey,
  onPressed = function()
    if IsInventoryOpen() or not CanOpenInventory() then
      return
    end

    OpenReachableStash()
  end,
})

RegisterNetEvent('siku_inventory:client:setStashPoints', function(points)
  SetStashPoints(points)
end)

AddEventHandler('onResourceStop', function(resource)
  if resource == GetCurrentResourceName() then
    clearPoints()
  end
end)

local BLUR_TRANSITION <const> = 500

--- Turns the game's own depth-of-field pass on or off behind the interface.
--- This is the native screen effect, not a CSS filter: it costs the interface
--- nothing and it reads as part of the game rather than as a web overlay.
---@param enabled boolean Whether the world should be blurred.
---@return nil
local function setWorldBlur(enabled)
  if not InventoryConfig.blurWorld then
    return
  end

  if enabled then
    TriggerScreenblurFadeIn(BLUR_TRANSITION)

    return
  end

  TriggerScreenblurFadeOut(BLUR_TRANSITION)
end

--- Whether the character is in a state to open their bag at all.
---
--- Asked here rather than by each caller, because a key, an export and another
--- resource must all get the same answer. The pause menu is left out: the SDK
--- already swallows a keybind while it is up, and a script asking to open the
--- screen from behind it is asking deliberately.
---@return boolean allowed Whether the screen may open.
function CanOpenInventory()
  local ped <const> = PlayerPedId()

  return DoesEntityExist(ped) and not IsEntityDead(ped)
end

--- Shows the interface and hands the mouse over to it.
---@return nil
function OpenInventoryScreen()
  if IsInventoryOpen() then
    return
  end

  SetInventoryOpen(true)
  SetNuiFocus(true, true)
  setWorldBlur(true)

  SendNUIMessage({
    action = 'siku_inventory:nui:setOpen',
    open = true,
  })

  TriggerServerEvent('siku_inventory:server:openScreen')
end

--- Hides the interface and gives control back to the game.
---@return nil
function CloseInventoryScreen()
  if not IsInventoryOpen() then
    return
  end

  SetInventoryOpen(false)
  SetNuiFocus(false, false)
  setWorldBlur(false)

  SendNUIMessage({
    action = 'siku_inventory:nui:setOpen',
    open = false,
  })

  TriggerServerEvent('siku_inventory:server:closeScreen')
end

--- Opens the local character's inventory, if they are in a state to open one.
---@return boolean opened Whether the screen was asked to open.
function OpenInventory()
  if IsInventoryOpen() then
    return true
  end

  if not CanOpenInventory() then
    return false
  end

  OpenInventoryScreen()

  return true
end

exports('OpenInventory', OpenInventory)

--- Closes the local character's inventory.
---@return boolean closed Whether the screen was open and got closed.
function CloseInventory()
  if not IsInventoryOpen() then
    return false
  end

  CloseInventoryScreen()

  return true
end

exports('CloseInventory', CloseInventory)

--- Sends the current state to the interface.
---@param state table The state to publish.
---@return nil
function PublishInventoryState(state)
  SendNUIMessage({
    action = 'siku_inventory:nui:setState',
    state = state,
  })
end

--- Sends what lies on the ground to the interface, on its own.
---@param entries table The ground the server pushed.
---@return nil
function PublishGroundState(entries)
  SendNUIMessage({
    action = 'siku_inventory:nui:setGround',
    ground = entries,
  })
end

--- Sends the second container to the interface, on its own. Sending nothing
--- is how it goes away.
---@param payload table? The container the server pushed.
---@return nil
function PublishContainerState(payload)
  SendNUIMessage({
    action = 'siku_inventory:nui:setContainer',
    container = payload or false,
  })
end

--- Sends the catalogue to the interface again, after what an item is allowed
--- to show changed under it.
---@return nil
function PublishItemCatalogue()
  SendNUIMessage({
    action = 'siku_inventory:nui:setCatalogue',
    catalogue = GetItemCatalogue(),
  })
end

--- Sends the character identity to the interface, when one is known.
---@return nil
function PublishCharacterIdentity()
  local identity <const> = GetCharacterIdentity()

  if not identity then
    return
  end

  SendNUIMessage({
    action = 'siku_inventory:nui:setIdentity',
    identity = identity,
  })
end

AddEventHandler('onResourceStop', function(resource)
  if resource ~= GetCurrentResourceName() then
    return
  end

  SetNuiFocus(false, false)

  if InventoryConfig.blurWorld then
    TriggerScreenblurFadeOut(0)
  end
end)

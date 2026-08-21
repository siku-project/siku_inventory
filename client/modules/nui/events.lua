RegisterNetEvent('siku_inventory:client:setState', function(state)
  SetInventoryState(state)
  PublishInventoryState(GetInventoryState())
end)

RegisterNetEvent('siku_inventory:client:setGround', function(entries)
  SetGroundState(entries)
  PublishGroundState(GetInventoryState().ground)
end)

RegisterNetEvent('siku_inventory:client:setContainer', function(payload)
  SetContainerState(payload)
  PublishContainerState(GetInventoryState().container)
end)

RegisterNetEvent('siku_inventory:client:openContainer', function()
  if IsInventoryOpen() then
    return
  end

  if not CanOpenInventory() then
    TriggerServerEvent('siku_inventory:server:closeScreen')

    return
  end

  OpenInventoryScreen()
end)

RegisterNetEvent('siku_inventory:client:setMetadataDisplay', function(fields)
  SetRegisteredMetadataDisplay(fields)
  PublishItemCatalogue()
end)

RegisterNetEvent('siku_inventory:client:setIdentity', function(payload)
  SetCharacterIdentity(payload)
  PublishCharacterIdentity()
end)

RegisterNetEvent('siku_inventory:client:close', function()
  CloseInventoryScreen()
end)

RegisterNetEvent('siku_inventory:client:actionRefused', function(reason)
  local key <const> = type(reason) == 'string' and reason or 'refused'

  if IsInventoryOpen() then
    SendNUIMessage({
      action = 'siku_inventory:nui:actionRefused',
      reason = key,
    })

    return
  end

  local web <const> = GetTranslations().web or {}

  Siku.Notification({
    type = 'error',
    title = T('notify_title'),
    description = web['error.' .. key] or web['error.refused'] or key,
  })
end)

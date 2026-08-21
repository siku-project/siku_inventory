RegisterNUICallback('siku_inventory:nui:ready', function(_, cb)
  cb({})

  SendNUIMessage({
    action = 'siku_inventory:nui:setLocale',
    locale = {
      language = TranslationConfig.language,
      translations = GetTranslations(),
    },
  })

  SendNUIMessage({
    action = 'siku_inventory:nui:setConfig',
    config = {
      slots = InventoryConfig.slots,
      maxWeight = InventoryConfig.maxWeight,
      hotbarSlots = HOTBAR_SLOTS,
    },
  })

  SendNUIMessage({
    action = 'siku_inventory:nui:setCatalogue',
    catalogue = GetItemCatalogue(),
  })

  PublishCharacterIdentity()
end)

RegisterNUICallback('siku_inventory:nui:close', function(_, cb)
  cb({})
  CloseInventoryScreen()
end)

RegisterNUICallback('siku_inventory:nui:move', function(data, cb)
  cb({})
  TriggerServerEvent('siku_inventory:server:move', data)
end)

RegisterNUICallback('siku_inventory:nui:split', function(data, cb)
  cb({})
  TriggerServerEvent('siku_inventory:server:split', data)
end)

RegisterNUICallback('siku_inventory:nui:use', function(data, cb)
  cb({})
  TriggerServerEvent('siku_inventory:server:use', data)
end)

RegisterNUICallback('siku_inventory:nui:give', function(data, cb)
  cb({})
  TriggerServerEvent('siku_inventory:server:give', data)
end)

RegisterNUICallback('siku_inventory:nui:nearbyPlayers', function(_, cb)
  cb(GetNearbyPlayerList())
end)

RegisterNUICallback('siku_inventory:nui:openCustomization', function(data, cb)
  cb({})
  TriggerServerEvent('siku_inventory:server:openCustomization', data)
end)

RegisterNUICallback('siku_inventory:nui:fitComponent', function(data, cb)
  cb({})
  FitComponent(data.slot, data.item)
end)

RegisterNUICallback('siku_inventory:nui:clearComponent', function(data, cb)
  cb({})
  ClearComponent(data.slot)
end)

RegisterNUICallback('siku_inventory:nui:closeCustomization', function(data, cb)
  cb({})
  CloseCustomization(data.save ~= false)
end)

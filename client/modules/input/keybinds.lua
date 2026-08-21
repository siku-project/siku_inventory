local HOTBAR_KEYS <const> = { '1', '2', '3', '4', '5' }
local RELOAD_KEY <const> = 'r'

Siku.AddKeybind({
  name = 'siku_inventory_open',
  description = T('keybind_open'),
  defaultKey = InventoryConfig.openKey,
  onPressed = function()
    if IsInventoryOpen() then
      CloseInventoryScreen()

      return
    end

    if not CanOpenInventory() then
      return
    end

    if OpenReachableCompartment() then
      return
    end

    OpenInventoryScreen()
  end,
})

for index = 1, HOTBAR_SLOTS do
  Siku.AddKeybind({
    name = ('siku_inventory_hotbar_%d'):format(index),
    description = T('keybind_hotbar', index),
    defaultKey = HOTBAR_KEYS[index],
    onPressed = function()
      if IsInventoryOpen() or not CanOpenInventory() then
        return
      end

      local slot <const> = GetHotbarSlot(index)

      if not slot then
        return
      end

      TriggerServerEvent('siku_inventory:server:use', { slot = slot })
    end,
  })
end

Siku.AddKeybind({
  name = 'siku_inventory_reload',
  description = T('keybind_reload'),
  defaultKey = RELOAD_KEY,
  onPressed = function()
    if IsInventoryOpen() or not CanOpenInventory() then
      return
    end

    ReloadDrawnWeapon()
  end,
})

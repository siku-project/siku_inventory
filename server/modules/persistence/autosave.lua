local AUTOSAVE_INTERVAL <const> = 300000

Siku.SetInterval(AUTOSAVE_INTERVAL, function()
  local saved <const> = SaveAllInventories()

  if saved > 0 then
    Siku.print.debug(('Autosave wrote %d inventor(ies)'):format(saved))
  end
end)

AddEventHandler('onResourceStop', function(resource)
  if resource ~= GetCurrentResourceName() then
    return
  end

  local saved <const> = SaveAllInventories()

  if saved > 0 then
    Siku.print.info(T('shutdown_saved', saved))
  end
end)

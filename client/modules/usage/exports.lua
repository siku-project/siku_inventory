local STARTED <const> = 'started'

RegisterNetEvent('siku_inventory:client:useExport', function(resource, export, item)
  if type(resource) ~= 'string' or type(export) ~= 'string' or type(item) ~= 'table' then
    return
  end

  if GetResourceState(resource) ~= STARTED then
    return
  end

  local ok <const>, err <const> = pcall(function()
    exports[resource][export](item)
  end)

  if not ok then
    Siku.print.error(('Client use export %s.%s failed: %s'):format(resource, export, tostring(err)))
  end
end)

--- Whether a value can be called.
---
--- Not the same question as whether it is a function. A handler handed over by
--- another resource crosses an export boundary on the way here, and what
--- arrives is a table carrying `__call` rather than the function that was
--- written. Asking for a function would refuse every handler that came from
--- outside — which is every handler this resource is given.
---@param value any The value to check.
---@return boolean callable Whether the value can be called.
function IsCallable(value)
  if type(value) == 'function' then
    return true
  end

  local meta <const> = getmetatable(value)

  return meta ~= nil and meta.__call ~= nil
end

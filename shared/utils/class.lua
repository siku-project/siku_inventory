--- Builds a class this resource owns.
---
--- Deliberately not the SDK's `Siku.Class`. A class is a metatable, and a
--- metatable does not survive the crossing between two resources: calling the
--- core's builder would define the constructor on this side and look for it on
--- the other, where it does not exist. The instance would come back empty —
--- no identifier, no methods — and only fail later, somewhere else.
---
--- So classes are built here, where they are used, and nothing about them ever
--- leaves the resource.
---@param name string The class name, for tostring.
---@return table class The class, with a `new` that runs `constructor`.
function CreateClass(name)
  local class <const> = {}

  class.__index = class
  class.__name = name
  class.__tostring = function()
    return name
  end

  --- Builds an instance and runs its constructor when one is declared.
  ---@return table instance The new instance.
  class.new = function(...)
    local instance <const> = setmetatable({}, class)

    if instance.constructor then
      instance.constructor(instance, ...)
    end

    return instance
  end

  return class
end

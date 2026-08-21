local POLL_INTERVAL <const> = 500
local WAIT_TIMEOUT <const> = 60000

local declared <const> = {}

--- Declares a permission this resource demands, so the configured role is
--- given it at startup.
---
--- Called at load, from wherever the command that demands it is declared: a
--- permission and the command it guards belong together, and a list kept
--- somewhere else is a list that goes stale.
---@param permission string The permission string.
---@return nil
function DeclareStaffPermission(permission)
  declared[#declared + 1] = permission
end

--- Whether the core has finished loading its roles.
---
--- Waiting on the migration is not enough: the roles are cached after it, and
--- a grant asked for before that finds no role to grant to and quietly does
--- nothing.
---@return boolean ready Whether the roles are known.
local function areRolesReady()
  local roles <const> = Siku.permissions.getAllRoles()

  return type(roles) == 'table' and #roles > 0
end

--- Gives the configured role every permission this resource declared.
---@return nil
local function grantDeclaredPermissions()
  local role <const> = InventoryConfig.staffRole

  if type(role) ~= 'string' or role == '' or #declared == 0 then
    return
  end

  local deadline <const> = GetGameTimer() + WAIT_TIMEOUT

  while not areRolesReady() do
    if GetGameTimer() >= deadline then
      return Siku.print.warn(T('staff_roles_unavailable', role))
    end

    Wait(POLL_INTERVAL)
  end

  for i = 1, #declared do
    if Siku.permissions.addPermissionToRole(role, declared[i]) then
      Siku.print.info(T('staff_permission_granted', declared[i], role))
    end
  end
end

CreateThread(grantDeclaredPermissions)

local REQUIRED_CORE_VERSION <const> = '0.2.0'

local dependency <const> = Siku.CheckDependency('siku_core', REQUIRED_CORE_VERSION)

if not dependency.ok then
  Siku.print.throw(dependency.message)
end

local migrated <const> = Siku.RunMigration(MigrationConfig)

Siku.print.success(('Linked to siku_core (%s)'):format(dependency.currentVersion))
Siku.VersionCheck('siku-project/siku_inventory')

local faulty <const> = ValidateItemDefinitions()

if faulty > 0 then
  Siku.print.warn(T('items_invalid_total', faulty))
end

local faultyStashes <const> = ValidateStashDeclarations()

if faultyStashes > 0 then
  Siku.print.warn(T('stashes_invalid_total', faultyStashes))
end

CreateThread(function()
  if not migrated then
    return
  end

  DiscardOrphanTemporaryStashes()
  LoadDeclaredStashes()
  LoadPersistedDrops()
  RestoreConnectedSessions()
  PublishStashPoints()
end)

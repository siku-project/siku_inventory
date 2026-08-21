local REQUIRED_CORE_VERSION <const> = '0.2.0'

local dependency <const> = Siku.CheckDependency('siku_core', REQUIRED_CORE_VERSION)

if not dependency.ok then
  Siku.print.throw(dependency.message)
end

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

--- Everything that needs the database waits in its own thread.
---
--- The migration blocks on purpose — this resource has no business serving
--- anything before its tables exist — and this file is the first server script
--- the resource loads: waiting here would suspend the load itself, so the
--- modules below would not exist yet and nothing above would have been
--- announced.
---
--- The connection is not waited on separately. The schema declares what it
--- depends on, and a dependency only completes once the database answered, so
--- waiting for it is already waiting for the database.
CreateThread(function()
  if not Siku.RunMigration(MigrationConfig) then
    return
  end

  DiscardOrphanTemporaryStashes()
  LoadDeclaredStashes()
  LoadPersistedDrops()
  RestoreConnectedSessions()
  PublishStashPoints()
end)

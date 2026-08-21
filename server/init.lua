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

local databaseReady = false

--- Nothing of this resource runs in here. A callback handed to another
--- resource is invoked by it, and a migration started from inside one is
--- credited to that resource rather than to this one — which is the name its
--- schema is then recorded under, and the name anything waiting on it waits
--- for. So this only raises the flag.
MySQL.ready(function()
  databaseReady = true
end)

--- Everything that needs the database waits in its own thread.
---
--- The migration blocks until the schemas it declared a dependency on are in
--- place, and this file is the first server script the resource loads: waiting
--- here would suspend the load itself, so the modules below would not exist
--- yet and nothing above would have been announced.
CreateThread(function()
  while not databaseReady do
    Wait(100)
  end

  if not Siku.RunMigration(MigrationConfig) then
    return
  end

  DiscardOrphanTemporaryStashes()
  LoadDeclaredStashes()
  LoadPersistedDrops()
  RestoreConnectedSessions()
  PublishStashPoints()
end)

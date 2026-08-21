MigrationConfig = {
  --- Whether this resource migrates its own schema on startup.
  enabled = true,

  --- Whether a schema whose version was already applied is still inspected
  --- for elements that went missing.
  detectMissing = true,

  --- Resources whose schema must be fully applied before this one runs.
  ---
  --- The inventory references characters, so the core schema has to exist
  --- first whatever the start order in server.cfg.
  dependencies = { 'siku_core' },

  schema = {
    --- Bump this whenever the tables below change.
    version = '1.4.0',

    tables = {
      --- One row per container. A character inventory, a stack dropped on
      --- the ground, a stash and, later, a trunk all live here: only
      --- owner_type changes. The hotbar is not a column: what a player put
      --- on a key is a stack like any other, stored in inventory_items under
      --- the identifier that names the key.
      {
        name = 'inventories',
        columns = {
          { name = 'id', type = 'INT', unsigned = true, autoIncrement = true, primaryKey = true },
          { name = 'owner_type', type = 'VARCHAR(20)', notNull = true },
          { name = 'owner_id', type = 'INT', unsigned = true, default = 'NULL' },

          --- Who a container belongs to when its owner is not a numeric row.
          --- A stash is named by the script that declared it and, when it is
          --- personal, by whoever it belongs to — neither of which is an
          --- identifier this resource hands out. Kept apart from owner_id
          --- rather than widening it: a character inventory is found by a
          --- number and always will be.
          { name = 'owner_key', type = 'VARCHAR(96)', default = 'NULL' },
          { name = 'slots', type = 'SMALLINT', unsigned = true, notNull = true, default = 40 },
          { name = 'max_weight', type = 'INT', unsigned = true, notNull = true, default = 35000 },
          { name = 'x', type = 'FLOAT', default = 'NULL' },
          { name = 'y', type = 'FLOAT', default = 'NULL' },
          { name = 'z', type = 'FLOAT', default = 'NULL' },
          { name = 'expires_at', type = 'BIGINT', unsigned = true, default = 'NULL' },
          { name = 'created_at', type = 'TIMESTAMP', default = 'CURRENT_TIMESTAMP' },
          {
            name = 'updated_at',
            type = 'TIMESTAMP',
            default = 'CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP',
          },
        },
        indexes = {
          { name = 'idx_inventories_owner', columns = { 'owner_type', 'owner_id' }, unique = true },
          { name = 'idx_inventories_owner_key', columns = { 'owner_type', 'owner_key' }, unique = true },
          { name = 'idx_inventories_expires_at', columns = { 'expires_at' } },
        },
      },

      --- One row per stack. A stack is a quantity of one item kind sitting in
      --- one slot, with the metadata belonging to that instance.
      {
        name = 'inventory_items',
        columns = {
          { name = 'id', type = 'INT', unsigned = true, autoIncrement = true, primaryKey = true },
          { name = 'inventory_id', type = 'INT', unsigned = true, notNull = true },
          --- A slot is named, not counted: the grid uses numbers and the
          --- hotbar uses `H1` to `H5`, so a key can never collide with a grid
          --- slot however many of those an inventory is given.
          { name = 'slot', type = 'VARCHAR(8)', notNull = true },
          { name = 'item', type = 'VARCHAR(64)', notNull = true },
          { name = 'count', type = 'INT', unsigned = true, notNull = true, default = 1 },
          { name = 'metadata', type = 'TEXT', default = 'NULL' },
          { name = 'uid', type = 'VARCHAR(40)', default = 'NULL' },

          --- When a perishable instance goes off, in epoch milliseconds.
          --- Kept on the row rather than inside metadata so that freshness
          --- never takes part in the stacking signature: two loaves baked a
          --- minute apart still share a slot.
          { name = 'expires_at', type = 'BIGINT', unsigned = true, default = 'NULL' },

          --- Uses left on this instance, for the kinds that count them. Not
          --- a quantity: one lockpick with three uses left is one item.
          { name = 'uses', type = 'SMALLINT', unsigned = true, default = 'NULL' },
          { name = 'created_at', type = 'TIMESTAMP', default = 'CURRENT_TIMESTAMP' },
        },
        indexes = {
          { name = 'idx_inventory_items_slot', columns = { 'inventory_id', 'slot' }, unique = true },
          { name = 'idx_inventory_items_item', columns = { 'item' } },
          { name = 'idx_inventory_items_uid', columns = { 'uid' }, unique = true },
        },
        foreignKeys = {
          {
            column = 'inventory_id',
            references = { table = 'inventories', column = 'id' },
            onDelete = 'CASCADE',
            onUpdate = 'CASCADE',
          },
        },
      },
    },
  },
}

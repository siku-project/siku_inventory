--- Expands every declared round into the item catalogue.
---@return nil
local function expandAmmo()
  for item, round in pairs(Ammo) do
    Items[item] = Siku.table.merge({}, round)
  end
end

expandAmmo()

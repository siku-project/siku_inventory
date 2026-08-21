local MELEE_LIGHT <const> = 140
local MELEE_HEAVY <const> = 141
local MELEE_ALTERNATE <const> = 142
local MELEE_ATTACK_ONE <const> = 263
local MELEE_ATTACK_TWO <const> = 264

local BASH_CONTROLS <const> = {
  MELEE_LIGHT,
  MELEE_HEAVY,
  MELEE_ALTERNATE,
  MELEE_ATTACK_ONE,
  MELEE_ATTACK_TWO,
}

if not InventoryConfig.disableWeaponBash then
  return
end

--- Blocks the melee swing a firearm can be used for, and nothing else.
---
--- The controls stay registered and are lifted rather than removed, because
--- what is being refused depends on what is in hand: empty hands still throw a
--- punch, and a blade is held precisely to be swung. Only a firearm used as a
--- club is refused.
---@param blocked boolean Whether the swing is being refused right now.
---@return nil
local function refuseBash(blocked)
  if blocked then
    return Siku.UnsuppressDisabledControl(table.unpack(BASH_CONTROLS))
  end

  Siku.SuppressDisabledControl(table.unpack(BASH_CONTROLS))
end

Siku.AddDisabledControl(table.unpack(BASH_CONTROLS))

--- Hands start empty, so the punch is left alone until a firearm says otherwise.
refuseBash(false)

AddEventHandler('siku_inventory:client:currentWeapon', function(weapon)
  refuseBash(type(weapon) == 'table' and weapon.melee ~= true)
end)

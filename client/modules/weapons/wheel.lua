local WEAPON_WHEEL_UD <const> = 12
local WEAPON_WHEEL_LR <const> = 13
local WEAPON_WHEEL_NEXT <const> = 14
local WEAPON_WHEEL_PREV <const> = 15
local SELECT_WEAPON <const> = 37
local SELECT_UNARMED <const> = 157
local SELECT_MELEE <const> = 158
local SELECT_HANDGUN <const> = 159
local SELECT_SHOTGUN <const> = 160
local SELECT_SMG <const> = 161
local SELECT_AUTORIFLE <const> = 162
local SELECT_SNIPER <const> = 163
local SELECT_HEAVY <const> = 164
local SELECT_SPECIAL <const> = 165

local WHEEL_CONTROLS <const> = {
  WEAPON_WHEEL_UD,
  WEAPON_WHEEL_LR,
  WEAPON_WHEEL_NEXT,
  WEAPON_WHEEL_PREV,
  SELECT_WEAPON,
  SELECT_UNARMED,
  SELECT_MELEE,
  SELECT_HANDGUN,
  SELECT_SHOTGUN,
  SELECT_SMG,
  SELECT_AUTORIFLE,
  SELECT_SNIPER,
  SELECT_HEAVY,
  SELECT_SPECIAL,
}

if not InventoryConfig.disableWeaponWheel then
  return
end

Siku.AddDisabledControl(table.unpack(WHEEL_CONTROLS))

CreateThread(function()
  while true do
    BlockWeaponWheelThisFrame()
    HudWeaponWheelIgnoreSelection()

    Wait(0)
  end
end)

SetWeaponsNoAutoswap(true)

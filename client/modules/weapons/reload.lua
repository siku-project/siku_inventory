local ATTACK <const> = 24
local AIM <const> = 25
local ATTACK_SECONDARY <const> = 257
local MELEE_ATTACK_LIGHT <const> = 263
local MELEE_ATTACK_HEAVY <const> = 264

local FIRING_CONTROLS <const> = {
  ATTACK,
  AIM,
  ATTACK_SECONDARY,
  MELEE_ATTACK_LIGHT,
  MELEE_ATTACK_HEAVY,
}

local loading = false

--- Asks the server to fill an instance.
---@param uid string The weapon instance.
---@param magazine number The capacity the game reports for it.
---@return nil
local function requestLoad(uid, magazine)
  TriggerServerEvent('siku_inventory:server:reload', { uid = uid, magazine = magazine })
end

--- Loads whatever is in the character's hands.
---@return nil
function ReloadDrawnWeapon()
  local drawn <const> = GetDrawnWeapon()

  if loading or not drawn or not drawn.takesAmmo then
    return
  end

  requestLoad(drawn.uid, MagazineOf(drawn.name, drawn.components))
end

--- Plays out the moment a load takes, then hands the rounds to the ped.
---
--- Nothing here decides anything: the rounds already left the bag. What this
--- controls is when the character can fire again.
---@param uid string The instance that was loaded.
---@param ammo number The rounds it now holds.
---@return nil
local function playLoad(uid, ammo)
  local settings <const> = InventoryConfig.reload

  if not settings or settings.timed ~= true then
    return ApplyLoadedAmmo(uid, ammo)
  end

  loading = true

  Siku.AddDisabledControl(table.unpack(FIRING_CONTROLS))

  Siku.ProgressBar({
    label = T('reload_progress'),
    icon = 'mdi-reload',
    duration = settings.duration or 2200,
  }, function()
    loading = false

    Siku.RemoveDisabledControl(table.unpack(FIRING_CONTROLS))
    ApplyLoadedAmmo(uid, ammo)
  end)
end

RegisterNetEvent('siku_inventory:client:weaponLoaded', function(payload)
  if type(payload) == 'table' then
    playLoad(payload.uid, payload.ammo)
  end
end)

RegisterNetEvent('siku_inventory:client:openReload', function(payload)
  if type(payload) ~= 'table' or type(payload.weapons) ~= 'table' then
    return
  end

  local weapons <const> = {}

  for i = 1, #payload.weapons do
    local weapon <const> = payload.weapons[i]
    local magazine <const> = MagazineOf(weapon.name, weapon.components)

    weapons[i] = {
      uid = weapon.uid,
      item = weapon.item,
      ammo = weapon.ammo,
      magazine = magazine,
      room = math.max(0, magazine - weapon.ammo),
    }
  end

  SendNUIMessage({
    action = 'siku_inventory:nui:setReload',
    reload = {
      ammoItem = payload.ammoItem,
      carried = payload.carried,
      weapons = weapons,
    },
  })
end)

RegisterNUICallback('siku_inventory:nui:reload', function(data, cb)
  cb({})

  if type(data) == 'table' and type(data.uid) == 'string' then
    requestLoad(data.uid, data.magazine)
  end
end)

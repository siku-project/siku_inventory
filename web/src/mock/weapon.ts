import { MOCK_CATALOGUE } from '@/mock/catalogue'
import { resolveVariant } from '@/mock/components'
import type { AvailableComponent, WeaponSlot } from '@/types/weapon'

/**
 * Stands in for the customization session while `bun run dev` is running.
 * Everything above this file — the slot rows, the selection, the commit — is
 * the same code the game drives.
 */

export const MOCK_SLOTS: WeaponSlot[] = [
  { id: 'sight', label: 'weapon.slot.sight' },
  { id: 'muzzle', label: 'weapon.slot.muzzle' },
  { id: 'flashlight', label: 'weapon.slot.flashlight' },
  { id: 'magazine', label: 'weapon.slot.magazine' },
  { id: 'grip', label: 'weapon.slot.grip' },
  { id: 'barrel', label: 'weapon.slot.barrel' },
  { id: 'skin', label: 'weapon.slot.skin' },
]

/**
 * The carried components this weapon actually takes. Filtering happens here
 * because it happens on the client in game too: the engine is asked, and a
 * part it refuses never reaches the panel.
 */
export const mockAvailable = (weaponName: string, owned: string[]): AvailableComponent[] =>
  owned
    .filter((item) => resolveVariant(weaponName, item) !== null)
    .map((item) => ({
      item,
      componentSlot: MOCK_CATALOGUE[item]?.slot ?? 'muzzle',
    }))

export interface MockWeaponScenario {
  item: string
  uid: string
  serial: string
  ammo: number
  components: Record<string, string>
  owned: string[]
}

/**
 * The states worth looking at: a bare weapon with parts to hand, one already
 * fitted, one carrying nothing, and one carrying only parts this weapon does
 * not take — the last two must both read as "nothing to fit" rather than as
 * an empty box.
 */
export const MOCK_WEAPON_SCENARIOS: Record<string, MockWeaponScenario> = {
  bare: {
    item: 'pistol',
    uid: 'mock-pistol-1',
    serial: 'SK-4471-B',
    ammo: 34,
    components: {},
    owned: ['at_suppressor_light', 'at_flashlight', 'at_clip_extended_pistol', 'at_skin_luxe'],
  },

  fitted: {
    item: 'pistol',
    uid: 'mock-pistol-1',
    serial: 'SK-4471-B',
    ammo: 34,
    components: { muzzle: 'at_suppressor_light' },
    owned: ['at_suppressor_light', 'at_flashlight', 'at_clip_extended_pistol'],
  },

  /** Carries nothing at all. */
  empty: {
    item: 'pistol',
    uid: 'mock-pistol-1',
    serial: 'SK-4471-B',
    ammo: 34,
    components: {},
    owned: [],
  },

  /** Carries parts, but none this pistol takes: the panel must say so. */
  incompatible: {
    item: 'pistol',
    uid: 'mock-pistol-1',
    serial: 'SK-4471-B',
    ammo: 34,
    components: {},
    owned: ['at_grip', 'at_scope_medium', 'at_barrel'],
  },

  rifle: {
    item: 'carbinerifle',
    uid: 'mock-carbine-1',
    serial: 'SK-8820-C',
    ammo: 120,
    components: { sight: 'at_scope_medium' },
    owned: [
      'at_grip',
      'at_flashlight',
      'at_scope_medium',
      'at_barrel',
      'at_clip_extended_rifle',
      'at_suppressor_light',
    ],
  },
}

export type MockWeaponScenarioName = keyof typeof MOCK_WEAPON_SCENARIOS

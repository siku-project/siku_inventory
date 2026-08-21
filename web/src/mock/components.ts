import type { ItemDefinition } from '@/types/inventory'

/**
 * A representative slice of shared/components.lua — one component per slot,
 * plus a second muzzle so replacement has something to replace with. The real
 * catalogue is pushed by the server and holds all seventy; the browser only
 * needs enough to exercise every path.
 *
 * Entries are written out in full, exactly as the Lua file writes them, so the
 * mock and the source of truth cannot drift into different shapes.
 */
const MOCK_COMPONENTS: ItemDefinition[] = [
  {
    id: 'at_flashlight',
    name: 'at_flashlight',
    label: 'Tactical Flashlight',
    description: 'Une lampe montée sur rail. Elle éclaire la cible et signale le tireur.',
    type: 'component',
    weight: 120,
    image: 'at_flashlight.png',
    stackable: false,
    unique: true,
    usable: false,
    closeOnUse: false,
    decays: false,
    metadataFields: [{ key: 'serial', label: 'item.meta.serial', format: 'text' }],
    slot: 'flashlight',
  },
  {
    id: 'at_suppressor_light',
    name: 'at_suppressor_light',
    label: 'Suppressor',
    description: 'Un silencieux de pistolet. Il étouffe la détonation sans la faire disparaître.',
    type: 'component',
    weight: 280,
    image: 'at_suppressor.png',
    stackable: false,
    unique: true,
    usable: false,
    closeOnUse: false,
    decays: false,
    metadataFields: [{ key: 'serial', label: 'item.meta.serial', format: 'text' }],
    slot: 'muzzle',
  },
  {
    id: 'at_suppressor_heavy',
    name: 'at_suppressor_heavy',
    label: 'Tactical Suppressor',
    description: 'Un silencieux de fusil, long et brûlant après quelques rafales.',
    type: 'component',
    weight: 280,
    image: 'at_suppressor.png',
    stackable: false,
    unique: true,
    usable: false,
    closeOnUse: false,
    decays: false,
    metadataFields: [{ key: 'serial', label: 'item.meta.serial', format: 'text' }],
    slot: 'muzzle',
  },
  {
    id: 'at_grip',
    name: 'at_grip',
    label: 'Grip',
    description: 'Une poignée avant. Elle tient la rafale plus bas.',
    type: 'component',
    weight: 280,
    image: 'at_grip.png',
    stackable: false,
    unique: true,
    usable: false,
    closeOnUse: false,
    decays: false,
    metadataFields: [{ key: 'serial', label: 'item.meta.serial', format: 'text' }],
    slot: 'grip',
  },
  {
    id: 'at_barrel',
    name: 'at_barrel',
    label: 'Heavy Barrel',
    description: 'Un canon lourd. Plus de précision, plus de poids à porter.',
    type: 'component',
    weight: 280,
    image: 'at_barrel.png',
    stackable: false,
    unique: true,
    usable: false,
    closeOnUse: false,
    decays: false,
    metadataFields: [{ key: 'serial', label: 'item.meta.serial', format: 'text' }],
    slot: 'barrel',
  },
  {
    id: 'at_clip_extended_pistol',
    name: 'at_clip_extended_pistol',
    label: 'Extended Pistol Clip',
    description: 'Un chargeur de pistolet rallongé. Il dépasse de la crosse.',
    type: 'component',
    weight: 280,
    image: 'at_clip_extended.png',
    stackable: false,
    unique: true,
    usable: false,
    closeOnUse: false,
    decays: false,
    metadataFields: [{ key: 'serial', label: 'item.meta.serial', format: 'text' }],
    slot: 'magazine',
  },
  {
    id: 'at_clip_extended_rifle',
    name: 'at_clip_extended_rifle',
    label: 'Extended Rifle Clip',
    description: "Un chargeur de fusil d'assaut rallongé, incurvé.",
    type: 'component',
    weight: 280,
    image: 'at_clip_extended2.png',
    stackable: false,
    unique: true,
    usable: false,
    closeOnUse: false,
    decays: false,
    metadataFields: [{ key: 'serial', label: 'item.meta.serial', format: 'text' }],
    slot: 'magazine',
  },
  {
    id: 'at_scope_medium',
    name: 'at_scope_medium',
    label: 'Medium Scope',
    description: 'Une lunette moyenne. Elle couvre la plupart des distances utiles.',
    type: 'component',
    weight: 280,
    image: 'at_scope.png',
    stackable: false,
    unique: true,
    usable: false,
    closeOnUse: false,
    decays: false,
    metadataFields: [{ key: 'serial', label: 'item.meta.serial', format: 'text' }],
    slot: 'sight',
  },
  {
    id: 'at_scope_holo',
    name: 'at_scope_holo',
    label: 'Holographic Sight',
    description: 'Un viseur holographique. Point rouge, les deux yeux ouverts.',
    type: 'component',
    weight: 280,
    image: 'at_scope.png',
    stackable: false,
    unique: true,
    usable: false,
    closeOnUse: false,
    decays: false,
    metadataFields: [{ key: 'serial', label: 'item.meta.serial', format: 'text' }],
    slot: 'sight',
  },
  {
    id: 'at_skin_luxe',
    name: 'at_skin_luxe',
    label: 'Luxury Weapon Kit',
    description:
      "Une finition dorée gravée à la main. Elle ne rend pas l'arme meilleure, seulement plus chère.",
    type: 'component',
    weight: 50,
    image: 'at_skin.png',
    stackable: false,
    unique: true,
    usable: false,
    closeOnUse: false,
    decays: false,
    metadataFields: [{ key: 'serial', label: 'item.meta.serial', format: 'text' }],
    slot: 'skin',
  },
]

/** The game components each item stands for, as shared/components.lua lists them. */
const MOCK_COMPONENT_VARIANTS: Record<string, string[]> = {
  at_flashlight: [
    'COMPONENT_AT_AR_FLSH',
    'COMPONENT_AT_AR_FLSH_REH',
    'COMPONENT_AT_PI_FLSH',
    'COMPONENT_AT_PI_FLSH_02',
    'COMPONENT_AT_PI_FLSH_03',
  ],
  at_suppressor_light: [
    'COMPONENT_AT_PI_SUPP',
    'COMPONENT_AT_PI_SUPP_02',
    'COMPONENT_CERAMICPISTOL_SUPP',
    'COMPONENT_PISTOLXM3_SUPP',
  ],
  at_suppressor_heavy: [
    'COMPONENT_AT_AR_SUPP',
    'COMPONENT_AT_AR_SUPP_02',
    'COMPONENT_AT_SR_SUPP',
    'COMPONENT_AT_SR_SUPP_03',
  ],
  at_grip: ['COMPONENT_AT_AR_AFGRIP', 'COMPONENT_AT_AR_AFGRIP_02'],
  at_barrel: ['COMPONENT_AT_AR_BARREL_02', 'COMPONENT_AT_CR_BARREL_02'],
  at_clip_extended_pistol: ['COMPONENT_PISTOL_CLIP_02', 'COMPONENT_COMBATPISTOL_CLIP_02'],
  at_clip_extended_rifle: ['COMPONENT_CARBINERIFLE_CLIP_02', 'COMPONENT_ASSAULTRIFLE_CLIP_02'],
  at_scope_medium: ['COMPONENT_AT_SCOPE_MEDIUM', 'COMPONENT_AT_SCOPE_MEDIUM_MK2'],
  at_scope_holo: ['COMPONENT_AT_PI_RAIL', 'COMPONENT_AT_SIGHTS'],
  at_skin_luxe: ['COMPONENT_PISTOL_VARMOD_LUXE', 'COMPONENT_CARBINERIFLE_VARMOD_LUXE'],
}

/** Mirrors the expansion the shared module performs on the Lua side. */
export const MOCK_COMPONENT_ITEMS: Record<string, ItemDefinition> = Object.fromEntries(
  MOCK_COMPONENTS.map((component) => [component.id, component]),
)

/**
 * Stands in for the engine, which the browser does not have. These are the
 * game components each weapon genuinely accepts — the same answer
 * `DoesWeaponTakeWeaponComponent` gives in game.
 */
const ENGINE: Record<string, string[]> = {
  WEAPON_PISTOL: [
    'COMPONENT_AT_PI_FLSH',
    'COMPONENT_AT_PI_SUPP_02',
    'COMPONENT_PISTOL_CLIP_02',
    'COMPONENT_PISTOL_VARMOD_LUXE',
  ],
  WEAPON_CARBINERIFLE: [
    'COMPONENT_AT_AR_FLSH',
    'COMPONENT_AT_AR_SUPP_02',
    'COMPONENT_AT_AR_AFGRIP',
    'COMPONENT_AT_AR_BARREL_02',
    'COMPONENT_AT_SCOPE_MEDIUM',
    'COMPONENT_CARBINERIFLE_CLIP_02',
    'COMPONENT_CARBINERIFLE_VARMOD_LUXE',
  ],
}

/**
 * Which game component a weapon takes for an item, or null when none of the
 * declared variants fits. This is the whole compatibility rule: no table of
 * weapon-to-component pairs is maintained anywhere.
 *
 * @param weaponName The name the game knows the weapon by.
 * @param item The component identifier.
 */
export const resolveVariant = (weaponName: string, item: string): string | null => {
  const accepted = ENGINE[weaponName] ?? []

  return MOCK_COMPONENT_VARIANTS[item]?.find((variant) => accepted.includes(variant)) ?? null
}

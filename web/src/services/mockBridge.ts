import { MOCK_CATALOGUE } from '@/mock/catalogue'
import { MOCK_LIMITS, MockServer, type MockOutcome } from '@/mock/server'
import {
  MOCK_IDENTITY,
  MOCK_PLAYERS,
  MOCK_SCENARIOS,
  MOCK_STASHES,
  type MockScenario,
  type MockStashName,
} from '@/mock/state'
import { FR_MESSAGES } from '@/mock/locale'
import {
  MOCK_SLOTS,
  MOCK_WEAPON_SCENARIOS,
  mockAvailable,
  type MockWeaponScenarioName,
} from '@/mock/weapon'
import type { BridgeSink, InventoryBridge } from '@/services/bridge'
import type {
  GiveRequest,
  MoveRequest,
  NearbyPlayer,
  SplitRequest,
  UseRequest,
} from '@/types/inventory'

const LATENCY = 40

const wait = (): Promise<void> => new Promise((resolve) => setTimeout(resolve, LATENCY))

/**
 * Stands in for the client and the server while `bun run dev` is running. It
 * answers on the same interface as the real bridge and pushes state through
 * the same sink, so nothing above this file knows which one is active.
 */
export const createMockBridge = (sink: BridgeSink): InventoryBridge => {
  let scenario: MockScenario = 'filled'
  let server = buildServer(scenario)
  let players = [...MOCK_PLAYERS]

  function buildServer(next: MockScenario): MockServer {
    const seed = MOCK_SCENARIOS[next]()

    return new MockServer(seed.inventory, seed.ground)
  }

  const publish = (outcome: MockOutcome): void => {
    sink.setState(outcome.state)

    if (outcome.refusal) {
      sink.refuse(outcome.refusal)
    }
  }

  /** Stands in for the world moving under a player who is standing still. */
  const pushGround = (): void => {
    sink.setGround(server.snapshot().ground)
  }

  /** Stands in for walking up to a locker and being let into it. */
  const openStash = (name: MockStashName): void => {
    const seed = MOCK_STASHES[name]

    if (!seed) {
      return
    }

    server.openContainer(seed())
    sink.setPrompt(null)
    sink.setState(server.snapshot())
    sink.setOpen(true)
  }

  const closeStash = (): void => {
    server.closeContainer()
    sink.setState(server.snapshot())
  }

  /** Stands in for standing next to something that can be opened. */
  const showPrompt = (label: string, key = 'E'): void => {
    sink.setPrompt({ label, key })
  }

  const load = (next: MockScenario): void => {
    scenario = next
    server = buildServer(scenario)
    sink.setState(server.snapshot())
  }

  const setPlayers = (next: NearbyPlayer[]): void => {
    players = next
  }

  /**
   * What the engine would answer for the two weapons the mock ships, and what
   * an extended magazine raises it to — the game decides that in play, and the
   * numbers are stood in for here so the behaviour is visible in development.
   */
  const MAGAZINES: Record<string, number> = { pistol: 12, carbinerifle: 30 }
  const EXTENDED: Record<string, number> = {
    at_clip_extended_pistol: 16,
    at_clip_extended_rifle: 60,
  }

  /** Mirrors MagazineOf: the capacity of a model with its parts fitted. */
  const magazineOf = (item: string, components: Record<string, string>): number => {
    const base = MAGAZINES[item] ?? 0
    const clip = components.magazine

    return clip && EXTENDED[clip] ? EXTENDED[clip] : base
  }

  /**
   * The customization session, kept here rather than in the store so that the
   * interface talks to it through exactly the same bridge calls it uses
   * against the real client.
   */
  let weapon: MockWeaponScenarioName = 'bare'
  let fitted: Record<string, string> = {}
  let owned: string[] = []

  const pushCustomization = (): void => {
    const scenarioData = MOCK_WEAPON_SCENARIOS[weapon]

    if (!scenarioData) {
      return
    }

    const weaponName = MOCK_CATALOGUE[scenarioData.item]?.name ?? scenarioData.item

    sink.setCustomization({
      weapon: {
        uid: scenarioData.uid,
        item: scenarioData.item,
        name: weaponName,
        ammoType: MOCK_CATALOGUE[scenarioData.item]?.ammoType,
        metadata: { serial: scenarioData.serial, ammo: scenarioData.ammo },
        components: { ...fitted },
      },
      slots: MOCK_SLOTS,
      available: mockAvailable(weaponName, owned),
      components: { ...fitted },
    })
  }

  const openWeapon = (next: MockWeaponScenarioName): void => {
    const scenarioData = MOCK_WEAPON_SCENARIOS[next]

    if (!scenarioData) {
      return
    }

    weapon = next
    fitted = { ...scenarioData.components }
    owned = [...scenarioData.owned]

    pushCustomization()
  }

  /**
   * Stands in for using a box of rounds. The server says what is carried; how
   * much each weapon still takes is the engine's answer, faked here the way
   * the client reads it off GTA in game.
   */
  const openReload = (ammoItem: string): void => {
    sink.setReload({
      ammoItem,
      carried: server.countItem(ammoItem),
      weapons: server.weaponsTaking(ammoItem).map((entry) => {
        const magazine = magazineOf(entry.item, entry.components)

        return { ...entry, magazine, room: Math.max(0, magazine - entry.ammo) }
      }),
    })
  }

  window.sikuInventoryMock = {
    load,
    setPlayers,
    openWeapon,
    openReload,
    pushGround,
    openStash,
    closeStash,
    showPrompt,
  }

  return {
    async start() {
      sink.setLocale({ language: 'fr', translations: { web: FR_MESSAGES } })
      sink.setCatalogue(MOCK_CATALOGUE)
      sink.setConfig({
        slots: MOCK_LIMITS.SLOTS,
        maxWeight: MOCK_LIMITS.MAX_WEIGHT,
        hotbarSlots: MOCK_LIMITS.HOTBAR_SLOTS,
      })
      sink.setIdentity(MOCK_IDENTITY)
      sink.setState(server.snapshot())
      sink.setOpen(true)
    },

    async move(request: MoveRequest) {
      await wait()
      publish(server.move(request))
    },

    async use(request: UseRequest) {
      await wait()

      const used = server.snapshot().inventory?.stacks[String(request.slot)]

      publish(server.use(request.slot))

      if (used && used.item.startsWith('ammo-')) {
        openReload(used.item)
      }
    },

    async split(request: SplitRequest) {
      await wait()
      publish(server.split(request))
    },

    async give(request: GiveRequest) {
      await wait()
      publish(server.give(request, players))
    },

    async nearbyPlayers() {
      await wait()

      return players
    },

    async close() {
      server.closeContainer()
      sink.setState(server.snapshot())
      sink.setOpen(false)
    },

    async openCustomization(uid: string) {
      await wait()

      const match = (Object.keys(MOCK_WEAPON_SCENARIOS) as MockWeaponScenarioName[]).find(
        (name) => MOCK_WEAPON_SCENARIOS[name]?.uid === uid,
      )

      if (!match) {
        sink.refuse('unknown_weapon')

        return
      }

      openWeapon(match)
    },

    async fitComponent(slot: string, item: string) {
      if (MOCK_CATALOGUE[item]?.slot !== slot) {
        return
      }

      fitted[slot] = item
      pushCustomization()
    },

    async clearComponent(slot: string) {
      delete fitted[slot]
      pushCustomization()
    },

    async reload(uid: string, magazine: number) {
      await wait()
      publish(server.reload(uid, magazine))
    },

    async closeCustomization() {
      sink.setCustomization(null)
      sink.setState(server.snapshot())
    },
  }
}

declare global {
  interface Window {
    sikuInventoryMock?: {
      load(scenario: MockScenario): void
      setPlayers(players: NearbyPlayer[]): void
      openWeapon(scenario: MockWeaponScenarioName): void
      openReload(ammoItem: string): void
      pushGround(): void
      openStash(name: MockStashName): void
      closeStash(): void
      showPrompt(label: string, key?: string): void
    }
  }
}

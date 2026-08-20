import axios from 'axios'
import type { AxiosInstance, AxiosResponse } from 'axios'

const resourceName: string =
  (
    (window as unknown as Record<string, unknown>).GetParentResourceName as
      (() => string) | undefined
  )?.() ?? 'siku_inventory'

const nui: AxiosInstance = axios.create({
  baseURL: `https://${resourceName}`,
  timeout: 5000,
  headers: {
    'Content-Type': 'application/json',
  },
})

nui.interceptors.response.use(
  (response: AxiosResponse) => response,
  (error) => {
    if (import.meta.env.DEV) {
      console.warn(`[NUI] Request failed:`, error.config?.url, error.message)
    }
    return Promise.reject(error)
  },
)

export async function sendNuiCallback<T = unknown, R = unknown>(
  eventName: string,
  data?: T,
): Promise<R | null> {
  try {
    const response = await nui.post<R>(eventName, data ?? {})
    return response.data
  } catch {
    return null
  }
}

export async function sendNuiEvent<T = unknown>(eventName: string, data?: T): Promise<boolean> {
  try {
    await nui.post(eventName, data ?? {})
    return true
  } catch {
    return false
  }
}

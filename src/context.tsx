import { ContextType, createContext } from 'react'

export const GaleriaContext = createContext({
  initialIndex: 0,
  open: false,
  urls: [] as unknown as [string, ...string[]],
  /**
   * @deprecated
   */
  ids: undefined as string[] | undefined,
  setOpen: (
    info:
      | { open: true; src: string; initialIndex: number; id?: string }
      | { open: false },
  ) => {},
  theme: 'dark' as 'dark' | 'light',
  src: '',
})

export type GaleriaContext = ContextType<typeof GaleriaContext>

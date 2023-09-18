import { createContext } from 'react'

export const GaleriaContext = createContext({
  initialIndex: 0,
  open: false,
  urls: [] as string[],
  ids: undefined as string[] | undefined,
  setOpen: (
    info:
      | { open: true; src: string; initialIndex: number; id?: string }
      | { open: false },
  ) => {},
  theme: 'light' as 'dark' | 'light',
  src: '',
})

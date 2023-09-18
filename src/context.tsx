import { createContext } from 'react'

export const GaleriaContext = createContext({
  initialIndex: 0,
  open: false,
  urls: [] as string[],
  setOpen: (
    info: { open: true; src: string; initialIndex: number } | { open: false },
  ) => {},
  theme: 'light' as 'dark' | 'light',
  src: '',
})

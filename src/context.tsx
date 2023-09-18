import { createContext } from 'react'

export const GaleriaContext = createContext({
  initialIndex: 0,
  open: false,
  urls: [] as string[],
})

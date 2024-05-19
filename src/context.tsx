import { ContextType, createContext } from 'react'
import type { Image } from 'react-native'

type ImageSource = string | Parameters<typeof Image.resolveAssetSource>[0]

export const GaleriaContext = createContext({
  open: false,
  urls: [] as unknown as undefined | ImageSource[],
  setOpen: (
    info:
      | { open: true; src: string; initialIndex: number; id?: string }
      | { open: false },
  ) => {},
  theme: 'dark' as 'dark' | 'light',
})

export type GaleriaContext = ContextType<typeof GaleriaContext>

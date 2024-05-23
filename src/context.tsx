import { ContextType, createContext } from 'react'
import type { Image } from 'react-native'

type ImageSource = string | Parameters<typeof Image.resolveAssetSource>[0]

export const GaleriaContext = createContext({
  initialIndex: 0,
  open: false,
  urls: [] as unknown as undefined | ImageSource[],
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

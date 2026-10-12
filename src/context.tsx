import { ContextType, createContext } from 'react'
import type { SFSymbol } from 'sf-symbols-typescript'

import type { MediaSource } from './Galeria.types'

export const GaleriaContext = createContext({
  initialIndex: 0,
  open: false,
  urls: [] as unknown as undefined | MediaSource[],
  closeIconName: undefined as undefined | SFSymbol,
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
  autoPlayVideo: false,
  hideBlurOverlay: false,
  hidePageIndicators: false,
})

export type GaleriaContext = ContextType<typeof GaleriaContext>

import { ContextType, createContext } from 'react'
import type { Image } from 'react-native'
import type { SFSymbol } from 'sf-symbols-typescript'

type ImageSource = string | Parameters<typeof Image.resolveAssetSource>[0]

export const GaleriaContext = createContext({
  initialIndex: 0,
  open: false,
  urls: [] as unknown as undefined | ImageSource[],
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
  hideBlurOverlay: false,
  hidePageIndicators: false,
  /**
   * Per-item media types. Must be same length as `urls`.
   * Accepted values: "image" | "video". Defaults to "image" when omitted.
   */
  mediaTypes: undefined as string[] | undefined,
})

export type GaleriaContext = ContextType<typeof GaleriaContext>

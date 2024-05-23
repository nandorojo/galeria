import { createContext, useContext } from 'react'
import type * as types from './types'

import { requireNativeViewManager } from 'expo-modules-core'
import { Image } from 'react-native'

const NativeView = requireNativeViewManager('Galeria')

const Context = createContext({
  urls: [],
})

export function Galeria({ urls, children }: types.GaleriaProps) {
  return <Context.Provider value={{ urls }}>{children}</Context.Provider>
}

Galeria.Image = function GaleriaImage({
  children,
  index = 0,
}: types.GaleriaImageProps) {
  const { urls } = useContext(Context)

  return (
    <NativeView
      index={index}
      urls={urls.map((url) => {
        if (typeof url === 'string') {
          return url
        }

        return Image.resolveAssetSource(url).uri
      })}
    >
      {children}
    </NativeView>
  )
}

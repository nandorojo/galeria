import { requireNativeViewManager } from 'expo-modules-core'
import * as React from 'react'

import { GaleriaViewProps } from './Galeria.types'

const NativeView: React.ComponentType<GaleriaViewProps> =
  requireNativeViewManager('Galeria')

const Galeria = Object.assign(
  function Galeria({
    children,
  }: {
    children: React.ReactNode
    theme?: 'dark' | 'light'
    urls?: string[]
    ids?: string[]
  }) {
    return <>{children}</>
  },
  {
    Image: NativeView,
    Popup: React.Fragment as React.FC<{
      disableTransition?: 'web'
    }>,
  },
)

export default Galeria

import { requireNativeViewManager } from 'expo-modules-core'

import { GaleriaViewProps } from './Galeria.types'
import { Fragment, useContext } from 'react'
import { GaleriaContext } from './context'

const NativeImage = requireNativeViewManager<
  GaleriaViewProps & {
    urls?: string[]
    theme: 'dark' | 'light'
  }
>('Galeria')

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
    Image(props: GaleriaViewProps) {
      const { theme = 'dark', urls } = useContext(GaleriaContext)
      return <NativeImage theme={theme} urls={urls} {...props} />
    },
    Popup: (() => null) as React.FC<{
      disableTransition?: 'web'
    }>,
  },
)

export default Galeria

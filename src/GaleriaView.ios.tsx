import { requireNativeViewManager } from 'expo-modules-core'

import { GaleriaViewProps } from './Galeria.types'
import { useContext } from 'react'
import { GaleriaContext } from './context'

const NativeImage = requireNativeViewManager<
  GaleriaViewProps & {
    urls?: string[]
    theme: 'dark' | 'light'
  }
>('Galeria')

const array = []
const noop = () => {}

const Galeria = Object.assign(
  function Galeria({
    children,
    urls = array,
    theme = 'dark',
  }: {
    children: React.ReactNode
    theme?: 'dark' | 'light'
    urls?: string[]
    ids?: string[]
  }) {
    return (
      <GaleriaContext.Provider
        value={{
          urls,
          theme,
          initialIndex: 0,
          open: false,
          src: '',
          setOpen: noop,
          ids: undefined,
        }}
      >
        {children}
      </GaleriaContext.Provider>
    )
  },
  {
    Image(props: GaleriaViewProps) {
      const { theme, urls } = useContext(GaleriaContext)
      return <NativeImage theme={theme} urls={urls} {...props} />
    },
    Popup: (() => null) as React.FC<{
      disableTransition?: 'web'
    }>,
  },
)

export default Galeria

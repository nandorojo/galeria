import { requireNativeViewManager } from 'expo-modules-core'

import { GaleriaViewProps } from './Galeria.types'
import { useContext } from 'react'
import { GaleriaContext } from './context'
import { Image, View } from 'react-native'

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
    urls,
    theme = 'dark',
    ids,
  }: {
    children: React.ReactNode
  } & Partial<Pick<GaleriaContext, 'theme' | 'ids' | 'urls'>>) {
    return (
      <GaleriaContext.Provider
        value={{
          urls,
          theme,
          initialIndex: 0,
          open: false,
          src: '',
          setOpen: noop,
          ids,
        }}
      >
        {children}
      </GaleriaContext.Provider>
    )
  },
  {
    Image({ children, ...props }: GaleriaViewProps) {
      const { theme, urls } = useContext(GaleriaContext)
      return (
        <NativeImage
          theme={theme}
          urls={urls?.map((url) => {
            if (typeof url === 'string') {
              return url
            }

            return Image.resolveAssetSource(url).uri
          })}
          {...props}
        >
          <>
            {/* <View
              nativeID="backView"
              style={{ backgroundColor: 'red', width: 60, height: 60 }}
            /> */}
            {children}
          </>
        </NativeImage>
      )
    },
    Popup: (() => null) as React.FC<{
      disableTransition?: 'web'
    }>,
  },
)

export default Galeria

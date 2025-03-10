import { requireNativeView } from 'expo'

import { GaleriaViewProps } from './Galeria.types'
import { useContext } from 'react'
import { GaleriaContext } from './context'
import { Image } from 'react-native'
import { SFSymbol } from 'sf-symbols-typescript'

const NativeImage = requireNativeView<
  GaleriaViewProps & {
    urls?: string[]
    closeIconName?: SFSymbol
    theme: 'dark' | 'light'
  }
>('Galeria')

const array = []
const noop = () => { }

const Galeria = Object.assign(
  function Galeria({
    children,
    closeIconName,
    urls,
    theme = 'dark',
    ids,
  }: {
    children: React.ReactNode
  } & Partial<Pick<GaleriaContext, 'theme' | 'ids' | 'urls' | 'closeIconName'>>) {
    return (
      <GaleriaContext.Provider
        value={{
          closeIconName,
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
    Image(props: GaleriaViewProps) {
      const { theme, urls, initialIndex, closeIconName } = useContext(GaleriaContext)
      return (
        <NativeImage
          closeIconName={closeIconName}
          theme={theme}
          urls={urls?.map((url) => {
            if (typeof url === 'string') {
              return url
            }

            return Image.resolveAssetSource(url).uri
          })}
          index={initialIndex}
          {...props}
        />
      )
    },
    Popup: (() => null) as React.FC<{
      disableTransition?: 'web'
    }>,
  },
)

export default Galeria

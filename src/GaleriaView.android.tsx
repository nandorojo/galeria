import { requireNativeView } from 'expo'

import { useContext } from 'react'
import { Image } from 'react-native'
import {
  controlEdgeToEdgeValues,
  isEdgeToEdge,
} from 'react-native-is-edge-to-edge'
import { GaleriaContext } from './context'
import { GaleriaIndexChangedEvent, GaleriaViewProps } from './Galeria.types'

const EDGE_TO_EDGE = isEdgeToEdge()

const NativeImage = requireNativeView<
  GaleriaViewProps & {
    edgeToEdge: boolean
    urls?: string[]
    theme: 'dark' | 'light'
    onIndexChange?: (event: GaleriaIndexChangedEvent) => void
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
          closeIconName: undefined,
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
    Image({ edgeToEdge, ...props }: GaleriaViewProps) {
      const { theme, urls } = useContext(GaleriaContext)

      if (__DEV__) {
        // warn the user once about unnecessary defined prop
        controlEdgeToEdgeValues({ edgeToEdge })
      }

      return (
        <NativeImage
          onIndexChange={props.onIndexChange}
          edgeToEdge={EDGE_TO_EDGE || (edgeToEdge ?? false)}
          theme={theme}
          urls={urls?.map((url) => {
            if (typeof url === 'string') {
              return url
            }

            return Image.resolveAssetSource(url).uri
          })}
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

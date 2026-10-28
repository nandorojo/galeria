import { requireNativeModule, requireNativeView } from 'expo'

import { useContext } from 'react'
import { Image, useWindowDimensions, type ViewStyle } from 'react-native'
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
    mediaTypes?: ('photo' | 'video')[]
    autoPlayVideo: boolean
    theme: 'dark' | 'light'
    onIndexChange?: (event: GaleriaIndexChangedEvent) => void
  }
>('Galeria', 'GaleriaView')

const NativeOverlay = requireNativeView<{
  urls?: string[]
  children?: React.ReactNode
  pointerEvents?: 'box-none'
  style?: ViewStyle
}>('Galeria', 'GaleriaOverlayView')

const GaleriaModule = requireNativeModule<{ dismiss(): Promise<void> }>(
  'Galeria',
)

const toUrls = (urls: GaleriaContext['urls']) =>
  urls?.map((item) => {
    const source =
      typeof item === 'object' && item !== null && 'source' in item
        ? item.source
        : item

    return typeof source === 'string'
      ? source
      : Image.resolveAssetSource(source).uri
  })

const noop = () => {}

const GaleriaRoot = Object.assign(
  function Galeria({
    children,
    urls,
    theme = 'dark',
    autoPlayVideo = false,
    ids,
  }: {
    children: React.ReactNode
  } & Partial<Pick<GaleriaContext, 'theme' | 'ids' | 'urls' | 'autoPlayVideo'>>) {
    return (
      <GaleriaContext.Provider
        value={{
          autoPlayVideo,
          hideBlurOverlay: false,
          hidePageIndicators: false,
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
      const { theme, urls, autoPlayVideo } = useContext(GaleriaContext)

      if (__DEV__) {
        // warn the user once about unnecessary defined prop
        controlEdgeToEdgeValues({ edgeToEdge })
      }

      return (
        <NativeImage
          onIndexChange={props.onIndexChange}
          edgeToEdge={EDGE_TO_EDGE || (edgeToEdge ?? false)}
          theme={theme}
          autoPlayVideo={autoPlayVideo}
          mediaTypes={urls?.map((source) =>
            typeof source === 'object' && source !== null && 'source' in source
              ? source.type
              : 'photo',
          )}
          urls={toUrls(urls)}
          {...props}
        />
      )
    },
    Popup: (() => null) as React.FC<{
      disableTransition?: 'web'
    }>,
    /**
     * React views shown over the viewer of this `Galeria`'s images while it's
     * open, covering it. They fade in and out with it, and with a single tap on
     * a photo. Touches on nothing of theirs go to the photos.
     */
    Overlay({
      children,
    }: {
      children?: React.ReactNode
    }): React.ReactElement | null {
      const { urls } = useContext(GaleriaContext)
      const { width, height } = useWindowDimensions()

      return (
        <NativeOverlay
          urls={toUrls(urls)}
          pointerEvents="box-none"
          style={{ position: 'absolute', top: 0, left: 0, width, height }}
        >
          {children}
        </NativeOverlay>
      )
    },
    /** Closes the open viewer, as its close button or back does. */
    dismiss: () => GaleriaModule.dismiss(),
  },
)

const Galeria = Object.assign(GaleriaRoot, { Item: GaleriaRoot.Image })

export default Galeria

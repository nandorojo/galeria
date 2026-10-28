import { requireNativeModule, requireNativeView } from 'expo'

import { useContext } from 'react'
import { Image, useWindowDimensions, type ViewStyle } from 'react-native'
import type { SFSymbol } from 'sf-symbols-typescript'
import { GaleriaContext } from './context'
import { GaleriaIndexChangedEvent, GaleriaViewProps } from './Galeria.types'

const NativeImage = requireNativeView<
  GaleriaViewProps & {
    urls?: string[]
    mediaTypes?: ('photo' | 'video')[]
    autoPlayVideo: boolean
    closeIconName?: SFSymbol
    theme: 'dark' | 'light'
    onIndexChange?: (event: GaleriaIndexChangedEvent) => void
    hideBlurOverlay?: boolean
    hidePageIndicators?: boolean
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
    closeIconName,
    urls,
    theme = 'dark',
    ids,
    autoPlayVideo = false,
    hideBlurOverlay = false,
    hidePageIndicators = false,
  }: {
    children: React.ReactNode
  } & Partial<
    Pick<
      GaleriaContext,
      | 'theme'
      | 'ids'
      | 'urls'
      | 'closeIconName'
      | 'hideBlurOverlay'
      | 'hidePageIndicators'
      | 'autoPlayVideo'
    >
  >) {
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
          autoPlayVideo,
          hideBlurOverlay,
          hidePageIndicators,
        }}
      >
        {children}
      </GaleriaContext.Provider>
    )
  },
  {
    Image(props: GaleriaViewProps) {
      const {
        theme,
        urls,
        initialIndex,
        closeIconName,
        hideBlurOverlay,
        hidePageIndicators,
        autoPlayVideo,
      } = useContext(GaleriaContext)
      return (
        <NativeImage
          onIndexChange={props.onIndexChange}
          closeIconName={closeIconName}
          theme={theme}
          autoPlayVideo={autoPlayVideo}
          mediaTypes={urls?.map((source) =>
            typeof source === 'object' && source !== null && 'source' in source
              ? source.type
              : 'photo',
          )}
          hideBlurOverlay={props.hideBlurOverlay ?? hideBlurOverlay}
          hidePageIndicators={props.hidePageIndicators ?? hidePageIndicators}
          urls={toUrls(urls)}
          index={initialIndex}
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

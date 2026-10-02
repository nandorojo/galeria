import { requireNativeView } from 'expo'

import { useContext } from 'react'
import { Image } from 'react-native'
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
>('Galeria')

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
            typeof source === 'object' && source !== null && 'url' in source
              ? source.type
              : 'photo',
          )}
          hideBlurOverlay={props.hideBlurOverlay ?? hideBlurOverlay}
          hidePageIndicators={props.hidePageIndicators ?? hidePageIndicators}
          urls={urls?.map((url) => {
            if (typeof url === 'string') {
              return url
            }

            if (typeof url === 'object' && url !== null && 'url' in url) {
              return url.url
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

const Galeria = Object.assign(GaleriaRoot, { Item: GaleriaRoot.Image })

export default Galeria

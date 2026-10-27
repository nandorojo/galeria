'use client'
import {
  useState,
  useId,
  ComponentProps,
  useRef,
  useEffect,
  useContext,
  useCallback,
  createContext,
  isValidElement,
  cloneElement,
} from 'react'
import { createPortal } from 'react-dom'

import {
  GaleriaIndexChangedEvent,
  GaleriaViewProps,
  MediaSource,
} from './Galeria.types'
import type Native from './GaleriaView.ios'

import {
  AnimatePresence,
  LayoutGroup,
  motion,
  useDomEvent,
  useIsPresent,
  type Variants,
} from 'framer-motion'
import { GaleriaContext } from './context'

function getMedia(item: MediaSource | undefined) {
  const isVideo =
    typeof item === 'object' &&
    item !== null &&
    'type' in item &&
    item.type === 'video'
  const source =
    typeof item === 'object' && item !== null && 'source' in item
      ? item.source
      : item
  const url =
    typeof source === 'object' && source !== null && 'uri' in source
      ? source.uri
      : source
  return { isVideo, url }
}

const getFirstImageChild = (node: Node): HTMLImageElement | null => {
  if (node instanceof HTMLImageElement) {
    return node
  }
  if (node.childNodes && node.childNodes.length > 0) {
    for (const child of Array.from(node.childNodes)) {
      const result = getFirstImageChild(child)
      if (result) return result
    }
  }
  return null
}

const getNodeAspectRatio = (node: Node) => {
  const imageNode = getFirstImageChild(node)
  if (imageNode) {
    return (
      imageNode.getBoundingClientRect().width /
      imageNode.getBoundingClientRect().height
    )
  }
  return 1
}

type ViewerItem = {
  index: number
  // -1 or 1 when the viewer moved to this item from the previous or next one, 0 when it opened on it
  direction: number
  // the aspect ratio and image of its thumbnail, if it's mounted: the item then grows from it, and shrinks back into it
  thumbnail?: { aspectRatio: number; poster?: string }
  // the latest onIndexChange of the Image it opened from
  onIndexChange: { current: GaleriaViewProps['onIndexChange'] }
}

const ViewerContext = createContext({
  register: (index: number, node: HTMLElement) => () => {},
  open: (index: number, onIndexChange: ViewerItem['onIndexChange']) => {},
  isOpen: false,
  lastIndex: undefined as number | undefined,
})

function Image({
  __web,
  index = 0,
  children,
  style,
  dynamicAspectRatio = false,
  onIndexChange,
}: GaleriaViewProps) {
  const { urls } = useContext(GaleriaContext)
  const viewer = useContext(ViewerContext)
  const { isVideo } = getMedia(urls?.[index])
  const ref = useRef<HTMLDivElement>(null)
  const onIndexChangeRef = useRef(onIndexChange)
  onIndexChangeRef.current = onIndexChange
  const { register } = viewer
  useEffect(() => register(index, ref.current!), [register, index])
  const onClick = (
    e: React.MouseEvent<HTMLDivElement> | React.TouchEvent<HTMLDivElement>,
  ) => {
    const imageNode = getFirstImageChild(e.currentTarget)
    if (imageNode) {
      viewer.open(index, onIndexChangeRef)
      const ratio = getNodeAspectRatio(imageNode)
      if (
        typeof process != 'undefined' &&
        typeof process.env != 'undefined' &&
        process?.env?.NODE_ENV === 'development' &&
        imageNode.parentElement
      ) {
        const nodeAspectRatio = getNodeAspectRatio(imageNode.parentElement)

        if (nodeAspectRatio !== ratio) {
          console.error(
            `[galeria] Galeria.Image does not have the same aspect ratio as its child.

This might result in a weird animation. To fix it, pass the "style" prop to Galeria.Image to give it the same height & width as the image.

Or, you might need something like alignItems: 'flex-start' to the parent element.`,
          )
        }
      }
    }
  }

  return (
    <motion.div
      ref={ref}
      style={
        {
          zIndex: index + (viewer.lastIndex === index ? 1000 : 0),
          ...style,
        } as object
      }
      // faster than onClick
      // onMouseDown={onClick}
      // onTouchStart={onClick}
      onClick={onClick}
      layoutId={String(index)}
      layout={isVideo ? 'preserve-aspect' : undefined}
      // while the viewer is open, a thumbnail whose item was left goes back in place at once, behind it
      transition={viewer.isOpen ? { duration: 0 } : undefined}
    >
      {isValidElement(children)
        ? cloneElement(children, { draggable: false } as object)
        : children}
    </motion.div>
  )
}

function Root({
  children,
  urls,
  theme = 'dark',
  autoPlayVideo = false,
  ids,
}: ComponentProps<typeof Native>) {
  const [openState, setOpen] = useState({
    open: false,
  } as
    | {
        open: false
      }
    | {
        open: true
        src: string
        initialIndex: number
      })
  const thumbnails = useRef(new Map<number, HTMLElement>())
  const [item, setItem] = useState<ViewerItem>()
  // the item shown last, which stays above the other thumbnails while it shrinks back into its own
  const [lastIndex, setLastIndex] = useState<number>()
  const count = urls?.length ?? 0
  // a swipe between items ends with a click, which mustn't close the viewer
  const wasDragged = useRef(false)
  const close = () => {
    if (!wasDragged.current) {
      setItem(undefined)
    }
  }

  const register = useCallback((index: number, node: HTMLElement) => {
    thumbnails.current.set(index, node)
    return () => {
      if (thumbnails.current.get(index) === node) {
        thumbnails.current.delete(index)
      }
    }
  }, [])

  const show = useCallback(
    (
      index: number,
      direction: number,
      onIndexChange: ViewerItem['onIndexChange'],
    ) => {
      const node = thumbnails.current.get(index)
      const imageNode = node && getFirstImageChild(node)
      setItem({
        index,
        direction,
        thumbnail: imageNode
          ? {
              aspectRatio: getNodeAspectRatio(imageNode),
              poster: imageNode.currentSrc || imageNode.src,
            }
          : undefined,
        onIndexChange,
      })
      setLastIndex(index)
      onIndexChange.current?.({
        nativeEvent: { currentIndex: index },
      } as GaleriaIndexChangedEvent)
    },
    [],
  )

  const open = useCallback(
    (index: number, onIndexChange: ViewerItem['onIndexChange']) =>
      show(index, 0, onIndexChange),
    [show],
  )

  const navigate = (step: number) => {
    if (!item) return
    const index = item.index + step
    if (index < 0 || index >= count) return
    show(index, step, item.onIndexChange)
  }

  return (
    <GaleriaContext.Provider
      value={{
        autoPlayVideo,
        hideBlurOverlay: false,
        hidePageIndicators: false,
        closeIconName: undefined,
        setOpen,
        urls,
        theme,
        ...(openState.open
          ? {
              open: true,
              src: openState.src,
              initialIndex: openState.initialIndex,
            }
          : {
              open: false,
              src: '',
              initialIndex: 0,
            }),
        ids,
      }}
    >
      <ViewerContext.Provider
        value={{ register, open, isOpen: !!item, lastIndex }}
      >
        <LayoutGroup inherit={false} id={useId()}>
          {children}

          <PopupModal
            visible={!!item}
            onPointerDown={() => {
              wasDragged.current = false
            }}
            onClose={close}
          >
            {item && (
              <Viewer
                item={item}
                urls={urls}
                theme={theme}
                autoPlayVideo={autoPlayVideo}
                onNavigate={navigate}
                onSwipe={() => {
                  wasDragged.current = true
                }}
                onClose={() => setItem(undefined)}
              />
            )}
          </PopupModal>
        </LayoutGroup>
      </ViewerContext.Provider>
    </GaleriaContext.Provider>
  )
}

const slide: Variants = {
  enter: (direction: number) => ({ x: `${direction * 100}%` }),
  center: { x: 0 },
  exit: (direction: number) => ({ x: `${-direction * 100}%` }),
}

function Viewer({
  item,
  urls,
  theme,
  autoPlayVideo,
  onNavigate,
  onSwipe,
  onClose,
}: {
  item: ViewerItem
  urls: MediaSource[] | undefined
  theme: 'dark' | 'light'
  autoPlayVideo: boolean
  onNavigate: (step: number) => void
  onSwipe: () => void
  onClose: () => void
}) {
  const { index, direction, thumbnail } = item
  const count = urls?.length ?? 0
  const { isVideo, url } = getMedia(urls?.[index])
  const background = {
    light: '#ffffff',
    dark: '#000000',
  }[theme]
  const foreground = {
    light: '#000000',
    dark: '#ffffff',
  }[theme]
  // an item slid in takes its thumbnail's place at once, rather than growing from it
  const layoutTransition = direction ? { layout: { duration: 0 } } : undefined
  const handlers = useRef({ onNavigate, onClose })
  handlers.current = { onNavigate, onClose }

  useEffect(() => {
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') return handlers.current.onClose()
      // a video's controls seek with the arrows
      if (event.defaultPrevented || isKeyboardTarget(event.target)) return
      const step = { ArrowLeft: -1, ArrowRight: 1 }[event.key]
      if (step) {
        // rather than scrolling what's behind
        event.preventDefault()
        handlers.current.onNavigate(step)
      }
    }
    // a trackpad's horizontal swipe goes along the items, one per swipe: its events (momentum included) until
    // they pause
    let swipe = 0
    let hasNavigated = false
    let swipeEnd: ReturnType<typeof setTimeout> | undefined
    const onWheel = (event: WheelEvent) => {
      if (Math.abs(event.deltaX) <= Math.abs(event.deltaY)) return
      // rather than the browser's back and forward gestures
      event.preventDefault()
      clearTimeout(swipeEnd)
      swipeEnd = setTimeout(() => {
        swipe = 0
        hasNavigated = false
      }, 200)
      if (hasNavigated) return
      swipe += event.deltaX
      if (Math.abs(swipe) > 50) {
        hasNavigated = true
        handlers.current.onNavigate(swipe > 0 ? 1 : -1)
      }
    }
    window.addEventListener('keydown', onKeyDown)
    window.addEventListener('wheel', onWheel, { passive: false })
    return () => {
      window.removeEventListener('keydown', onKeyDown)
      window.removeEventListener('wheel', onWheel)
      clearTimeout(swipeEnd)
    }
  }, [])

  return (
    <>
      <motion.div
        style={{ position: 'absolute', inset: 0 }}
        initial={{ backgroundColor: background + '00' }}
        animate={{ backgroundColor: background }}
        exit={{ backgroundColor: background + '00' }}
      />

      <WindowDimensions>
        {(dimensions) => {
          // given the image aspect ratio, and the window dimensions, we want to derive the proper height and width
          // such that it spans the size of the window with a "contain" effect, but implemented in code rather than using object-fit

          // Calculate dimensions for "contain" effect
          const windowRatio = dimensions.width / dimensions.height
          const imageRatio = thumbnail?.aspectRatio ?? windowRatio

          // If image is wider than window (relative to their heights)
          const width =
            imageRatio > windowRatio
              ? dimensions.width
              : dimensions.height * imageRatio
          const height =
            imageRatio > windowRatio
              ? dimensions.width / imageRatio
              : dimensions.height

          return (
            <AnimatePresence initial={false} custom={direction}>
              <motion.div
                key={index}
                custom={direction}
                variants={slide}
                initial="enter"
                animate="center"
                exit="exit"
                transition={{ x: { type: 'spring', bounce: 0, duration: 0.4 } }}
                style={{
                  position: 'absolute',
                  inset: 0,
                  display: 'flex',
                  justifyContent: 'center',
                  alignItems: 'center',
                }}
                // not a video, whose controls are dragged
                drag={count > 1 && !isVideo ? 'x' : false}
                dragConstraints={{ left: 0, right: 0 }}
                dragElastic={1}
                dragMomentum={false}
                onDrag={(_, { offset }) => {
                  // not a tap that moved a little
                  if (Math.abs(offset.x) > 10) onSwipe()
                }}
                onDragEnd={(_, { offset, velocity }) => {
                  const swipe = offset.x + velocity.x * 0.2
                  if (Math.abs(swipe) > dimensions.width / 4) {
                    onNavigate(swipe < 0 ? 1 : -1)
                  }
                }}
              >
                {url && isVideo ? (
                  <ViewerVideo
                    layoutId={thumbnail ? String(index) : undefined}
                    layout="preserve-aspect"
                    transition={layoutTransition}
                    src={url as string}
                    poster={thumbnail?.poster}
                    controls
                    playsInline
                    autoPlay={autoPlayVideo}
                    preload="metadata"
                    onClick={(event) => event.stopPropagation()}
                    onWheel={(event) => event.stopPropagation()}
                    style={{
                      width: dimensions.width,
                      height: dimensions.height,
                      objectFit: 'contain',
                    }}
                  />
                ) : url ? (
                  <motion.img
                    layoutId={thumbnail ? String(index) : undefined}
                    transition={layoutTransition}
                    draggable={false}
                    style={{
                      width,
                      height,
                      // the thumbnail's crop, to grow from it and shrink back into it, else the whole image
                      objectFit: thumbnail ? 'cover' : 'contain',
                      zIndex: 2000,
                    }}
                    src={url as string}
                  ></motion.img>
                ) : null}
              </motion.div>
            </AnimatePresence>
          )
        }}
      </WindowDimensions>

      <motion.div
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          padding: 16,
          cursor: 'pointer',
        }}
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
      >
        <svg
          width="24"
          height="24"
          viewBox="0 0 24 24"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            d="M19 6.41L17.59 5L12 10.59L6.41 5L5 6.41L10.59 12L5 17.59L6.41 19L12 13.41L17.59 19L19 17.59L13.41 12L19 6.41Z"
            fill={foreground}
          />
        </svg>
      </motion.div>

      {index > 0 && (
        <NavigationButton
          side="left"
          color={foreground}
          onPress={() => onNavigate(-1)}
        />
      )}
      {index < count - 1 && (
        <NavigationButton
          side="right"
          color={foreground}
          onPress={() => onNavigate(1)}
        />
      )}

      <OnScrollOnce onScroll={onClose} />
    </>
  )
}

function NavigationButton({
  side,
  color,
  onPress,
}: {
  side: 'left' | 'right'
  color: string
  onPress: () => void
}) {
  return (
    <motion.button
      type="button"
      aria-label={side === 'left' ? 'Previous' : 'Next'}
      style={{
        position: 'absolute',
        top: '50%',
        [side]: 0,
        y: '-50%',
        padding: 16,
        border: 'none',
        background: 'none',
        cursor: 'pointer',
      }}
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      onClick={(event) => {
        event.stopPropagation()
        onPress()
      }}
    >
      <svg
        width="24"
        height="24"
        viewBox="0 0 24 24"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path
          d={
            side === 'left'
              ? 'M15.41 7.41L14 6L8 12L14 18L15.41 16.59L10.83 12L15.41 7.41Z'
              : 'M8.59 16.59L10 18L16 12L10 6L8.59 7.41L13.17 12L8.59 16.59Z'
          }
          fill={color}
        />
      </svg>
    </motion.button>
  )
}

function getWindowDimensions() {
  // same measurement as react-native-web's Dimensions, without depending on react-native
  const { visualViewport } = window
  if (visualViewport) {
    return {
      width: Math.round(visualViewport.width * visualViewport.scale),
      height: Math.round(visualViewport.height * visualViewport.scale),
    }
  }
  return {
    width: document.documentElement.clientWidth,
    height: document.documentElement.clientHeight,
  }
}

function useWindowDimensions() {
  const [dimensions, setDimensions] = useState(getWindowDimensions)
  useEffect(() => {
    const target = window.visualViewport ?? window
    const onResize = () => setDimensions(getWindowDimensions())
    target.addEventListener('resize', onResize)
    return () => target.removeEventListener('resize', onResize)
  }, [])
  return dimensions
}

function WindowDimensions({
  children,
}: {
  children: (dimensions: { width: number; height: number }) => React.ReactNode
}) {
  const dimensions = useWindowDimensions()
  return children(dimensions)
}

function OnScrollOnce({ onScroll }: { onScroll: () => void }) {
  useDomEvent(useRef(window), 'scroll', onScroll)
  useDomEvent(useRef(window), 'wheel', (event) => {
    // not a trackpad's horizontal swipe, which goes along the items (Viewer)
    const { deltaX, deltaY } = event as WheelEvent
    if (Math.abs(deltaY) >= Math.abs(deltaX)) onScroll()
  })

  return null
}

// pauses as it slides out, rather than playing on with the next item
function ViewerVideo(props: ComponentProps<(typeof motion)['video']>) {
  const ref = useRef<HTMLVideoElement>(null)
  const isPresent = useIsPresent()
  useEffect(() => {
    if (!isPresent) ref.current?.pause()
  }, [isPresent])
  return <motion.video ref={ref} {...props} />
}

function isKeyboardTarget(target: EventTarget | null) {
  return (
    target instanceof HTMLMediaElement ||
    target instanceof HTMLInputElement ||
    target instanceof HTMLTextAreaElement ||
    (target instanceof HTMLElement && target.isContentEditable)
  )
}

function PopupModal({
  visible,
  children,
  onPointerDown,
  onClose,
}: {
  visible: boolean
  children: React.ReactNode
  onPointerDown?: () => void
  onClose: () => void
}) {
  const elementRef = useRef<HTMLDivElement | null>(null)
  if (typeof window !== 'undefined' && !elementRef.current) {
    const element = document.createElement('div')
    element.setAttribute('galeria-popup', '1')

    if (element && document.body) {
      document.body.appendChild(element)
      elementRef.current = element
    }
  }

  // eslint-disable-next-line react-hooks/rules-of-hooks
  useEffect(function cleanup() {
    return () => {
      if (document.body && elementRef.current) {
        document.body.removeChild(elementRef.current)
        elementRef.current = null
      }
    }
  }, [])

  if (!visible) return null
  const node = (
    <div
      style={{
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        zIndex: 100,
      }}
      onPointerDownCapture={onPointerDown}
      onClick={(e) => {
        onClose()
      }}
    >
      {children}
    </div>
  )
  return elementRef.current ? createPortal(node, elementRef.current) : null
}

const Galeria: typeof Native = Object.assign(Root, {
  Image,
  Item: Image,
  Popup: () => null,
})

export default Galeria

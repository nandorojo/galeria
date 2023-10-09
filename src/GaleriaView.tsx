import {
  useState,
  useId,
  useRef,
  useEffect,
  useLayoutEffect,
  cloneElement,
  ComponentProps,
  useContext,
} from 'react'

import { GaleriaViewProps } from './Galeria.types'
import type Native from './GaleriaView.ios'
import {
  LayoutGroup,
  animate,
  motion,
  useMotionValue,
  useTransform,
} from 'framer-motion'
import { Dimensions, Modal } from 'react-native'
import { GaleriaContext } from './context'

const useClientEffect =
  typeof window === 'undefined' ? useEffect : useLayoutEffect

function Popup({ disableTransition }: { disableTransition?: 'web' }) {
  const { open } = useContext(GaleriaContext)

  // necessary to reset the state
  // also, let's not render unnecessary hooks, etc
  if (open) return <OpenPopup disableTransition={Boolean(disableTransition)} />

  return null
}

function OpenPopup({ disableTransition }: { disableTransition: boolean }) {
  const { open, setOpen, urls, initialIndex, theme, src, ids } =
    useContext(GaleriaContext)

  const isDragging = useMotionValue(false)
  const carousel = urls.length > 1 && urls

  const images = carousel || [src].filter(Boolean)

  const scrollRef = useRef<HTMLDivElement>(null)

  useClientEffect(
    function setInitialScrollIndex() {
      const scroller = scrollRef.current
      if (open && scroller) {
        const elementToScrollTo: HTMLDivElement | null = document.querySelector(
          `[data-galeria-index="${initialIndex}"]`,
        )
        if (elementToScrollTo) {
          scroller.scrollLeft = elementToScrollTo.offsetLeft
        }
      }
    },
    [open, initialIndex],
  )

  if (__DEV__) {
    if (new Set(images).size !== images.length) {
      console.error(
        `GaleriaView: duplicate images found in urls prop. This will cause unexpected behavior.`,
      )
    }
  }

  const dragPercentProgress = useMotionValue(0)

  const backdropOpacity = useTransform(dragPercentProgress, [0, 0.4], [1, 0], {
    clamp: true,
  })

  const [imageIndex = initialIndex, setIndex] = useState<number>()

  useEffect(
    function arrowKeys() {
      const listener = (e: KeyboardEvent) => {
        let nextIndex = imageIndex
        if (e.key === 'ArrowRight') {
          nextIndex = Math.min(imageIndex + 1, images.length - 1)
        } else if (e.key === 'ArrowLeft') {
          nextIndex = Math.max(imageIndex - 1, 0)
        }

        scrollRef.current?.scrollTo({
          left: nextIndex * Dimensions.get('window').width,
          behavior: 'smooth',
        })
      }
      document.addEventListener('keydown', listener)
      return () => {
        document.removeEventListener('keydown', listener)
      }
    },
    [imageIndex, images.length],
  )

  console.log('[popup]', { imageIndex, initialIndex })

  if (!open || images.length < 1) {
    return null
  }

  return (
    <Modal
      visible={open}
      transparent
      onRequestClose={() => setOpen({ open: false })}
    >
      <motion.div
        initial={
          !disableTransition && {
            opacity: 0,
          }
        }
        animate={{
          opacity: 1,
        }}
        transition={{ type: 'timing' }}
        style={{
          position: 'absolute',
          inset: 0,
          zIndex: -1,
          background: theme === 'dark' ? 'black' : 'white',
          opacity: backdropOpacity,
        }}
      ></motion.div>
      <motion.div
        style={{
          width: '100%',
          flexDirection: 'row',
          display: 'flex',
          alignItems: 'center',
          height: '100vh',
          overflowX: 'auto',
          overflowY: 'hidden',
          scrollSnapType: 'x mandatory',
          scrollbarWidth: 'none',
        }}
        onClick={() => {
          // run on next tick to transition back
          if (!isDragging.get()) setTimeout(() => setOpen({ open: false }))
        }}
        ref={scrollRef}
      >
        {images.map((image, i) => {
          const isActiveItem = i === imageIndex
          return (
            <ViewabilityTracker
              onEnter={(entry) => {
                console.log('[onEnter]', i)
                if (open && images.length > 1) setIndex(i)
              }}
              key={image}
              scrollRef={scrollRef}
            >
              <motion.img
                layout={false}
                layoutId={getLayoutId(ids?.[i], i)}
                {...(isActiveItem &&
                  !disableTransition && {
                    layoutId: getLayoutId(ids?.[i], i),
                    layout: true,
                  })}
                layoutScroll
                data-galeria-index={i}
                src={image}
                style={{
                  width: '100%',
                  scrollSnapAlign: 'center',
                  ...(!isActiveItem && {
                    opacity: backdropOpacity,
                  }),
                  height: 'auto',
                  maxHeight: '100%',
                  objectFit: 'contain',
                }}
                drag={carousel ? 'y' : true}
                onDragStart={(e, info) => {
                  isDragging.set(true)
                }}
                onDrag={(e, info) => {
                  const parentHeight =
                    scrollRef.current?.clientHeight || window.innerHeight
                  const percentDragged = Math.abs(info.offset.y / parentHeight)
                  dragPercentProgress.set(percentDragged)
                  console.log('[onDrag]', Math.round(percentDragged * 100))
                }}
                dragSnapToOrigin
                onDragEnd={(e, info) => {
                  const parentHeight =
                    scrollRef.current?.clientHeight || window.innerHeight
                  const percentDragged = Math.abs(info.offset.y / parentHeight)
                  isDragging.set(false)
                  if (percentDragged > 3 || info.velocity.y > 500) {
                    animate(dragPercentProgress, 40, { duration: 0.5 })
                    setOpen({ open: false })
                  } else {
                    animate(dragPercentProgress, 0, { duration: 0.5 })
                  }
                }}
              />
            </ViewabilityTracker>
          )
        })}
      </motion.div>
    </Modal>
  )
}

const getLayoutId = (id: string | undefined, index: number) => {
  const finalId = id || `index-${index}`
  console.log('[getLayoutId]', finalId)
  return finalId
}

function Image({ style, src, index = 0, id }: GaleriaViewProps) {
  const { setOpen } = useContext(GaleriaContext)

  const [openedCount, setOpenedCount] = useState(-1)
  const prevOpenedCount = useRef(openedCount)

  useEffect(
    function triggerOpen() {
      if (openedCount === prevOpenedCount.current) {
        return
      }
      prevOpenedCount.current = openedCount

      // it's opened if the index is greater than -1
      if (openedCount <= -1) return

      setOpen({
        open: true,
        src,
        initialIndex: index ?? 0,
        id,
      })
    },
    [openedCount],
  )

  return (
    // we don't want the image to have layout effects until we have opened it
    // so until then, we render no layout id
    <motion.img
      layoutId={openedCount > -1 ? getLayoutId(id, index) : undefined}
      // in order to change the layout id, we must change they key itself
      // once it's animated once, we don't need to change this again
      key={`${openedCount > -1}`}
      src={src}
      style={style as object}
      onClick={() => {
        // ideally we could just open the gallery here
        // but we can't because that requires this node always having a layoutId
        // so instead we change the key to trigger a re-render
        // i tried flushsync but it appeared to match useLayoutEffect rather than useEffect which wasn't desired
        setOpenedCount((next) => {
          // we use a number each time so that useEffect is fired for each open
          return Math.max(0, next + 1)
        })
      }}
    />
  )
}

const Galeria: typeof Native = Object.assign(
  function Galeria({
    children,
    urls,
    theme = 'light',
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
    return (
      <GaleriaContext.Provider
        value={{
          setOpen,
          urls: urls || [],
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
        <LayoutGroup inherit={false} id={useId()}>
          {children}
        </LayoutGroup>
      </GaleriaContext.Provider>
    )
  },
  {
    Image,
    Popup,
  },
)

export default Galeria

const ViewabilityTracker = ({
  children,
  itemVisiblePercentThreshold = 100,
  onEnter,
  scrollRef,
}: {
  children: JSX.Element
  onEnter?: (entry: IntersectionObserverEntry) => void
  itemVisiblePercentThreshold?: number
  scrollRef: React.RefObject<HTMLDivElement>
}) => {
  const ref = useRef<any>(null)

  const enter = useRef(onEnter)
  useEffect(() => {
    enter.current = onEnter
  })

  useEffect(() => {
    let observer: IntersectionObserver
    observer = new IntersectionObserver(
      ([entry]) => {
        const isVisibleWithinRoot =
          entry.boundingClientRect.top >= (entry.rootBounds?.top || 0) &&
          entry.boundingClientRect.bottom <= (entry.rootBounds?.bottom || 0)

        if (entry.isIntersecting && isVisibleWithinRoot) {
          enter.current?.(entry)
        }
      },

      {
        threshold: itemVisiblePercentThreshold / 100,
        root: scrollRef.current,
      },
    )

    if (ref.current) observer.observe(ref.current)

    return () => {
      observer?.disconnect()
    }
  }, [itemVisiblePercentThreshold])

  return cloneElement(children, { ref })
}

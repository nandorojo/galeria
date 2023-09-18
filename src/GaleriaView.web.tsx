import {
  useState,
  useId,
  useRef,
  useEffect,
  useLayoutEffect,
  cloneElement,
} from 'react'

import { GaleriaViewProps } from './Galeria.types'
import { unstable_createElement } from 'react-native-web'
import {
  AnimatePresence,
  LayoutGroup,
  animate,
  motion,
  useMotionValue,
  useTransform,
} from 'framer-motion'
import { Modal, ScrollView, View } from 'react-native'

const variants = {
  enter: (direction: number) => {
    return {
      x: direction > 0 ? 1000 : -1000,
      opacity: 0,
    }
  },
  center: {
    zIndex: 1,
    x: 0,
    opacity: 1,
  },
  exit: (direction: number) => {
    return {
      zIndex: 0,
      x: direction < 0 ? 1000 : -1000,
      opacity: 0,
    }
  },
}

/**
 * Experimenting with distilling swipe offset and velocity into a single variable, so the
 * less distance a user has swiped, the more velocity they need to register as a swipe.
 * Should accomodate longer swipes and short flicks without having binary checks on
 * just distance thresholds and velocity > 0.
 */
const swipeConfidenceThreshold = 10000
const swipePower = (offset: number, velocity: number) => {
  return Math.abs(offset) * velocity
}

const useClientEffect =
  typeof window === 'undefined' ? useEffect : useLayoutEffect

export default function GaleriaView({
  theme,
  src,
  style,
  ...props
}: GaleriaViewProps) {
  const [open, setOpen] = useState(false)
  const initialIndex = 'initialIndex' in props ? props.initialIndex : 0
  const [imageIndex, setIndex] = useState(initialIndex)
  const id = useId()
  const isDragging = useMotionValue(false)
  const carousel = 'urls' in props && props.urls.length > 1 && props.urls
  const layoutId = (src: string) => src

  const images = carousel || [src]

  const scrollRef = useRef<HTMLDivElement>(null)

  useClientEffect(
    function setInitialScrollIndex() {
      const scroller = scrollRef.current
      if (open && scroller) {
        const scrollerParentWidth =
          scroller.parentElement?.clientWidth || window.innerWidth
        scroller.scrollLeft = initialIndex * scrollerParentWidth
      }
    },
    [open],
  )

  console.log('[imageIndex]', id, imageIndex)

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

  return (
    <LayoutGroup id={id}>
      <motion.img
        layoutId={layoutId(src)}
        src={src}
        style={{
          ...(style as object),
        }}
        onClick={() => {
          setOpen(true)
        }}
      />
      {open && (
        <Modal visible={open} transparent onRequestClose={() => setOpen(false)}>
          <motion.div
            initial={{
              opacity: 0,
            }}
            animate={{
              opacity: 1,
            }}
            transition={{ type: 'timing', duration: 0.3 }}
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
            ref={scrollRef}
          >
            {images.map((image, i) => {
              const isActiveItem = i === imageIndex
              const framerId = isActiveItem ? layoutId(image) : undefined
              return (
                <ViewabilityTracker
                  onEnter={(entry) => {
                    if (open) setIndex(i)
                    console.log('[onEnter]', id, i, entry.intersectionRatio)
                  }}
                  key={image}
                  scrollRef={scrollRef}
                >
                  <motion.img
                    layoutId={framerId}
                    // reset the instance if it's hidden
                    key={framerId}
                    src={image}
                    style={{
                      width: '100%',
                      scrollSnapAlign: 'center',
                    }}
                    drag={carousel ? 'y' : true}
                    onDragStart={(e, info) => {
                      isDragging.set(true)
                    }}
                    onDrag={(e, info) => {
                      const parentHeight =
                        scrollRef.current?.clientHeight || window.innerHeight
                      const percentDragged = Math.abs(
                        info.offset.y / parentHeight,
                      )
                      dragPercentProgress.set(percentDragged)
                      console.log('[onDrag]', Math.round(percentDragged * 100))
                    }}
                    dragSnapToOrigin
                    onDragEnd={(e, info) => {
                      const parentHeight =
                        scrollRef.current?.clientHeight || window.innerHeight
                      const percentDragged = Math.abs(
                        info.offset.y / parentHeight,
                      )
                      isDragging.set(false)
                      if (percentDragged > 5 || info.velocity.y > 500) {
                        animate(dragPercentProgress, 40, { duration: 0.5 })
                        setOpen(false)
                      } else {
                        animate(dragPercentProgress, 0, { duration: 0.5 })
                      }
                    }}
                    onClick={() => {
                      // run on next tick to transition back
                      if (!isDragging.get()) setTimeout(() => setOpen(false))
                    }}
                  />
                </ViewabilityTracker>
              )
            })}
          </motion.div>
        </Modal>
      )}
    </LayoutGroup>
  )
}

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

// // forked from: https://github.com/Popmotion/popmotion/blob/master/packages/popmotion/src/utils/wrap.ts
const wrap = (min: number, max: number, v: number) => {
  const rangeSize = max - min
  return ((((v - min) % rangeSize) + rangeSize) % rangeSize) + min
}

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
  motion,
  useMotionValue,
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
  const layoutId = (src: string) => [src, id].join('-')

  const images = carousel || [src]

  const scrollRef = useRef<HTMLDivElement>(null)

  useClientEffect(
    function setInitialScrollIndex() {
      const scroller = scrollRef.current
      if (open && scroller) {
        const scrollerParentWidth =
          scroller.parentElement?.clientWidth || window.innerWidth
        scroller.scrollLeft = initialIndex * scrollerParentWidth

        // const getClosestIndex = (e: Event) => {
        //   const scrollerParentWidth =
        //     scroller.parentElement?.clientWidth || window.innerWidth
        //   const scrollLeft = scroller.scrollLeft
        //   const index = Math.round(scrollLeft / scrollerParentWidth)
        //   setIndex(index)
        //   console.log('[scrollend]', index)
        // }

        // scroller.addEventListener('scrollend', getClosestIndex)

        // return () => {
        //   scroller?.removeEventListener('scrollend', getClosestIndex)
        // }
      }
    },
    [open],
  )

  return (
    <>
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
          drag={carousel ? 'y' : true}
          onDragStart={(e, info) => {
            isDragging.set(true)
          }}
          dragSnapToOrigin
          onDragEnd={(e, info) => {
            const distanceDragged = Math.max(
              Math.abs(info.offset.y),
              carousel ? Math.abs(info.offset.x) : 0,
            )
            isDragging.set(false)
            if (distanceDragged > 150 || info.velocity.y > 500) {
              setOpen(false)
            }
          }}
          onClick={() => {
            // run on next tick to transition back
            if (!isDragging.get()) setTimeout(() => setOpen(false))
          }}
          ref={scrollRef}
        >
          {images.map((image, i) => {
            return (
              <ViewabilityTracker
                onEnter={() => {
                  setIndex(i)
                }}
                key={image}
              >
                <motion.img
                  layoutId={imageIndex === i ? layoutId(image) : undefined}
                  src={image}
                  style={{
                    width: '100%',
                    scrollSnapAlign: 'center',
                    pointerEvents: 'none',
                  }}
                />
              </ViewabilityTracker>
            )
          })}
        </motion.div>
      </Modal>
    </>
  )
}

const ViewabilityTracker = ({
  children,
  itemVisiblePercentThreshold = 100,
  onEnter,
}: {
  children: JSX.Element
  onEnter?: () => void
  itemVisiblePercentThreshold?: number
}) => {
  const ref = useRef<any>(null)

  const enter = useRef(onEnter)
  useEffect(() => (enter.current = onEnter))

  useEffect(() => {
    let observer: IntersectionObserver
    if (enter.current) {
      observer = new IntersectionObserver(
        ([entry]) => {
          if (entry.isIntersecting) {
            enter.current?.()
          }
        },

        {
          threshold: itemVisiblePercentThreshold / 100,
        },
      )

      if (ref.current) observer.observe(ref.current)
    }

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

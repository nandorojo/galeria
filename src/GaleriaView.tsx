import {
  useState,
  useId,
  ComponentProps,
  useRef,
  useEffect,
  useContext,
  useLayoutEffect,
  isValidElement,
  cloneElement,
  useCallback,
  useMemo,
} from 'react'
import { createPortal } from 'react-dom'
import { Dimensions, Image as ReactImage } from 'react-native'

import { GaleriaViewProps } from './Galeria.types'
import type Native from './GaleriaView.ios'

import {
  LayoutGroup,
  motion,
  useDragControls,
  useMotionValue,
  useTransform,
} from 'framer-motion'
import { GaleriaContext } from './context'

import { Modal } from 'react-native'

const useEffecter = typeof window === 'undefined' ? useLayoutEffect : useEffect

/** TODO */
function ImageOld({ __web, index = 0, children, style }: GaleriaViewProps) {
  const [{ open, aspectRatio }, setOpen] = useState({
    open: false,
    aspectRatio: 1,
  })

  const { theme, urls } = useContext(GaleriaContext)

  const id = useId()

  const ref = useRef<HTMLDivElement>(null)

  const direction = aspectRatio > 1 ? 'horizontal' : 'vertical'

  useEffect(function scrollListener() {
    const handler = (e: any) => {
      setOpen(({ open, aspectRatio }) => ({
        open: false,
        aspectRatio,
      }))
    }

    document.addEventListener('scroll', handler)

    return () => {
      document.removeEventListener('scroll', handler)
    }
  }, [])

  const src = urls?.[index]

  const dragPosition = useDragControls()

  const pan = useMotionValue(-1)

  const startDragPosition = useRef({ x: 0, y: 0 })
  const screenHeight = Dimensions.get('window').height

  return (
    <>
      <motion.div
        {...__web}
        ref={ref}
        layout
        layoutId={id}
        onClick={() => {
          const bounding = ref.current?.getBoundingClientRect()
          setOpen(({ open }) => ({
            open: !open,
            aspectRatio: bounding ? bounding.height / bounding.width : 1,
          }))
        }}
        style={{ ...(style as object) }}
      >
        {isValidElement(children)
          ? cloneElement(children, { draggable: false } as object)
          : children}
      </motion.div>

      <Modal
        animationType="none"
        transparent
        visible={open}
        onRequestClose={() =>
          setOpen((current) => ({
            ...current,
            open: !current.open,
          }))
        }
      >
        <div
          style={{
            height: '100%',
            width: '100%',
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            position: 'relative',
          }}
          onClick={() => {
            setOpen((current) => ({ ...current, open: false }))
          }}
        >
          <motion.div
            style={{
              background: theme === 'dark' ? 'black' : 'white',
              position: 'absolute',
              inset: 0,
              opacity: useTransform(pan, (dragY) => {
                if (dragY === -1) return 1
                const dragPercent = (screenHeight - dragY) / screenHeight
                return dragPercent
              }),
            }}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
          />

          <motion.div
            style={{
              touchAction: 'none',
              msTouchAction: 'none',
              aspectRatio,
              ...(direction === 'horizontal'
                ? { width: '100%', paddingBottom: `${100 / aspectRatio}%` }
                : { height: '100%', width: `${100 / aspectRatio}%` }),
            }}
            layoutId={id}
            drag="y"
            onDragStart={(e, { point }) => {
              startDragPosition.current = point
            }}
            onDrag={(_, { delta, point }) => {
              const y = point.y - startDragPosition.current.y
              pan.set(Math.abs(y))
              console.log('[pan]', y)
            }}
          >
            <motion.div
              style={{
                height: '100%',
                width: '100%',
              }}
            >
              <ReactImage
                style={{
                  height: '100%',
                  width: '100%',
                }}
                source={typeof src === 'string' ? { uri: src } : src}
                {...{ draggable: false }}
              />
            </motion.div>
          </motion.div>
        </div>
      </Modal>
    </>
  )
}

function Image({ __web, index = 0, children, style }: GaleriaViewProps) {
  const [isOpen, setIsOpen] = useState(false)
  const { urls } = useContext(GaleriaContext)
  const url = urls?.[index]
  const parentRef = useRef<HTMLDivElement>()
  const [aspectRatio, setAspectRatio] = useState(1)
  const id = useId()
  return (
    <>
      <motion.div
        style={style as object}
        onClick={() => setIsOpen(true)}
        ref={useMemo(
          () => (ref) => {
            if (ref) {
              const { height, width } = ref.getBoundingClientRect()
              setAspectRatio(height / width)
              parentRef.current = ref
            }
          },
          [],
        )}
        layoutId={id}
      >
        {isValidElement(children)
          ? cloneElement(children, { draggable: false } as object)
          : children}
      </motion.div>

      <PopupModal visible={isOpen} onClose={() => setIsOpen(false)}>
        {url ? (
          <motion.img
            layoutId={id}
            style={{
              width: '100%',
              height: `${100 / aspectRatio}%`,
              objectFit: 'cover',
            }}
            src={url as string}
          ></motion.img>
        ) : null}
      </PopupModal>
    </>
  )
}

function Root({
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
      <LayoutGroup inherit={false} id={useId()}>
        {children}
      </LayoutGroup>
    </GaleriaContext.Provider>
  )
}

function PopupModal({
  visible,
  children,
  onClose,
}: {
  visible: boolean
  children: React.ReactNode
  onClose: () => void
}) {
  const elementRef = useRef<HTMLDivElement | null>(null)
  if (typeof window !== 'undefined' && !elementRef.current) {
    const element = document.createElement('div')
    element.setAttribute('galeria-popup', 'hello-inspector')

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

  // for radix menus, which glitch a lot with regular modals on RNW
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
      onClick={onClose}
    >
      {children}
    </div>
  )
  return elementRef.current ? createPortal(node, elementRef.current) : null
}

const Galeria: typeof Native = Object.assign(Root, {
  Image,
  Popup: () => null,
})

export default Galeria

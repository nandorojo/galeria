'use client'
import {
  useState,
  useId,
  ComponentProps,
  useRef,
  useEffect,
  useContext,
  isValidElement,
  cloneElement,
} from 'react'
import { createPortal } from 'react-dom'
import { useWindowDimensions } from 'react-native' // TODO: remove this

import { GaleriaViewProps } from './Galeria.types'
import type Native from './GaleriaView.ios'

import { LayoutGroup, motion, useDomEvent } from 'framer-motion'
import { GaleriaContext } from './context'

function Image({
  __web,
  index = 0,
  children,
  style,
  dynamicAspectRatio = false,
}: GaleriaViewProps) {
  const [isOpen, setIsOpen] = useState(false)
  const { urls, theme } = useContext(GaleriaContext)
  const url = urls?.[index]
  const [aspectRatio, setAspectRatio] = useState(1)
  const id = useId()
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
  const onClick = (
    e: React.MouseEvent<HTMLDivElement> | React.TouchEvent<HTMLDivElement>,
  ) => {
    const imageNode = getFirstImageChild(e.target as Node)
    if (imageNode) {
      setIsOpen(true)
      const ratio = getNodeAspectRatio(imageNode)
      setAspectRatio(ratio)
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
  const background = {
    light: '#ffffff',
    dark: '#000000',
  }[theme]
  const foreground = {
    light: '#000000',
    dark: '#ffffff',
  }[theme]
  const [wasOpen, setWasOpen] = useState(false)

  if (isOpen && !wasOpen) {
    setWasOpen(true)
  }

  return (
    <>
      <motion.div
        style={{ zIndex: index + (wasOpen ? 1000 : 0), ...style } as object}
        // faster than onClick
        // onMouseDown={onClick}
        // onTouchStart={onClick}
        onClick={onClick}
        layoutId={id}
      >
        {isValidElement(children)
          ? cloneElement(children, { draggable: false } as object)
          : children}
      </motion.div>

      <PopupModal visible={isOpen} onClose={() => setIsOpen(false)}>
        <WindowDimensions>
          {(dimensions) => {
            // given the image aspect ratio, and the window dimensions, we want to derive the proper height and width
            // such that it spans the size of the window with a "contain" effect, but implemented in code rather than using object-fit

            // Calculate dimensions for "contain" effect
            const windowRatio = dimensions.width / dimensions.height
            const imageRatio = aspectRatio

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
              <motion.div
                style={{
                  position: 'absolute',
                  inset: 0,
                  display: 'flex',
                  justifyContent: 'center',
                  alignItems: 'center',
                }}
                initial={{ backgroundColor: background + '00' }}
                animate={{ backgroundColor: background }}
                exit={{ backgroundColor: background + '00' }}
              >
                {url ? (
                  <motion.img
                    layoutId={id}
                    style={{
                      width,
                      height,
                      objectFit: 'cover',
                      zIndex: 2000,
                    }}
                    src={url as string}
                  ></motion.img>
                ) : null}
              </motion.div>
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

        <OnScrollOnce
          onScroll={() => {
            isOpen && setIsOpen(false)
          }}
        />
      </PopupModal>
    </>
  )
}

function Root({
  children,
  urls,
  theme = 'dark',
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
      <LayoutGroup inherit={false} id={useId()}>
        {children}
      </LayoutGroup>
    </GaleriaContext.Provider>
  )
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
  useDomEvent(useRef(window), 'wheel', onScroll)

  return null
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
  Popup: () => null,
})

export default Galeria

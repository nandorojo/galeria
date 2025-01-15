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

import { GaleriaViewProps } from './Galeria.types'
import type Native from './GaleriaView.ios'

import { LayoutGroup, motion } from 'framer-motion'
import { GaleriaContext } from './context'

function GaleriaImage({
  __web,
  index = 0,
  children,
  style,
  ...props
}: GaleriaViewProps) {
  const [isOpen, setIsOpen] = useState(false)
  const { urls, theme } = useContext(GaleriaContext)
  let url = urls?.[index]
  const [measuredAspectRatio, setAspectRatio] = useState(1)
  const aspectRatio = props.aspectRatio ?? measuredAspectRatio
  const id = useId()
  const getFirstImageChild = (node: Node) => {
    if (node.nodeType === 1 && node.nodeName === 'IMG') {
      return node
    }
    if (node.childNodes) {
      return getFirstImageChild(node.childNodes[0])
    }
    return null
  }
  const getNodeAspectRatio = (node: Node) => {
    const imageNode = getFirstImageChild(node)
    if (imageNode) {
      return (
        imageNode.getBoundingClientRect().height /
        imageNode.getBoundingClientRect().width
      )
    }
    return 1
  }
  const onClick = (e) => {
    const imageNode = getFirstImageChild(e.target as Node)
    if (imageNode) {
      setIsOpen(true)
      const ratio = getNodeAspectRatio(imageNode)
      setAspectRatio(ratio)
      if (
        typeof process != 'undefined' &&
        typeof process.env != 'undefined' &&
        process?.env?.NODE_ENV === 'development'
      ) {
        const nodeAspectRatio = getNodeAspectRatio(e.target)

        console.log('node-aspect-ratio', nodeAspectRatio)

        if (nodeAspectRatio !== ratio) {
          console.error(
            `[galeria] Galeria.Image does not have the same aspect ratio as its child.
            
This might result in a weird animation. To fix it, pass the "style" prop to Galeria.Image to give it the same height & width as the image.`,
          )
        }
      }
    }
  }
  const isHorizontal = Number(measuredAspectRatio.toFixed(3)) >= 1
  if (typeof url === 'number') {
    console.error(`[galeria] urls[${index}] failed to get image: Expo Web/Metro Web does not currently support locally-imported images with <Galeria.Image />

Please use a remote image in the urls[] array prop of your <Galeria> for now.`)
  }
  return (
    <>
      <motion.div
        style={
          {
            zIndex: index,
            ...style,
          } as React.CSSProperties
        }
        onMouseEnter={function preloadOnHover() {
          if (typeof url === 'string') {
            try {
              const img = new Image()
              img.src = url
            } catch {}
          }
        }}
        // faster than onClick
        onMouseDown={onClick}
        onTouchStart={onClick}
        layoutId={id}
        aria-label="test"
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
              ...{
                ...(aspectRatio > 1
                  ? {
                      width: `100%`,
                      aspectRatio,
                    }
                  : {
                      height: '100%',
                      aspectRatio,
                    }),
              },
              objectFit: 'cover',
              zIndex: 2000,
            }}
            src={url as string}
          ></motion.img>
        ) : null}
      </PopupModal>
    </>
  )
}

function Popup() {}

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
  const { theme } = useContext(GaleriaContext)
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
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
      }}
      onClick={onClose}
    >
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        style={{
          zIndex: -1,
          position: 'absolute',
          inset: 0,
          background: theme === 'dark' ? '#000000' : '#ffffff',
        }}
      />
      {children}
    </div>
  )
  return elementRef.current ? createPortal(node, elementRef.current) : null
}

const Galeria: typeof Native = Object.assign(Root, {
  Image: GaleriaImage,
  Popup: () => null,
})

export default Galeria

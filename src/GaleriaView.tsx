import {
  useState,
  useId,
  ComponentProps,
  useRef,
  useEffect,
  cloneElement,
  isValidElement,
  useContext,
  useLayoutEffect,
} from 'react'

import { GaleriaViewProps } from './Galeria.types'
import type Native from './GaleriaView.ios'

import { LayoutGroup, motion, useScroll, scrollInfo } from 'framer-motion'
import { GaleriaContext } from './context'

import { Modal } from 'react-native'

const useEffecter = typeof window === 'undefined' ? useLayoutEffect : useEffect

/** TODO */
function Image({ __web, index = 0, children, style }: GaleriaViewProps) {
  const [{ open, aspectRatio }, setOpen] = useState({
    open: false,
    aspectRatio: 1,
  })

  const { theme } = useContext(GaleriaContext)

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
        {children}
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
            }}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
          />

          <motion.div
            style={{
              aspectRatio,
              ...(direction === 'horizontal'
                ? { width: '100%', paddingBottom: `${100 / aspectRatio}%` }
                : { height: '100%' }),
            }}
            layoutId={id}
          >
            <div style={{ display: 'contents', pointerEvents: 'none' }}>
              {isValidElement(children)
                ? cloneElement(children, {
                    style: {
                      ...(children.props as any)?.style,
                      height: '100%',
                      width: '100%',
                    },
                  } as object)
                : children}
            </div>
          </motion.div>
        </div>
      </Modal>
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

const Galeria: typeof Native = Object.assign(Root, {
  Image,
  Popup: () => null,
})

export default Galeria

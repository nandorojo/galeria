import { useState, useId, ComponentProps } from 'react'

import { GaleriaViewProps } from './Galeria.types'
import type Native from './GaleriaView.ios'
import { LayoutGroup, motion } from 'framer-motion'
import { GaleriaContext } from './context'

/** TODO */
function Image({ __web, index = 0, id, children }: GaleriaViewProps) {
  const [open, setOpen] = useState(false)

  console.log('[GALERIA] web support coming soon...')

  return (
    <motion.div
      {...__web}
      layout
      onClick={() => {
        setOpen((next) => !open)
      }}
      style={{
        display: 'contents',
      }}
    >
      {children}
    </motion.div>
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

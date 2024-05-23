import type { motion } from 'framer-motion'
import type { ComponentProps } from 'react'

export type ChangeEventPayload = {
  value: string
}

export type GaleriaViewProps = {
  index?: number
  id?: string
  children: React.ReactElement
  __web?: ComponentProps<(typeof motion)['div']>
}

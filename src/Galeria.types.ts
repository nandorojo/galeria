import type { motion } from 'framer-motion'
import { ComponentProps } from 'react'
import { ImageStyle } from 'react-native'

export type ChangeEventPayload = {
  value: string
}

export type GaleriaViewProps = {
  style?: ImageStyle
  src: string
  index?: number
  id?: string
  __web?: ComponentProps<(typeof motion)['img']>
  recyclingKey?: string
}

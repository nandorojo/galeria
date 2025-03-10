import type { motion } from 'framer-motion'
import type { ComponentProps } from 'react'
import { ViewStyle } from 'react-native'
import { SFSymbol } from 'sf-symbols-typescript'

export type ChangeEventPayload = {
  value: string
}

export type GaleriaViewProps = {
  index?: number
  id?: string
  children: React.ReactElement
  closeIconName?: SFSymbol
  __web?: ComponentProps<(typeof motion)['div']>
  style?: ViewStyle
  dynamicAspectRatio?: boolean
}

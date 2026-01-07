import type { motion } from 'framer-motion'
import type { ComponentProps } from 'react'
import type { NativeSyntheticEvent } from 'react-native'
import { ViewStyle } from 'react-native'
import type { SFSymbol } from 'sf-symbols-typescript'

export type ChangeEventPayload = {
  value: string
}

type GaleriaIndexChangedPayload = {
  currentIndex: number
}

export type GaleriaIndexChangedEvent =
  NativeSyntheticEvent<GaleriaIndexChangedPayload>

export interface GaleriaViewProps {
  index?: number
  id?: string
  children: React.ReactElement
  closeIconName?: SFSymbol
  __web?: ComponentProps<(typeof motion)['div']>
  style?: ViewStyle
  dynamicAspectRatio?: boolean
  edgeToEdge?: boolean
  onIndexChange?: (event: GaleriaIndexChangedEvent) => void
  hideBlurOverlay?: boolean
  hidePageIndicators?: boolean
}

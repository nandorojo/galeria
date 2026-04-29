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

export type GaleriaRightNavItemPressedEvent =
  NativeSyntheticEvent<{ index: number }>

export interface GaleriaViewProps {
  index?: number
  id?: string
  children: React.ReactElement
  closeIconName?: SFSymbol
  /** iOS only: SF Symbol name for an action button shown in the viewer's top-right nav bar. */
  rightNavItemIconName?: SFSymbol
  __web?: ComponentProps<(typeof motion)['div']>
  style?: ViewStyle
  dynamicAspectRatio?: boolean
  edgeToEdge?: boolean
  onIndexChange?: (event: GaleriaIndexChangedEvent) => void
  /** iOS only: fired when the right nav item button is tapped inside the viewer. */
  onPressRightNavItemIcon?: (event: GaleriaRightNavItemPressedEvent) => void
  hideBlurOverlay?: boolean
  hidePageIndicators?: boolean
}

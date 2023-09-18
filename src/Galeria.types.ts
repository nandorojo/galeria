import { ImageStyle } from 'react-native'

export type ChangeEventPayload = {
  value: string
}

export type GaleriaViewProps = {
  style?: ImageStyle
  src: string
  index?: number
}

import { ImageSourcePropType } from 'react-native'

export type GaleriaProps = {
  urls: (string | ImageSourcePropType)[]
  children: React.ReactNode
}

export type GaleriaImageProps = {
  index?: number
  children: React.ReactElement
}

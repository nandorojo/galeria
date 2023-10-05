import { Image as NativeImage } from 'react-native'
import type Native from './GaleriaView.ios'

const android: typeof Native = Object.assign(
  function Galeria({ children }) {
    return <>{children}</>
  },
  {
    Image({ src, style }) {
      return (
        <NativeImage
          style={style}
          source={{
            uri: src,
          }}
        />
      )
    },
    Popup() {
      return <></>
    },
  },
)

export default android

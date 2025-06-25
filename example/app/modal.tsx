import { Galeria } from 'galeria'
import { StyleSheet, View } from 'react-native'
import Image from 'react-native-fast-image'
import { urls } from '../constants/Images'

export default function ModalScreen() {
  return (
    <View style={styles.container}>
      <Galeria urls={urls} theme="dark">
        <Galeria.Image>
          <Image
            style={{
              height: 245,
              width: 245,
              objectFit: 'cover',
            }}
            source={{ uri: urls[0] }}
          />
        </Galeria.Image>
      </Galeria>
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
})

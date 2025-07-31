import { Image } from 'expo-image'
import { Galeria } from 'galeria'
import { StyleSheet, Text, View } from 'react-native'
import { urls } from '../constants/Images'

export default function SecondModalScreen() {
  return (
    <View style={styles.container}>
      <Text>Second Modal with Galeria</Text>

      <Galeria urls={[urls[4]]} theme="dark">
        <Galeria.Image>
          <Image
            style={{
              height: 245,
              width: 245,
              objectFit: 'cover',
            }}
            source={{ uri: urls[4] }}
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

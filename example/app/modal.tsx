import { Image } from 'expo-image'
import { Galeria } from 'galeria'
import { Button, StyleSheet, View } from 'react-native'
import { urls } from '../constants/Images'
import { useRouter } from 'expo-router'

export default function ModalScreen() {
  const router = useRouter()
  return (
    <View style={styles.container}>
      <Galeria urls={urls} theme="dark">
        <Galeria.Image
          onIndexChange={(e) =>
            console.log('IndeX: ', e.nativeEvent.currentIndex)
          }
        >
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

      <Button
        title="Open new modal Modal"
        onPress={() => router.push('/second-modal')}
      />
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

import { StatusBar } from 'expo-status-bar'
import { Galeria } from 'galeria'
import { Platform, StyleSheet, Text, View } from 'react-native'
import { urls } from '../constants/Images'
import { Image } from 'expo-image'

export default function ModalScreen() {
  return (
    <View style={styles.container}>
      <Galeria urls={urls} theme="light">
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

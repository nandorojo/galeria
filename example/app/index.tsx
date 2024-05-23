import { urls } from '../constants/Images'
import { FlashList } from '@shopify/flash-list'
import { Galeria } from 'galeria'
import {
  StyleSheet,
  View,
  Dimensions,
  ImageResolvedAssetSource,
} from 'react-native'
import { Image } from 'expo-image'

export default function PhotosScreen() {
  return (
    <View style={styles.container}>
      <Galeria urls={urls}>
        <FlashList
          data={urls}
          renderItem={({ item, index }) => {
            return (
              <Galeria.Image index={index}>
                <Image
                  style={styles.image}
                  source={src(item)}
                  recyclingKey={item + index}
                />
              </Galeria.Image>
            )
          }}
          numColumns={3}
          estimatedItemSize={size}
          keyExtractor={(item, i) => item + i}
        />
      </Galeria>
    </View>
  )
}

const size = Dimensions.get('window').width / 3
const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  image: {
    width: size,
    height: size,
  },
})

const src = (s: any) => (typeof s === 'string' ? { uri: s } : s)

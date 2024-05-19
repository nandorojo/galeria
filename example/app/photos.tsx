import { FlashList, ListRenderItemInfo } from '@shopify/flash-list'
import { Galeria } from 'galeria'
import { StyleSheet, View, Dimensions } from 'react-native'
import { urls } from '../constants/Images'
import { Image } from 'expo-image'
import { Image as Nativeimage } from 'react-native'
const itemWidth = Dimensions.get('window').width / 3

export default function PhotosScreen() {
  return (
    <View style={styles.container}>
      <Galeria urls={urls} theme="dark">
        <FlashList
          data={urls}
          renderItem={({ item: url, index }) => {
            return (
              <Galeria.Image index={index}>
                <Image
                  style={{
                    width: itemWidth,
                    height: itemWidth,
                  }}
                  source={{ uri: url }}
                  recyclingKey={url + index}
                />
              </Galeria.Image>
            )
          }}
          numColumns={3}
          estimatedItemSize={itemWidth}
          keyExtractor={(item, i) => item + i}
        />
      </Galeria>
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
})

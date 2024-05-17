import { FlashList, ListRenderItemInfo } from '@shopify/flash-list'
import { Galeria } from 'galeria'
import { StyleSheet, View, Dimensions } from 'react-native'
import { urls } from '../constants/Images'
import { Image } from 'expo-image'
import { Image as Nativeimage } from 'react-native'
const itemWidth = Dimensions.get('window').width / 3

export default function PhotosScreen() {
  const renderItem = ({ item: url, index }: ListRenderItemInfo<string>) => {
    return (
      <Galeria.Image id={url} index={index}>
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
  }
  return (
    <View style={styles.container}>
      <Galeria urls={urls} theme="dark">
        <FlashList
          data={urls}
          renderItem={renderItem}
          numColumns={3}
          estimatedItemSize={itemWidth}
          keyExtractor={(item, i) => item + i}
        />
        <Galeria.Popup />
      </Galeria>
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
})

import { FlashList, ListRenderItemInfo } from '@shopify/flash-list'
import { Image } from 'expo-image'
import { Galeria } from 'galeria'
import { Dimensions, StyleSheet, View } from 'react-native'
import { urls } from '../constants/Images'

const itemWidth = Dimensions.get('window').width / 3

export default function PhotosScreen() {
  const renderItem = ({ item: url, index }: ListRenderItemInfo<string>) => {
    return (
      <Galeria.Image
        id={url}
        index={index}
        onIndexChange={(e) =>
          console.log('Index: ', e.nativeEvent.currentIndex)
        }
        style={{
          backgroundColor: 'black',
          borderWidth: 1,
        }}
      >
        <Image
          style={{
            width: itemWidth,
            height: itemWidth,
          }}
          source={typeof url === 'string' ? { uri: url } : url}
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
    flexGrow: 1,
    flexBasis: 0,
  },
})

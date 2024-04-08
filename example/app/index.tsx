import {
  ScrollView,
  StyleSheet,
  View,
  Image as nativeimage,
} from 'react-native'
import { FlashList } from '@shopify/flash-list'
import image from '../assets/favicon.png'

import { Galeria } from 'galeria'
import { Fragment } from 'react'
import { Image } from 'expo-image'

const urls = [
  'https://res.cloudinary.com/dn29xlaeh/image/upload/q_75,w_600,fl_lossy/beatgig-sandbox/chat/hmpschevbtbzjockgq6n',
  'https://raw.githubusercontent.com/michaelhenry/MHFacebookImageViewer/master/Example/Demo/Assets.xcassets/cat1.imageset/cat1.jpg',
  'https://d33wubrfki0l68.cloudfront.net/dd23708ebc4053551bb33e18b7174e73b6e1710b/dea24/static/images/wallpapers/shared-colors@2x.png',
  'https://d33wubrfki0l68.cloudfront.net/49de349d12db851952c5556f3c637ca772745316/cfc56/static/images/wallpapers/bridge-02@2x.png',
  'https://d33wubrfki0l68.cloudfront.net/594de66469079c21fc54c14db0591305a1198dd6/3f4b1/static/images/wallpapers/bridge-01@2x.png',
  'https://res.cloudinary.com/dn29xlaeh/image/upload/q_75,w_600,fl_lossy/beatgig-sandbox/chat/hmpschevbtbzjockgq6n',
  'https://raw.githubusercontent.com/michaelhenry/MHFacebookImageViewer/master/Example/Demo/Assets.xcassets/cat1.imageset/cat1.jpg',
  'https://d33wubrfki0l68.cloudfront.net/dd23708ebc4053551bb33e18b7174e73b6e1710b/dea24/static/images/wallpapers/shared-colors@2x.png',
  'https://d33wubrfki0l68.cloudfront.net/49de349d12db851952c5556f3c637ca772745316/cfc56/static/images/wallpapers/bridge-02@2x.png',
  'https://d33wubrfki0l68.cloudfront.net/594de66469079c21fc54c14db0591305a1198dd6/3f4b1/static/images/wallpapers/bridge-01@2x.png',
  'https://res.cloudinary.com/dn29xlaeh/image/upload/q_75,w_600,fl_lossy/beatgig-sandbox/chat/hmpschevbtbzjockgq6n',
  'https://raw.githubusercontent.com/michaelhenry/MHFacebookImageViewer/master/Example/Demo/Assets.xcassets/cat1.imageset/cat1.jpg',
  'https://d33wubrfki0l68.cloudfront.net/dd23708ebc4053551bb33e18b7174e73b6e1710b/dea24/static/images/wallpapers/shared-colors@2x.png',
  'https://d33wubrfki0l68.cloudfront.net/49de349d12db851952c5556f3c637ca772745316/cfc56/static/images/wallpapers/bridge-02@2x.png',
  'https://d33wubrfki0l68.cloudfront.net/594de66469079c21fc54c14db0591305a1198dd6/3f4b1/static/images/wallpapers/bridge-01@2x.png',
  'https://res.cloudinary.com/dn29xlaeh/image/upload/q_75,w_600,fl_lossy/beatgig-sandbox/chat/hmpschevbtbzjockgq6n',
  'https://raw.githubusercontent.com/michaelhenry/MHFacebookImageViewer/master/Example/Demo/Assets.xcassets/cat1.imageset/cat1.jpg',
  'https://d33wubrfki0l68.cloudfront.net/dd23708ebc4053551bb33e18b7174e73b6e1710b/dea24/static/images/wallpapers/shared-colors@2x.png',
  'https://d33wubrfki0l68.cloudfront.net/49de349d12db851952c5556f3c637ca772745316/cfc56/static/images/wallpapers/bridge-02@2x.png',
  'https://d33wubrfki0l68.cloudfront.net/594de66469079c21fc54c14db0591305a1198dd6/3f4b1/static/images/wallpapers/bridge-01@2x.png',
  'https://res.cloudinary.com/dn29xlaeh/image/upload/q_75,w_600,fl_lossy/beatgig-sandbox/chat/hmpschevbtbzjockgq6n',
  'https://raw.githubusercontent.com/michaelhenry/MHFacebookImageViewer/master/Example/Demo/Assets.xcassets/cat1.imageset/cat1.jpg',
  'https://d33wubrfki0l68.cloudfront.net/dd23708ebc4053551bb33e18b7174e73b6e1710b/dea24/static/images/wallpapers/shared-colors@2x.png',
  'https://d33wubrfki0l68.cloudfront.net/49de349d12db851952c5556f3c637ca772745316/cfc56/static/images/wallpapers/bridge-02@2x.png',
  'https://d33wubrfki0l68.cloudfront.net/594de66469079c21fc54c14db0591305a1198dd6/3f4b1/static/images/wallpapers/bridge-01@2x.png',
]

console.log('asset', image, nativeimage.resolveAssetSource(image).uri)

export default function App() {
  const renderItem = (url: string, i: number) => {
    return (
      <Galeria.Image id={url} index={i}>
        <Image
          style={{
            height: 245,
            width: 245,
            objectFit: 'cover',
          }}
          source={{ uri: url }}
          recyclingKey={url + i}
        />
      </Galeria.Image>
    )
  }

  return (
    <View style={{ flex: 1, backgroundColor: 'white' }}>
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

  return (
    <View
      style={{
        flex: 1,
        backgroundColor: 'black',
      }}
    >
      <Galeria urls={urls} theme="dark">
        <FlashList
          data={urls}
          renderItem={({ item: urls, index: i }) => {
            return renderItem(urls, i)
          }}
          estimatedItemSize={245}
          keyExtractor={(item, i) => item + i}
        />
        <Galeria.Popup />
      </Galeria>
    </View>
  )
}

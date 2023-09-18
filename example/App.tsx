import { StyleSheet, Text, View } from 'react-native'

import { Galeria } from 'galeria'

const urls = [
  'https://raw.githubusercontent.com/michaelhenry/MHFacebookImageViewer/master/Example/Demo/Assets.xcassets/cat1.imageset/cat1.jpg',
  'https://d33wubrfki0l68.cloudfront.net/dd23708ebc4053551bb33e18b7174e73b6e1710b/dea24/static/images/wallpapers/shared-colors@2x.png',
  'https://d33wubrfki0l68.cloudfront.net/49de349d12db851952c5556f3c637ca772745316/cfc56/static/images/wallpapers/bridge-02@2x.png',
  'https://d33wubrfki0l68.cloudfront.net/594de66469079c21fc54c14db0591305a1198dd6/3f4b1/static/images/wallpapers/bridge-01@2x.png',
]
export default function App() {
  return (
    <View style={styles.container}>
      {urls.map((url, i) => {
        return (
          <Galeria
            style={{
              width: 200 * 1.2,
              height: 130 * 1.2,
            }}
            key={url}
            initialIndex={i}
            src={url}
            urls={urls}
          />
        )
      })}
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'black',
    alignItems: 'center',
    justifyContent: 'center',
  },
})

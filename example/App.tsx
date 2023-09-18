import { StyleSheet, View } from 'react-native'

import { Galeria } from 'galeria'

const urls = [
  'https://raw.githubusercontent.com/michaelhenry/MHFacebookImageViewer/master/Example/Demo/Assets.xcassets/cat1.imageset/cat1.jpg',
  'https://d33wubrfki0l68.cloudfront.net/dd23708ebc4053551bb33e18b7174e73b6e1710b/dea24/static/images/wallpapers/shared-colors@2x.png',
  'https://d33wubrfki0l68.cloudfront.net/49de349d12db851952c5556f3c637ca772745316/cfc56/static/images/wallpapers/bridge-02@2x.png',
  'https://d33wubrfki0l68.cloudfront.net/594de66469079c21fc54c14db0591305a1198dd6/3f4b1/static/images/wallpapers/bridge-01@2x.png',
]
export default function App() {
  return (
    <View style={{ flex: 1, flexDirection: 'row', flexWrap: 'wrap' }}>
      <Galeria urls={urls}>
        {urls.map((url, i) => {
          return (
            <Galeria.Image
              style={{
                height: 200,
                width: 200,
                objectFit: 'cover',
              }}
              index={i}
              src={url}
            />
          )
        })}
        <Galeria.Popup disableTransition="web" />
      </Galeria>
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: 'black',
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
})

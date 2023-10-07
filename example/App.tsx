import { ScrollView, StyleSheet, View } from 'react-native'

import { Galeria } from 'galeria'

const urls = [
  'https://raw.githubusercontent.com/michaelhenry/MHFacebookImageViewer/master/Example/Demo/Assets.xcassets/cat1.imageset/cat1.jpg',
  'https://d33wubrfki0l68.cloudfront.net/dd23708ebc4053551bb33e18b7174e73b6e1710b/dea24/static/images/wallpapers/shared-colors@2x.png',
  'https://d33wubrfki0l68.cloudfront.net/49de349d12db851952c5556f3c637ca772745316/cfc56/static/images/wallpapers/bridge-02@2x.png',
  'https://d33wubrfki0l68.cloudfront.net/594de66469079c21fc54c14db0591305a1198dd6/3f4b1/static/images/wallpapers/bridge-01@2x.png',
]
export default function App() {
  return (
    <View
      style={{
        flex: 1,
        backgroundColor: 'black',
      }}
    >
      <ScrollView>
        <Galeria urls={urls} ids={urls} theme="dark">
          {urls.map((url, i) => {
            return (
              <Galeria.Image
                key={url}
                style={{
                  height: 245,
                  width: '100%',
                  objectFit: 'cover',
                }}
                id={url}
                index={i}
                src={url}
              />
            )
          })}
          <Galeria.Popup />
        </Galeria>

        {urls.map((url, i) => {
          return (
            <Galeria key={url} theme="light">
              <Galeria.Image
                style={{
                  height: 245,
                  width: '100%',
                  objectFit: 'cover',
                }}
                src={url}
              />
              <Galeria.Popup />
            </Galeria>
          )
        })}
      </ScrollView>
    </View>
  )
}

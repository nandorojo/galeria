import { useTheme } from '@react-navigation/native'
import { Image } from 'expo-image'
import { Galeria, type MediaSource } from 'galeria'
import { useState } from 'react'
import { Platform, ScrollView, Switch, Text, View } from 'react-native'

const items = [
  {
    label: 'Bundled video',
    media: { type: 'video', source: require('../assets/video.mp4') },
    poster: require('../assets/video-poster.jpg'),
  },
  {
    label: 'Photo',
    media: { type: 'photo', source: require('../assets/400_400.png') },
    poster: require('../assets/400_400.png'),
  },
  {
    label: 'HTTPS video',
    media: {
      type: 'video',
      source:
        'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4',
    },
    poster: require('../assets/flower-poster.jpg'),
  },
] as const

const media: MediaSource[] = items.map((item) => item.media)

export default function VideosScreen() {
  const [autoPlayVideo, setAutoPlayVideo] = useState(false)
  const { colors } = useTheme()

  return (
    <ScrollView contentContainerStyle={{ padding: 16, gap: 16 }}>
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12 }}>
        <Text style={{ color: colors.text }}>Autoplay videos</Text>
        <Switch
          accessibilityLabel="Autoplay videos"
          value={autoPlayVideo}
          onValueChange={setAutoPlayVideo}
        />
      </View>
      <Text style={{ color: colors.text }}>
        {Platform.OS === 'web'
          ? 'Open each item separately. Videos use browser playback controls.'
          : 'Open any item, then swipe between photos and videos.'}
      </Text>
      <Galeria urls={media} autoPlayVideo={autoPlayVideo}>
        {items.map((item, index) => (
          <View key={item.label} style={{ gap: 8 }}>
            <Text style={{ color: colors.text }}>{item.label}</Text>
            <Galeria.Item index={index}>
              <View style={{ height: 200 }}>
                <Image
                  source={item.poster}
                  style={{ width: '100%', height: '100%' }}
                />
                {item.media.type === 'video' && (
                  <View
                    pointerEvents="none"
                    style={{
                      position: 'absolute',
                      inset: 0,
                      alignItems: 'center',
                      justifyContent: 'center',
                    }}
                  >
                    <Text
                      style={{
                        color: 'white',
                        backgroundColor: '#0009',
                        borderRadius: 24,
                        padding: 12,
                        fontSize: 24,
                      }}
                    >
                      ▶
                    </Text>
                  </View>
                )}
              </View>
            </Galeria.Item>
          </View>
        ))}
      </Galeria>
    </ScrollView>
  )
}

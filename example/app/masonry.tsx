import { MasonryFlashList } from '@shopify/flash-list'
import { Galeria } from 'galeria'
import { forwardRef } from 'react'
import { Dimensions, Image, Platform, View } from 'react-native'

const images: {
  url: string
  width: number
  height: number
}[] = [
  {
    url: 'https://images.unsplash.com/photo-1561378137-e40d3723d0df?w=2000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8aWNlJTIwYmVyZ3xlbnwwfHwwfHx8MA%3D%3D',
    height: 239,
    width: 361,
  },
  {
    url: 'https://images.unsplash.com/photo-1562004736-6704d0518d24?w=2000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8aWNlJTIwYmVyZ3xlbnwwfHwwfHx8MA%3D%3D',
    height: 241,
    width: 361,
  },
  {
    url: 'https://images.unsplash.com/photo-1493855344473-0378f32bd0d4?w=2000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fGljZSUyMGJlcmd8ZW58MHx8MHx8fDA%3D',
    height: 241,
    width: 361,
  },
  {
    url: 'https://images.unsplash.com/photo-1543470388-80a8f5281639?w=2000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aWNlJTIwYmVyZ3xlbnwwfHwwfHx8MA%3D%3D',
    height: 542,
    width: 361,
  },
  {
    url: 'https://images.unsplash.com/photo-1584701782188-b44dc2815522?w=2000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fGljZSUyMGJlcmd8ZW58MHx8MHx8fDA%3D',
    height: 270,
    width: 361,
  },
  {
    url: 'https://images.unsplash.com/photo-1494564605686-2e931f77a8e2?w=2000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTR8fGljZSUyMGJlcmd8ZW58MHx8MHx8fDA%3D',
    height: 240,
    width: 361,
  },
  {
    url: 'https://images.unsplash.com/photo-1543470373-e055b73a8f29?w=2000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8aWNlJTIwYmVyZ3xlbnwwfHwwfHx8MA%3D%3D',
    height: 241,
    width: 361,
  },
  {
    url: 'https://images.unsplash.com/photo-1570667303213-409ddca8753c?w=2000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8aWNlJTIwYmVyZ3xlbnwwfHwwfHx8MA%3D%3D',
    height: 255,
    width: 361,
  },
  {
    url: 'https://plus.unsplash.com/premium_photo-1670288166585-49e08f37e624?w=2000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8aWNlJTIwYmVyZ3xlbnwwfHwwfHx8MA%3D%3D',
    height: 361,
    width: 361,
  },
  {
    url: 'https://plus.unsplash.com/premium_photo-1676573201475-f67a243acb74?w=2000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8aWNlJTIwYmVyZ3xlbnwwfHwwfHx8MA%3D%3D',
    height: 203,
    width: 361,
  },

  {
    url: 'https://images.unsplash.com/photo-1561378137-e40d3723d0df?w=2000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8aWNlJTIwYmVyZ3xlbnwwfHwwfHx8MA%3D%3D',
    height: 239,
    width: 361,
  },
  {
    url: 'https://images.unsplash.com/photo-1562004736-6704d0518d24?w=2000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8aWNlJTIwYmVyZ3xlbnwwfHwwfHx8MA%3D%3D',
    height: 241,
    width: 361,
  },
  {
    url: 'https://images.unsplash.com/photo-1493855344473-0378f32bd0d4?w=2000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fGljZSUyMGJlcmd8ZW58MHx8MHx8fDA%3D',
    height: 241,
    width: 361,
  },
  {
    url: 'https://images.unsplash.com/photo-1543470388-80a8f5281639?w=2000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aWNlJTIwYmVyZ3xlbnwwfHwwfHx8MA%3D%3D',
    height: 542,
    width: 361,
  },
  {
    url: 'https://images.unsplash.com/photo-1584701782188-b44dc2815522?w=2000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fGljZSUyMGJlcmd8ZW58MHx8MHx8fDA%3D',
    height: 270,
    width: 361,
  },
  {
    url: 'https://images.unsplash.com/photo-1494564605686-2e931f77a8e2?w=2000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTR8fGljZSUyMGJlcmd8ZW58MHx8MHx8fDA%3D',
    height: 240,
    width: 361,
  },
  {
    url: 'https://images.unsplash.com/photo-1543470373-e055b73a8f29?w=2000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8aWNlJTIwYmVyZ3xlbnwwfHwwfHx8MA%3D%3D',
    height: 241,
    width: 361,
  },
  {
    url: 'https://images.unsplash.com/photo-1570667303213-409ddca8753c?w=2000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8aWNlJTIwYmVyZ3xlbnwwfHwwfHx8MA%3D%3D',
    height: 255,
    width: 361,
  },
  {
    url: 'https://plus.unsplash.com/premium_photo-1670288166585-49e08f37e624?w=2000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8aWNlJTIwYmVyZ3xlbnwwfHwwfHx8MA%3D%3D',
    height: 361,
    width: 361,
  },
  {
    url: 'https://plus.unsplash.com/premium_photo-1676573201475-f67a243acb74?w=2000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8aWNlJTIwYmVyZ3xlbnwwfHwwfHx8MA%3D%3D',
    height: 203,
    width: 361,
  },
]

const CellRendererComponent = forwardRef<View, any>(
  ({ index, children }, ref) => {
    return (
      <View ref={ref} style={{ zIndex: 100 - index }} testID={`test-${index}`}>
        {children}
      </View>
    )
  },
)

export default function Masonry() {
  return (
    <Galeria urls={images.map((image) => image.url)} theme="dark">
      <MasonryFlashList
        data={images}
        contentContainerStyle={{ backgroundColor: 'black' }}
        CellRendererComponent={Platform.select({ web: CellRendererComponent })}
        renderItem={({ index, item }) => {
          const aspectRatio = item.width / item.height
          const width = Dimensions.get('window').width / 2
          const height = width / aspectRatio
          return (
            <Galeria.Image
              style={{
                height,
                width,
              }}
              index={index}
              isBlurOverlayVisible={false}
              isPageIndicatorsVisible={true}
            >
              <Image
                source={{ uri: item.url }}
                style={{ width: '100%', height: '100%' }}
              />
            </Galeria.Image>
          )
        }}
        numColumns={2}
        estimatedItemSize={200}
      />
    </Galeria>
  )
}

<img width="1728" alt="Screenshot 2024-05-23 at 1 02 03 PM" src="https://github.com/nandorojo/galeria/assets/13172299/d43f4d04-3510-47fa-8c1d-93cb01644d38">

# Galeria 📷

The React (Native) Image viewer. The API is simple, and it runs natively.



<video width="300" src="https://github.com/nandorojo/galeria/assets/13172299/5e915a75-bd40-410f-99fb-5df644ce96ad" ></video>



## Features

 - Shared element transitions
 - Pinch to zoom
 - Double tap to zoom
 - Pan to close
 - Multi-image support
 - Modal support
 - FlashList support
 - Clean API
 - Web support (alpha)
 - Remote URLs & local images

> Galeria is in beta...🚧 A true release is coming soon.

### One Image

```tsx
import { Galeria } from '@nandorojo/galeria'
import { Image } from 'react-native' // works with ANY image component!

const url = 'https://my-image.com/image.jpg'

export const SingleImage = ({ style }) => (
  <Galeria urls={[url]}>
    <Galeria.Image>
      <Image source={{ uri: url }} style={style} />
    </Galeria.Image>
  </Galeria>
)
```

### Multiple Images

Simply pass an array to `urls`.

```tsx
import { Galeria } from '@nandorojo/galeria'
import { Image } from 'react-native' // works with ANY image component!

import localImage from './assets/local-image.png'

const urls = ['https://my-image.com/image.jpg', localImage]

export const MutliImage = ({ style }) => (
  <Galeria urls={urls}>
    {urls.map((url, index) => (
       <Galeria.Image index={index} key={...}>
         <Image source={typeof url === 'string' ? { uri: url } : url} style={style} />
       </Galeria.Image>
     )}
  </Galeria>
)
```


### Dark Mode

```tsx
import { Galeria } from '@nandorojo/galeria'

export const DarkMode = () => (
  <Galeria urls={urls} theme='dark'>
    ...
  </Galeria>
)
```

### FlashList

```tsx
import { Galeria } from '@nandorojo/galeria'
import { Image, type ImageAssetSource } from 'react-native' // works with ANY image component!
import { FlashList } from "@shopify/flash-list"

import localImage from './assets/local-image.png'

const urls = ['https://my-image.com/image.jpg', localImage]

export const FlashListSupport = () => {
  return (
    <Galeria urls={urls}>
      <FlashList
        data={urls}
        renderItem={({ item, index }) => {
          // you should put this in a memoized component
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
  )
}

const src = (s) => (typeof s === 'string' ? { uri: s } : s) // 🤷‍♂️
```

## Credits

- Under the hood, Galeria uses native libraries on iOS and Android.
- On Web, Galeria uses Framer Motion.
- Thanks to [Michael Henry](https://github.com/michaelhenry/ImageViewer.swift) for the iOS Image Viewer
- Thanks to [iielse](https://github.com/iielse/imageviewer) for the Android Image Viewer

## License

This software is free to use for apps or libraries of any size. However, I ask that you don't re-sell it or represent it as yours. If you fork it and make it public, please give credit back to the original GitHub repository.

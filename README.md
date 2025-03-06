<img width="1728" alt="Screenshot 2024-05-23 at 1 02 03 PM" src="https://github.com/nandorojo/galeria/assets/13172299/d43f4d04-3510-47fa-8c1d-93cb01644d38">

# Galeria 📷

An image viewer for React (+ Native). **It works with any image component - bring your own image component!**

<!-- <video width="300" src="https://github.com/nandorojo/galeria/assets/13172299/5e915a75-bd40-410f-99fb-5df644ce96ad" ></video> -->


https://github.com/user-attachments/assets/5062e949-b205-4260-830c-38041cec26db


## Features

- Shared element transitions
- Pinch to zoom
- Double tap to zoom
- Pan to close
- Multi-image support
- React Native Modal support
- FlashList support
- Clean API
- Web support
- Remote URLs & local images
- Supports different images when collapsed and expanded
  - This lets you show smaller thumbnails with higher resolution expanded images
- Works with _any image component_
  - `<Image />` from `react-native`
  - `<SolitoImage />` from `solito/image`
  - `<Image />` from `next/image`
  - `<Image />` from `expo-image`
  - `<FastImage />` from `react-native-fast-image`
  - `<img />` on web
  - ...etc

For iOS and Android, the implementation uses Swift (`ImageViewer.swift`) and Kotlin (`imageviewer`) respectively – see [credits](#credits).

Web support is a simplified version of the native experience powered by Framer Motion. It currently supports a single image at a time.

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
  <Galeria urls={urls} theme="dark">
    ...
  </Galeria>
)
```

### FlashList

```tsx
import { Galeria } from '@nandorojo/galeria'
import { Image, type ImageAssetSource } from 'react-native' // works with ANY image component!
import { FlashList } from '@shopify/flash-list'

import localImage from './assets/local-image.png'

const urls = ['https://my-image.com/image.jpg', localImage]
const size = 100
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
                style={{ width: size, height: size }}
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

### Plain Web Support

Galeria does not use _any_ React Native code on the web. It is a pure React component library.

So you can even use `<img />` if you want to only use it on web.

```tsx
import { Galeria } from '@nandorojo/galeria'

const urls = ['https://my-image.com/image.jpg']

export const WebSupport = () => (
  <Galeria urls={urls}>
    <Galeria.Image>
      <img src={urls[0]} width={100} height={100} />
    </Galeria.Image>
  </Galeria>
)
```

### Solito Image

```tsx
import { SolitoImage } from 'solito/image'

const urls = ['https://my-image.com/image.jpg']

export const SolitoSupport = () => (
  <Galeria urls={urls}>
    <Galeria.Image>
      <SolitoImage src={urls[0]} />
    </Galeria.Image>
  </Galeria>
)
```

### Next.js Image

```tsx
import { Galeria } from '@nandorojo/galeria'
import Image from 'next/image'

const urls = ['https://my-image.com/image.jpg']

export const NextJS = () => (
  <Galeria urls={urls}>
    <Galeria.Image>
      <Image
        src={urls[0]}
        width={100}
        height={100}
        // edit these props for your use case
        unoptimized
      />
    </Galeria.Image>
  </Galeria>
)
```

### Expo Image

```tsx
import { Galeria } from '@nandorojo/galeria'
import { Image } from 'expo-image'

const urls = ['https://my-image.com/image.jpg']

export const ExpoImage = () => (
  <Galeria urls={urls}>
    <Galeria.Image>
      <Image src={urls[0]} style={{ width: 100, height: 100 }} />
    </Galeria.Image>
  </Galeria>
)
```

### React Native Fast Image

```tsx
import { Galeria } from '@nandorojo/galeria'
import FastImage from 'react-native-fast-image'

const urls = ['https://my-image.com/image.jpg']

export const FastImage = () => (
  <Galeria urls={urls}>
    <Galeria.Image>
      <FastImage
        source={{ uri: urls[0] }}
        style={{ width: 100, height: 100 }}
      />
    </Galeria.Image>
  </Galeria>
)
```

## Installation

```bash
yarn add @nandorojo/galeria

# or

npm i @nandorojo/galeria
```

### Next.js / Solito

Add `@nandorojo/galeria` to `transpilePackages` in your `next.config.js`.

```tsx
module.exports = {
  transpilePackages: ['@nandorojo/galeria'],
}
```

### Expo

Galeria uses native libraries on iOS and Android, so it does not work with Expo Go. You will need to use a dev client.

After installing it, rebuild your native code:

```bash
npx expo prebuild
npx expo run:ios # or npx expo run:android
```

## Credits

- Under the hood, Galeria uses native libraries on iOS and Android.
- On Web, Galeria uses Framer Motion.
- Thanks to [Michael Henry](https://github.com/michaelhenry/ImageViewer.swift) for the iOS Image Viewer
- Thanks to [iielse](https://github.com/iielse/imageviewer) for the Android Image Viewer
- Thanks to [Alan](https://github.com/alantoa) for building the Android integration.

## License

This software is free to use for apps or libraries of any size. However, I ask that you don't re-sell it or represent it as yours. If you fork it and make it public, please give credit back to the original GitHub repository.

Consider this the MIT license – just be considerate.

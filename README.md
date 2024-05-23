# Galeria 📷

The React (Native) Image viewer. The API is simple, and it runs natively.

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

> Galeria is in beta...🚧 A true release is coming soon.

## Remote Images

### One Image

```tsx
import { Galeria } from '@nandorojo/galeria'
import { Image } from 'react-native' // works with ANY image component!

export const SingleImage = ({ url, style }) => (
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

export const MutliImage = ({ urls, style }) => (
  <Galeria urls={urls}>
    <Galeria.Image>
      <Image source={{ uri: url }} style={style} />
    </Galeria.Image>
  </Galeria>
)
```

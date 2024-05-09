import { View, Image as Nativeimage, LogBox } from 'react-native'

import { Galeria } from 'galeria'
import { Image } from 'expo-image'
import { Link } from 'expo-router'
import { urls } from '../constants/Images'

export default function HomeScreen() {
  return (
    <View style={{ gap: 12, paddingVertical: 16, paddingHorizontal: 16 }}>
      <LinkItem href="/photos">Photos</LinkItem>
      <LinkItem href="/chat">Chat</LinkItem>
      <LinkItem href="/modal">Modal</LinkItem>

      <Galeria urls={urls} theme="dark">
        <Galeria.Image id={urls[0]} index={0}>
          <Image
            style={{
              height: 245,
              width: 245,
            }}
            source={{ uri: urls[0] }}
          />
        </Galeria.Image>
      </Galeria>
    </View>
  )
}

const LinkItem = ({
  href,
  children,
}: {
  href: string
  children: React.ReactNode
}) => {
  return (
    <View
      style={{
        paddingVertical: 8,
        paddingHorizontal: 12,
        borderBottomColor: '#eee',
        borderBottomWidth: 1,
      }}
    >
      <Link
        style={{
          fontSize: 16,
          fontWeight: '600',
        }}
        href={href}
      >
        {children}
      </Link>
    </View>
  )
}

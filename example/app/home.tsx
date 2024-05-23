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

      <Galeria theme="light" urls={urls}>
        {urls.map((uri, index) => (
          <Galeria.Image key={uri + index} index={index}>
            <Image
              style={{
                height: 245,
                width: 245,
              }}
              source={uri}
            />
          </Galeria.Image>
        ))}

        {/* <Galeria.Popup /> */}
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
          color: 'white',
        }}
        href={href}
      >
        {children}
      </Link>
    </View>
  )
}

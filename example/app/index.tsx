import { useTheme } from '@react-navigation/native'
import { Image } from 'expo-image'
import { Link } from 'expo-router'
import { Galeria } from 'galeria'
import { View } from 'react-native'
import { urls } from '../constants/Images'

export default function HomeScreen() {
  return (
    <View style={{ gap: 12, paddingVertical: 16, paddingHorizontal: 16 }}>
      <LinkItem href="/photos">Photos</LinkItem>
      <LinkItem href="/chat">Chat</LinkItem>
      <LinkItem href="/modal">Modal</LinkItem>
      <LinkItem href="/masonry">Masonry</LinkItem>

      <Galeria urls={urls} theme="light">
        <Galeria.Image id={urls[0]} index={0}>
          <Image
            style={{
              height: 245,
              width: 245,
              borderRadius: 20,
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
  const colorScheme = useTheme()
  return (
    <View
      style={{
        paddingVertical: 8,
        paddingHorizontal: 12,
        borderBottomColor: colorScheme.colors.border,
        borderBottomWidth: 1,
      }}
    >
      <Link
        style={{
          fontSize: 16,
          fontWeight: '600',
          color: colorScheme.colors.text,
        }}
        href={href}
      >
        {children}
      </Link>
    </View>
  )
}

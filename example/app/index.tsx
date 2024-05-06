import {
  ScrollView,
  StyleSheet,
  Text,
  View,
  Image as nativeimage,
} from 'react-native'
import { FlashList } from '@shopify/flash-list'
// import image from '../assets/favicon.png'

import { Galeria } from 'galeria'
import { Fragment } from 'react'
import { Image } from 'expo-image'
import { SafeAreaProvider, SafeAreaView } from 'react-native-safe-area-context'
import { StatusBar } from 'expo-status-bar'
import { Link } from 'expo-router'
import { urls } from '../constants/Images'

export default function HomeScreen() {
  return (
    <View style={{ gap: 12, paddingVertical: 16, paddingHorizontal: 16 }}>
      <LinkItem href="/photos">Photos</LinkItem>
      <LinkItem href="/chat">Chat</LinkItem>
      <LinkItem href="/modal">Modal</LinkItem>

      <Galeria urls={urls} theme="light">
        <Galeria.Image>
          <Image
            style={{
              height: 245,
              width: 245,
              objectFit: 'cover',
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

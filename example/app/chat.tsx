import { useHeaderHeight } from '@react-navigation/elements'
import { FlashList, ListRenderItem } from '@shopify/flash-list'
import { Galeria } from 'galeria'
import React from 'react'
import { Platform, StyleSheet, Text, TextInput, View } from 'react-native'
import Image from 'react-native-fast-image'
import { useSafeAreaInsets } from 'react-native-safe-area-context'
import { urls } from '../constants/Images'

const messages: MessageProps[] = [
  {
    text: 'Hello',
    url: urls[0],
  },
  {
    text: 'Hi',
    sender: true,
  },
  {
    text: 'How are you?',
  },
  {
    text: 'I am good',
    sender: true,
  },
  {
    text: 'How can I help you?',
    url: urls[1],
  },
  {
    text: 'I need help with my order',
    sender: true,
  },
  {
    text: 'Sure, I can help you with that',
    url: urls[2],
  },
  {
    text: 'Thank you',
    sender: true,
  },
  {
    text: 'You are welcome',
    url: urls[3],
  },
  {
    text: 'Goodbye',
    sender: true,
  },
  {
    text: 'Goodbye',
    url: urls[4],
  },
]
const reversedMessages = [...messages].reverse()

const images = messages.map((item) => item.url).filter(Boolean) as string[]
const reversedImages = reversedMessages
  .map((item) => item.url)
  .filter(Boolean) as string[]

type MessageProps = {
  text: string
  url?: string
  sender?: boolean
}

function Message({ text, url, sender }: MessageProps) {
  if (!!url) {
    const imageIndex = images.findIndex((item) => item === url)
    console.log('[imageIndex]', imageIndex, text)
  }

  return (
    <View
      style={[
        sender ? styles.senderContainer : styles.recipientContainer,
        styles.messageContainer,
      ]}
    >
      <Text style={sender ? styles.senderMessage : styles.recipientMessage}>
        {text}
      </Text>
      {!!url && (
        <Galeria.Image
          id={url}
          index={images.findIndex((item) => item === url)}
        >
          <Image
            style={{
              height: 245,
              width: 245,
              objectFit: 'cover',
            }}
            source={typeof url === 'string' ? { uri: url } : url}
          />
        </Galeria.Image>
      )}
    </View>
  )
}

const RenderItem: ListRenderItem<MessageProps> = ({ item, index }) => {
  return <Message key={index} {...item} />
}
export default function ChatScreen() {
  const { bottom } = useSafeAreaInsets()
  const height = useHeaderHeight()
  return (
    <Galeria urls={images} theme="dark">
      <View style={styles.container}>
        <FlashList
          inverted
          data={reversedMessages}
          renderItem={RenderItem}
          ListFooterComponent={
            <View
              style={{
                height: 12 + Platform.select({ ios: height, default: 0 }),
              }}
            />
          }
          estimatedItemSize={300}
        />
        <View style={{ paddingBottom: bottom, ...styles.inputBox }}>
          <TextInput
            style={styles.textInput}
            placeholder="Send a message"
            placeholderTextColor="#686F76"
          />
        </View>
      </View>
    </Galeria>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000',
  },
  senderContainer: {
    alignSelf: 'flex-end',
    backgroundColor: 'rgba(255,245,0,1.00)',
  },
  recipientContainer: {
    alignSelf: 'flex-start',
    backgroundColor: '#1F2024',
  },
  senderMessage: {
    color: '#000',
  },
  recipientMessage: {
    color: '#fff',
  },
  inputBox: {
    width: '100%',
    paddingTop: 12,
    paddingHorizontal: 12,
  },
  textInput: {
    height: 44,
    backgroundColor: '#2A2D30',
    borderRadius: 20,
    color: '#fff',
    paddingHorizontal: 20,
    fontSize: 16,
  },
  messageContainer: {
    gap: 12,
    borderRadius: 12,
    paddingHorizontal: 12,
    paddingVertical: 16,
    margin: 10,
    marginVertical: 5,
  },
})

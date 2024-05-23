import {
  DarkTheme,
  DefaultTheme,
  ThemeProvider,
} from '@react-navigation/native'

import { Stack } from 'expo-router'
import { Platform } from 'react-native'

export {
  // Catch any errors thrown by the Layout component.
  ErrorBoundary,
} from 'expo-router'

export const unstable_settings = {
  initialRouteName: 'index',
}

export default function RootLayoutNav() {
  const colorScheme = 'dark'

  return (
    <ThemeProvider value={colorScheme === 'dark' ? DarkTheme : DefaultTheme}>
      <Stack
        screenOptions={{
          gestureEnabled: true,
        }}
      >
        <Stack.Screen name="index" options={{ title: 'Photos' }} />
        <Stack.Screen name="home" options={{ title: 'Example' }} />
        <Stack.Screen
          name="chat"
          options={{
            title: 'Chat',
            ...Platform.select({
              ios: {
                headerTransparent: true,
                headerBlurEffect: 'dark',
                headerTitleStyle: {
                  color: '#fff',
                },
                statusBarStyle: 'inverted',
              },
            }),
          }}
        />
        <Stack.Screen name="modal" options={{ presentation: 'modal' }} />
      </Stack>
    </ThemeProvider>
  )
}

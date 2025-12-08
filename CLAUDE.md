# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Galeria is a cross-platform image viewer for React and React Native. It uses native implementations (Swift/Kotlin) on iOS/Android and Framer Motion on web. The key philosophy is "BYOIC" (Bring Your Own Image Component) - it wraps any image component to add full-screen viewing capabilities.

## Build Commands

```bash
# Build the library
yarn build

# Clean build artifacts
yarn clean

# Lint
yarn lint

# Run tests
yarn test

# Open native projects in IDE
yarn open:ios     # Opens Xcode
yarn open:android # Opens Android Studio
```

## Example App

The example app is in `example/` and uses Expo Router:

```bash
cd example
yarn install
yarn ios      # expo run:ios
yarn android  # expo run:android
yarn web      # expo start --web
```

## Architecture

### Platform-Specific Files
- `src/GaleriaView.tsx` - Web implementation using Framer Motion
- `src/GaleriaView.ios.tsx` - iOS bridge using expo's `requireNativeView`
- `src/GaleriaView.android.tsx` - Android bridge with edge-to-edge support

### Native Code
- `ios/GaleriaView.swift` - iOS view that wraps UIImageView and attaches gesture handlers
- `ios/ImageViewer.swift/` - Swift ImageViewer library (forked from michaelhenry/ImageViewer.swift)
- `android/src/main/java/nandorojo/modules/galeria/GaleriaView.kt` - Android view using iielse/imageviewer

### Component Structure
The library exports a compound component pattern:
- `<Galeria urls={[...]}>` - Root provider with image URLs and theme
- `<Galeria.Image index={n}>` - Wrapper for individual images
- `<Galeria.Popup>` - Optional popup component (no-op on native)

### Context
`src/context.tsx` defines `GaleriaContext` which passes:
- `urls` - Array of image sources
- `theme` - 'dark' | 'light'
- `closeIconName` - SF Symbol name (iOS only)
- State for modal open/close

### Key Patterns
- Native views are registered via `expo-module.config.json` pointing to `GaleriaModule` classes
- URL resolution handles both remote URLs and local assets via `Image.resolveAssetSource`
- Edge-to-edge display on Android is detected via `react-native-is-edge-to-edge`

## Code Style

Uses Prettier with single quotes and no semicolons (configured in package.json).

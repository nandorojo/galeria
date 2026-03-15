# Testing — Video Support in @nandorojo/galeria

## 1. Basic usage (no breaking changes)

Make sure existing image-only galleries still work exactly as before — no `mediaTypes` prop.

```tsx
<Galeria urls={['https://example.com/photo1.jpg', 'https://example.com/photo2.jpg']}>
  <Galeria.Image index={0}>
    <Image source={{ uri: 'https://example.com/photo1.jpg' }} style={{ width: 200, height: 200 }} />
  </Galeria.Image>
</Galeria>
```

**Expected:** Images open fullscreen with swipe paging, shared element transition, close button. Identical behaviour to the pre-video release.

---

## 2. Mixed photos + videos

```tsx
const urls = [
  'https://example.com/photo1.jpg',
  'https://example.com/clip.mp4',
  'https://example.com/photo2.jpg',
]
const mediaTypes = ['image', 'video', 'image']

<Galeria urls={urls} mediaTypes={mediaTypes}>
  <Galeria.Image index={0}>
    <Image source={{ uri: urls[0] }} style={{ width: 200, height: 200 }} />
  </Galeria.Image>
</Galeria>
```

**Expected:**
- Page 0 → photo, pan-to-zoom works
- Page 1 → video auto-plays with native controls (scrubber, play/pause)
- Page 2 → photo again
- Swiping from photo→video: video **auto-plays** on arrive
- Swiping from video→photo: video **pauses**
- Swiping back to video: video **resumes / replays**

---

## 3. All-video gallery

```tsx
const urls = [
  'https://example.com/clip1.mp4',
  'https://example.com/clip2.mp4',
]
const mediaTypes = ['video', 'video']

<Galeria urls={urls} mediaTypes={mediaTypes}>
  <Galeria.Image index={0}>
    <Image source={{ uri: urls[0] }} style={{ width: 200, height: 200 }} />
  </Galeria.Image>
</Galeria>
```

**Expected:** Both pages play video. Only one video plays at a time.

---

## 4. Shared element transition (video thumbnail)

The thumbnail `UIImageView` / `ImageView` that the video page displays before playback starts should be used for the push/pop shared-element transition — same as a regular photo.

**Expected:** Tapping a thumbnail transitions smoothly into fullscreen; closing the viewer transitions back to the thumbnail position.

---

## 5. Pan-to-dismiss with video

While a video is fullscreen (page 1), pan downward to dismiss.

**Expected:** The dismiss gesture works (no zoom-scale check blocks it). The viewer closes with the reverse shared-element transition.

---

## 6. iOS-specific checks

- AVPlayerViewController native controls (scrubber, AirPlay button, PiP) are visible.
- Swiping away from a video page pauses the `AVPlayer`.
- Looping: video loops after reaching the end.

## 7. Android-specific checks

- `MediaController` controls (play/pause, seek bar) show on tap.
- First-frame thumbnail is rendered before playback starts.
- Swiping away pauses the `VideoView`.

---

## Build

### iOS
```sh
cd ios && pod install
npx expo run:ios
```

### Android
```sh
npx expo run:android
```

---

## Known limitations / future work

- Android thumbnail uses Glide's `.frame(0L)` which requires `glide-video` or Glide >= 4.x with video support; if it fails the thumbnail will be blank (video still plays fine).
- No custom seek bar on Android — relies on the built-in `MediaController`.
- ExoPlayer support (better buffering, HLS, DRM) can be added later by swapping `VideoView` for an `ExoPlayer`-backed `PlayerView` in `GaleriaView.kt`.

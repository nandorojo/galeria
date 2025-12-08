# Plan: Replace ImageViewer Transition with MatchTransition

## Current Architecture

The existing ImageViewer uses UIKit's standard modal presentation with custom transitioning:

```
UIImageView (tap)
  → ImageCarouselViewController (UIPageViewController)
    → ImageViewerController (per-page, handles zoom/pan)
    → ImageViewerTransitionPresentationManager (UIViewControllerTransitioningDelegate)
      → ImageViewerTransitionPresentationAnimator (UIViewControllerAnimatedTransitioning)
```

**Key files:**
- `ImageViewerTransitionPresentationManager.swift` - Custom modal transition using `UIViewControllerAnimatedTransitioning`
- `ImageCarouselViewController.swift` - Conforms to `ImageViewerTransitionViewControllerConvertible`
- `ImageViewerController.swift` - Individual page with pan-to-dismiss gesture
- `UIImageView_Extensions.swift` - Entry point that presents the modal

**Current transition flow:**
1. Creates dummy `UIImageView` snapshot
2. Animates frame from source → fullscreen (present) or fullscreen → source (dismiss)
3. Uses `UIView.animate` with 0.3s duration
4. Pan gesture in `ImageViewerController` moves `imageView.center`, dismisses if `diffY > 60`

---

## Target Architecture

Replace the UIKit modal presentation with DynamicTransition's `NavigationView` + `MatchTransition`:

```
GaleriaView (tap on UIImageView)
  → NavigationController/NavigationView
    → ImageViewerRootView (new: the full-screen viewer)
      → MatchTransition (handles present/dismiss animation)
```

---

## Implementation Steps

### Step 1: Create `ImageViewerRootView`

Create a new UIView subclass that replaces `ImageCarouselViewController` + `ImageViewerController`:

**File:** `ios/ImageViewer.swift/ImageViewerRootView.swift`

```swift
class ImageViewerRootView: UIView, RootViewType {
    let transition = MatchTransition()

    // Data
    var imageItems: [ImageItem] = []
    var initialIndex: Int = 0
    var currentIndex: Int = 0
    var theme: ImageViewerTheme = .dark
    var imageLoader: ImageLoader
    var onIndexChange: ((Int) -> Void)?
    var onDismiss: (() -> Void)?

    // Views
    private let scrollView: UIScrollView  // For paging between images
    private let imageView: UIImageView    // Current displayed image
    private let backgroundView: UIView
    private let navBar: UINavigationBar

    // Lifecycle (RootViewType)
    func willAppear(animated: Bool) { ... }
    func didAppear(animated: Bool) { ... }
    func willDisappear(animated: Bool) { ... }
    func didDisappear(animated: Bool) { ... }

    var preferredStatusBarStyle: UIStatusBarStyle {
        theme == .dark ? .lightContent : .default
    }
}
```

**Key changes from current:**
- UIView instead of UIViewController
- Owns its own `MatchTransition` instance
- Conforms to `RootViewType` for lifecycle callbacks
- Implements `TransitionProvider` and `MatchTransitionDelegate`

---

### Step 2: Implement `TransitionProvider` Protocol

```swift
extension ImageViewerRootView: TransitionProvider {
    func transitionFor(presenting: Bool, otherView: UIView) -> Transition? {
        return transition
    }
}
```

This tells `NavigationView` to use our `MatchTransition` for all transitions.

---

### Step 3: Implement `MatchTransitionDelegate` Protocol

```swift
extension ImageViewerRootView: MatchTransitionDelegate {
    func matchedViewFor(transition: MatchTransition, otherView: UIView) -> UIView? {
        // When this is the foreground (detail view), return the current imageView
        if transition.context?.foreground == self {
            return imageView
        }
        return nil
    }

    func matchTransitionWillBegin(transition: MatchTransition) {
        // Optional: animate nav bar, background, etc.
    }
}
```

---

### Step 4: Update `GaleriaView` to Use NavigationView

**File:** `ios/GaleriaView.swift`

Instead of presenting `ImageCarouselViewController` modally, we need to:

1. Create a `NavigationView` or `NavigationController` as the container
2. Push `ImageViewerRootView` onto it when tapped
3. Make `GaleriaView` conform to `MatchTransitionDelegate` to provide the source `UIImageView`

```swift
class GaleriaView: ExpoView, MatchTransitionDelegate {
    private var navigationView: NavigationView?

    // Called on tap
    func showImageViewer() {
        let viewerView = ImageViewerRootView(
            imageItems: /* from urls */,
            initialIndex: initialIndex ?? 0,
            theme: theme,
            imageLoader: /* loader */
        )

        // Get or create navigation context
        if let navView = self.navigationView {
            navView.pushView(viewerView, animated: true)
        } else {
            // Create navigation view with root and present
            // ...
        }
    }

    // MatchTransitionDelegate
    func matchedViewFor(transition: MatchTransition, otherView: UIView) -> UIView? {
        // Return the source UIImageView that was tapped
        return childImageView
    }

    func matchTransitionWillBegin(transition: MatchTransition) {
        // Hide source image during transition
    }
}
```

---

### Step 5: Wire Up Dismiss Gestures

In `ImageViewerRootView.viewDidLoad()` equivalent:

```swift
func setupGestures() {
    // Vertical pan to dismiss
    addGestureRecognizer(transition.verticalDismissGestureRecognizer)

    // Horizontal pan to dismiss (optional, for edge swipe)
    addGestureRecognizer(transition.horizontalDismissGestureRecognizer)

    // Tap to toggle nav bar (existing behavior)
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
}

@objc func didTap() {
    // Toggle nav bar visibility OR dismiss
    navigationView?.popView(animated: true)
}
```

---

### Step 6: Handle Multi-Image Paging

The current `ImageCarouselViewController` uses `UIPageViewController`. We have options:

**Option A: Embed UIPageViewController inside ImageViewerRootView**
- Keep the paging logic mostly intact
- Just replace the transition/presentation layer

**Option B: Use horizontal UIScrollView with paging**
- Simpler, no UIViewController involvement
- Handle page changes via `scrollViewDidEndDecelerating`

**Recommendation:** Option A initially (less code change), then refactor to Option B later.

---

### Step 7: Presentation Strategy

**Challenge:** The current flow presents modally from any view controller. With `NavigationView`, we need a container.

**Options:**

**Option A: Overlay NavigationView**
- Create `NavigationView` dynamically and add it to the window
- Push `ImageViewerRootView` onto it
- Remove `NavigationView` when stack is empty

**Option B: Use existing React Native modal**
- Keep React Native's modal presentation
- Use MatchTransition just for the shared element animation within

**Recommendation:** Option A for full native control and fluid gestures.

```swift
// In UIImageView_Extensions.swift or GaleriaView
func showImageViewer() {
    guard let window = self.window else { return }

    // Create navigation view with empty root or transparent placeholder
    let placeholderRoot = UIView()
    placeholderRoot.backgroundColor = .clear

    let navView = NavigationView(rootView: placeholderRoot)
    navView.frame = window.bounds
    window.addSubview(navView)

    // Create and push the image viewer
    let viewerView = ImageViewerRootView(...)
    navView.pushView(viewerView, animated: true)

    // Store reference for dismissal
    viewerView.onDismiss = {
        navView.removeFromSuperview()
    }
}
```

---

### Step 8: Delete Deprecated Files

Once migration is complete, remove:
- `ImageViewerTransitionPresentationManager.swift` (entire file)
- `ImageViewerTransitionViewControllerConvertible` protocol
- Pan gesture handling in `ImageViewerController.swift` (replaced by MatchTransition)

---

## Files to Modify

| File | Changes |
|------|---------|
| `ios/ImageViewer.swift/ImageViewerRootView.swift` | **NEW** - Main viewer view |
| `ios/GaleriaView.swift` | Add `MatchTransitionDelegate`, change presentation |
| `ios/ImageViewer.swift/UIImageView_Extensions.swift` | Update `showImageViewer` to use NavigationView |
| `ios/ImageViewer.swift/ImageCarouselViewController.swift` | Remove transition delegate code, possibly deprecate |
| `ios/ImageViewer.swift/ImageViewerController.swift` | Remove pan-to-dismiss gesture (handled by MatchTransition) |
| `ios/ImageViewer.swift/ImageViewerTransitionPresentationManager.swift` | **DELETE** |

---

## Migration Checklist

- [ ] Create `ImageViewerRootView` conforming to `RootViewType`
- [ ] Implement `TransitionProvider` on `ImageViewerRootView`
- [ ] Implement `MatchTransitionDelegate` on `ImageViewerRootView` (foreground)
- [ ] Implement `MatchTransitionDelegate` on `GaleriaView` (background/source)
- [ ] Update tap handler to use `NavigationView.pushView()`
- [ ] Wire up `verticalDismissGestureRecognizer` and `horizontalDismissGestureRecognizer`
- [ ] Handle multi-image paging (keep UIPageViewController or replace with UIScrollView)
- [ ] Test pinch-to-zoom interaction with dismiss gesture
- [ ] Test with different image aspect ratios
- [ ] Test theme (dark/light) backgrounds
- [ ] Delete `ImageViewerTransitionPresentationManager.swift`
- [ ] Update `onIndexChange` callback to work with new architecture

---

## Open Questions

1. **Zoom + Dismiss interaction:** Current code disables pan-to-dismiss when zoomed (`scrollView.zoomScale != minimumZoomScale`). Need to ensure MatchTransition gesture recognizers respect this.

2. **React Native integration:** Does `NavigationView` need to be added to a specific view in the RN hierarchy, or can it overlay the window?

3. **Carousel paging:** Keep `UIPageViewController` initially or migrate to `UIScrollView` with paging?

4. **Safe area handling:** `MatchTransition` uses `lockedSafeAreaInsets` - verify this works with Galeria's edge-to-edge support.

const { withAppDelegate, withInfoPlist } = require('expo/config-plugins')

// Apps built with the iOS 27 SDK must adopt the UIScene life cycle, otherwise
// UIKit aborts at launch. Expo's AppDelegate template doesn't do this yet, so
// this plugin moves window + React Native setup into a SceneDelegate.

const START_REACT_NATIVE = `#if os(iOS) || os(tvOS)
    window = UIWindow(frame: UIScreen.main.bounds)
    factory.startReactNative(
      withModuleName: "main",
      in: window,
      launchOptions: launchOptions)
#endif
`

const SCENE_DELEGATE = `
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene,
          let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }

    let window = UIWindow(windowScene: windowScene)
    self.window = window
    appDelegate.window = window

    appDelegate.reactNativeFactory?.startReactNative(
      withModuleName: "main",
      in: window,
      launchOptions: nil)

    // Deep links that launched the app arrive here instead of launchOptions.
    if let url = connectionOptions.urlContexts.first?.url {
      _ = appDelegate.application(UIApplication.shared, open: url)
    }
    if let userActivity = connectionOptions.userActivities.first {
      _ = appDelegate.application(UIApplication.shared, continue: userActivity) { _ in }
    }
  }

  // Linking API
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    for context in URLContexts {
      _ = appDelegate.application(UIApplication.shared, open: context.url)
    }
  }

  // Universal Links
  func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    _ = appDelegate.application(UIApplication.shared, continue: userActivity) { _ in }
  }
}
`

function addSceneDelegate(contents) {
  if (contents.includes('class SceneDelegate')) return contents
  if (!contents.includes(START_REACT_NATIVE)) {
    throw new Error(
      'withSceneDelegate: AppDelegate.swift does not match the expected Expo template'
    )
  }
  return (
    contents.replace(
      START_REACT_NATIVE,
      '    // The window and React Native root are created in SceneDelegate.\n'
    ) + SCENE_DELEGATE
  )
}

module.exports = function withSceneDelegate(config) {
  config = withAppDelegate(config, (config) => {
    if (config.modResults.language !== 'swift') {
      throw new Error('withSceneDelegate: only Swift AppDelegates are supported')
    }
    config.modResults.contents = addSceneDelegate(config.modResults.contents)
    return config
  })

  return withInfoPlist(config, (config) => {
    config.modResults.UIApplicationSceneManifest = {
      UIApplicationSupportsMultipleScenes: false,
      UISceneConfigurations: {
        UIWindowSceneSessionRoleApplication: [
          {
            UISceneConfigurationName: 'Default Configuration',
            UISceneDelegateClassName: '$(PRODUCT_MODULE_NAME).SceneDelegate',
          },
        ],
      },
    }
    return config
  })
}

module.exports.addSceneDelegate = addSceneDelegate

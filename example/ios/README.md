# iOS Setup

## Info.plist

`Runner/Info.plist` includes the required usage descriptions for:

- **NSAppleMusicUsageDescription** – Music library access (used by `permission_handler` for `Permission.mediaLibrary`).
- **NSMediaLibraryUsageDescription** – Media library access for audio metadata.

## permission_handler (Media Library)

This example requests `Permission.mediaLibrary` on iOS. For that to work, the **Podfile** must enable the media library permission in the native build.

After the first `flutter build ios` or `flutter run` (which creates `ios/Podfile`), add the following inside the **existing** `post_install` block in `ios/Podfile` (inside the loop over `target.build_configurations`):

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      # Enable media library permission for permission_handler
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_MEDIA_LIBRARY=1',
      ]
    end
  end
end
```

If your Podfile already has a `post_install` block, only add the `config.build_settings['GCC_PREPROCESSOR_DEFINITIONS']` part inside the inner loop (so you don’t duplicate `flutter_additional_ios_build_settings`).

Then run:

```bash
cd ios && pod install && cd ..
```

## AppDelegate

`Runner/AppDelegate.swift` registers plugins with `GeneratedPluginRegistrant.register(with: self)` so the music_feature_analyzer plugin and others are registered automatically.

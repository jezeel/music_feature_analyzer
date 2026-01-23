# Build Compatibility Guide

This document explains how `music_feature_analyzer` works in different usage scenarios.

## ✅ Published Package (pub.dev) - `music_feature_analyzer: ^1.0.1-beta-06`

> ⚠️ **Beta Version**: This is a beta release and may have issues. Not recommended for production use.

When using the published package from pub.dev, **everything works automatically**:

### Setup Steps:

1. **Add to `pubspec.yaml`:**
   ```yaml
   dependencies:
     music_feature_analyzer: ^1.0.1-beta-06
   ```

2. **Run:**
   ```bash
   flutter pub get
   flutter clean
   flutter pub get
   ```

3. **That's it!** The plugin:
   - ✅ Automatically registers via Flutter's plugin system
   - ✅ Flutter's build system provides all required dependencies
   - ✅ No manual MainActivity changes needed
   - ✅ No manual Gradle configuration needed

### How It Works:

- Flutter's plugin build system (`flutter pub get`) automatically:
  - Generates `GeneratedPluginRegistrant.java` with plugin registration
  - Provides Flutter embedding classes (FlutterPlugin, MethodChannel, etc.)
  - Configures Gradle dependencies automatically
  - Handles all native code integration

### Verification:

After `flutter pub get`, check that your app's `GeneratedPluginRegistrant.java` includes:
```java
flutterEngine.getPlugins().add(new com.music_feature_analyzer.MusicFeatureAnalyzerPlugin());
```

---

## 🔧 Local Path Dependency (Development/Example)

> ⚠️ **Important**: Automatic plugin registration only works for packages installed from pub.dev. For local path dependencies, manual registration is required.

When using the package as a local path dependency (like in the example app), additional setup is required:

### Setup Steps:

1. **Add to `pubspec.yaml`:**
   ```yaml
   dependencies:
     music_feature_analyzer:
       path: ../path/to/music_feature_analyzer
   ```

2. **Update `android/settings.gradle.kts`:**
   ```kotlin
   include(":music_feature_analyzer")
   project(":music_feature_analyzer").projectDir = File("../../android")
   ```

3. **Update `android/app/build.gradle.kts`:**
   ```kotlin
   dependencies {
       implementation(project(":music_feature_analyzer"))
   }
   ```

4. **Manually register in `MainActivity.kt`:**
   ```kotlin
   import com.music_feature_analyzer.MusicFeatureAnalyzerPlugin
   
   override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
       super.configureFlutterEngine(flutterEngine)
       flutterEngine.plugins.add(MusicFeatureAnalyzerPlugin())
   }
   ```

5. **Ensure `local.properties` has Flutter SDK path:**
   ```properties
   flutter.sdk=C:/path/to/flutter
   ```

### How It Works:

- The plugin's `build.gradle` automatically finds the Flutter SDK and adds Flutter embedding JAR as a dependency
- Manual registration ensures the plugin works even if Flutter's auto-discovery doesn't find it
- The plugin project is included as a Gradle subproject

---

## 📋 Build Configuration Details

### For Published Packages:

The plugin's `android/build.gradle` is designed to work seamlessly with Flutter's build system:

- **Flutter embedding dependency**: Automatically provided by Flutter's Gradle plugin
- **Plugin registration**: Handled by `GeneratedPluginRegistrant.java`
- **No manual configuration needed**: Flutter handles everything

### For Local Path Dependencies:

The plugin's `android/build.gradle` includes fallback logic:

- **Flutter SDK detection**: Reads `local.properties` to find Flutter SDK path
- **JAR resolution**: Automatically finds `flutter.jar` in Flutter SDK artifacts
- **Compile-time dependency**: Adds Flutter embedding as `compileOnly` dependency
- **Graceful fallback**: If JAR not found, assumes Flutter's build system will provide it

---

## 🧪 Testing Both Scenarios

### Test Published Package:

1. Create a new Flutter project
2. Add `music_feature_analyzer: ^1.0.1` to `pubspec.yaml`
3. Run `flutter pub get`
4. Use the package - it should work without any manual setup

### Test Local Path:

1. Use the included `example/` app
2. It's already configured for local path dependency
3. Run `flutter run` from the `example/` directory
4. The plugin should work with manual registration

---

## ⚠️ Troubleshooting

### Issue: "Unresolved reference: FlutterPlugin"

**For Published Packages:**
- Run `flutter clean` and `flutter pub get`
- Ensure you're using Flutter's build system (not building Android directly)

**For Local Path:**
- Check that `local.properties` has correct `flutter.sdk` path
- Verify Flutter SDK has `flutter.jar` in artifacts directory
- Try rebuilding: `flutter clean && flutter pub get`

### Issue: "MissingPluginException"

**For Published Packages:**
- Check `GeneratedPluginRegistrant.java` includes the plugin
- Run `flutter clean` and `flutter pub get` again

**For Local Path:**
- Ensure manual registration in `MainActivity.kt`
- Verify plugin project is included in `settings.gradle.kts`
- Check plugin dependency in `app/build.gradle.kts`

---

## 📝 Summary

| Scenario | Plugin Registration | Flutter Dependencies | Gradle Config |
|----------|-------------------|---------------------|---------------|
| **Published (pub.dev)** | ✅ Automatic | ✅ Automatic | ✅ Automatic |
| **Local Path** | ⚙️ Manual (MainActivity) | ⚙️ Auto-detected (build.gradle) | ⚙️ Manual (settings.gradle) |

**Key Point**: The package is designed to work seamlessly when published. Local path dependencies require additional setup, which is normal for Flutter plugin development.

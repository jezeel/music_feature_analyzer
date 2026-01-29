# Build compatibility

## Use from pub.dev (recommended)

Add the package from **pub.dev** in your `pubspec.yaml`:

```yaml
dependencies:
  music_feature_analyzer: ^1.0.1
```

Then run:

```bash
flutter pub get
```

No extra setup is needed. The plugin registers automatically.

---

## Use from Git (testing only)

For **testing or development only**, you can depend on the **main** branch from Git:

```yaml
dependencies:
  music_feature_analyzer:
    git:
      url: https://github.com/jezeel/music_feature_analyzer.git
      ref: main
```

> **Note:** This is only for trying unreleased changes. Prefer **pub.dev** (`music_feature_analyzer: ^1.0.1`) for normal use.

After pulling package updates from Git, run `flutter pub get` (or `flutter clean` then `flutter pub get`) so your app picks up the latest code.

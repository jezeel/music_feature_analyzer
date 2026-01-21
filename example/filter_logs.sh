#!/bin/bash

# Clear ADB logs
echo "Clearing ADB logs..."
adb logcat -c

echo "Starting filtered log monitoring..."
echo "Filtering for: flutter, music_feature_analyzer, HomeScreen, Main, Feature, Metadata"
echo "Excluding: SurfaceControl, ViewRootImpl, InputMethodManager, etc."
echo "Press Ctrl+C to stop"
echo ""

# Filter logs - only show flutter and app-specific logs
adb logcat | grep -E "flutter|music_feature_analyzer|HomeScreen|Main|Feature|Metadata|Extract|Analyze" | grep -vE "SurfaceControl|ViewRootImpl|InputMethodManager|InputTransport|Choreographer|SurfaceView|libEGL|ffmpeg-kit-flutter.*selectDocument|FFmpegKitFlutterPlugin.*ignored|MSG_WINDOW_FOCUS_CHANGED|Relayout returned|stopped\(|stopped\)|onWindowVisibilityChanged|surfaceCreated|surfaceDestroyed|surfaceChanged|nativeRelease"

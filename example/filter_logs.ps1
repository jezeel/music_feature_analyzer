# Clear ADB logs
Write-Host "Clearing ADB logs..." -ForegroundColor Yellow
adb logcat -c

Write-Host "Starting filtered log monitoring..." -ForegroundColor Green
Write-Host "Filtering for: flutter, music_feature_analyzer, HomeScreen, Main, Feature, Metadata" -ForegroundColor Cyan
Write-Host "Excluding: SurfaceControl, ViewRootImpl, InputMethodManager, etc." -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host ""

# Filter logs - only show flutter and app-specific logs
adb logcat | Select-String -Pattern "flutter|music_feature_analyzer|HomeScreen|Main|Feature|Metadata|Extract|Analyze" | Where-Object { 
    $line = $_.Line
    # Exclude unwanted system logs
    $line -notmatch "SurfaceControl" -and
    $line -notmatch "ViewRootImpl" -and
    $line -notmatch "InputMethodManager" -and
    $line -notmatch "InputTransport" -and
    $line -notmatch "Choreographer" -and
    $line -notmatch "SurfaceView" -and
    $line -notmatch "libEGL" -and
    $line -notmatch "ffmpeg-kit-flutter.*selectDocument" -and
    $line -notmatch "FFmpegKitFlutterPlugin.*ignored" -and
    $line -notmatch "MSG_WINDOW_FOCUS_CHANGED" -and
    $line -notmatch "Relayout returned" -and
    $line -notmatch "stopped\(|stopped\)" -and
    $line -notmatch "onWindowVisibilityChanged" -and
    $line -notmatch "surfaceCreated|surfaceDestroyed|surfaceChanged" -and
    $line -notmatch "nativeRelease"
}

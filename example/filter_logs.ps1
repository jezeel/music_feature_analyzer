# ADB Log Filter for Music Feature Analyzer Example App
# Shows only relevant app and plugin logs

param(
    [switch]$Clear = $true
)

$packageName = "com.example.music_feature_analyzer_example"

# Clear ADB logs if requested
if ($Clear) {
    Write-Host "Clearing ADB logs..." -ForegroundColor Yellow
    adb logcat -c
    Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "Starting filtered log monitoring for: $packageName" -ForegroundColor Green
Write-Host "Filtering for: MainActivity, MusicFeatureAnalyzer, Flutter logs, music_feature_analyzer" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host ""

# Filter logs using adb logcat with tag filters
adb logcat -s MainActivity:V MusicFeatureAnalyzer:V flutter:V | Where-Object {
    $line = $_.Line
    
    # Include our package
    if ($line -match $packageName) { return $true }
    
    # Include MainActivity logs
    if ($line -match "MainActivity") { return $true }
    
    # Include MusicFeatureAnalyzer plugin logs
    if ($line -match "MusicFeatureAnalyzer") { return $true }
    
    # Include Flutter/Dart logs
    if ($line -match "flutter.*\(.*\):" -or $line -match "I/flutter") { return $true }
    
    # Include music_feature_analyzer package logs
    if ($line -match "music_feature_analyzer") { return $true }
    
    # Exclude system noise
    if ($line -match "SurfaceControl|ViewRootImpl|InputMethodManager|Choreographer|SurfaceView|nativeRelease|ProfileInstaller|PhoneWindow") {
        return $false
    }
    
    return $true
}

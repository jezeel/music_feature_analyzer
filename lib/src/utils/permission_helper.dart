import 'dart:io';
import '../utils/app_logger.dart';

/// Comprehensive permission helper that handles all Android versions and iOS edge cases
/// Automatically detects platform and SDK version to provide correct permission handling
/// 
/// **Note:** This package does not include `permission_handler` as a dependency
/// to keep the package lightweight. Users should add it to their app's pubspec.yaml
/// and use the provided code examples.
class PermissionHelper {
  static final _logger = AppLogger('PermissionHelper');

  /// Get comprehensive permission request instructions for the current platform
  /// Handles all Android SDK versions and iOS scenarios automatically
  /// 
  /// Returns a map with:
  /// - `platform`: Current platform name
  /// - `sdkVersion`: Android SDK version (if Android)
  /// - `permission`: Permission name to request
  /// - `code`: Complete code snippet with all edge cases handled
  /// - `manifestRequired`: Whether manifest/plist changes are needed
  /// - `edgeCases`: List of edge cases handled
  /// - `conflicts`: Potential conflicts and resolutions
  /// 
  /// Example usage:
  /// ```dart
  /// final instructions = PermissionHelper.getPermissionInstructions();
  /// print('Platform: ${instructions['platform']}');
  /// print('SDK: ${instructions['sdkVersion']}');
  /// print('Edge Cases: ${instructions['edgeCases']}');
  /// ```
  /// Get permission instructions for Android or iOS
  /// This package supports Android and iOS only
  static Map<String, dynamic> getPermissionInstructions() {
    if (Platform.isAndroid) {
      return _getAndroidInstructions();
    } else if (Platform.isIOS) {
      return _getIOSInstructions();
    } else {
      // This package supports Android and iOS only
      return {
        'platform': 'Unsupported',
        'permission': 'N/A',
        'code': '// This package supports Android and iOS only\n// Desktop and Web platforms are not supported',
        'manifestRequired': false,
        'edgeCases': <String>[
          'This package is designed for mobile platforms (Android/iOS) only',
          'Desktop and Web platforms are not supported',
        ],
        'conflicts': <String>[],
        'message': 'This package supports Android and iOS only. Desktop and Web platforms are not supported.',
      };
    }
  }

  static Map<String, dynamic> _getAndroidInstructions() {
    return {
      'platform': 'Android',
      'sdkVersion': 'Auto-detected (API 29, 30, 31, 32, 33+)',
      'permission': 'READ_MEDIA_AUDIO (Android 13+) or READ_EXTERNAL_STORAGE (Android 12-)',
      'code': '''
// Add to pubspec.yaml:
//   permission_handler: ^11.0.0
//   device_info_plus: ^10.0.0

import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Comprehensive permission handler that handles all Android versions
Future<Map<String, dynamic>> requestAudioPermission() async {
  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;
  final sdkInt = androidInfo.version.sdkInt;
  
  // Android 13+ (API 33+) - Uses granular media permissions
  if (sdkInt >= 33) {
    final status = await Permission.audio.request();
    
    // Handle permanently denied (user selected "Don't ask again")
    if (status.isPermanentlyDenied) {
      // Guide user to app settings
      await openAppSettings();
      return {
        'granted': false,
        'permanentlyDenied': true,
        'action': 'openAppSettings',
        'message': 'Permission permanently denied. Please enable in app settings.',
      };
    }
    
    return {
      'granted': status.isGranted,
      'status': status.toString(),
      'sdkVersion': sdkInt,
    };
  }
  // Android 12 (API 31-32) - Still uses READ_EXTERNAL_STORAGE
  else if (sdkInt >= 31) {
    final status = await Permission.storage.request();
    
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return {
        'granted': false,
        'permanentlyDenied': true,
        'action': 'openAppSettings',
        'message': 'Permission permanently denied. Please enable in app settings.',
      };
    }
    
    return {
      'granted': status.isGranted,
      'status': status.toString(),
      'sdkVersion': sdkInt,
    };
  }
  // Android 10-11 (API 29-30) - Scoped Storage introduced
  else if (sdkInt >= 29) {
    // On Android 10+, WRITE_EXTERNAL_STORAGE is not needed for reading
    // But READ_EXTERNAL_STORAGE is still required
    final status = await Permission.storage.request();
    
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return {
        'granted': false,
        'permanentlyDenied': true,
        'action': 'openAppSettings',
        'message': 'Permission permanently denied. Please enable in app settings.',
      };
    }
    
    return {
      'granted': status.isGranted,
      'status': status.toString(),
      'sdkVersion': sdkInt,
      'note': 'Scoped Storage: Direct file paths may not work. Use MediaStore or Content URIs.',
    };
  }
  // Android 9 and below (API < 29) - Traditional storage model
  else {
    final status = await Permission.storage.request();
    
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return {
        'granted': false,
        'permanentlyDenied': true,
        'action': 'openAppSettings',
        'message': 'Permission permanently denied. Please enable in app settings.',
      };
    }
    
    return {
      'granted': status.isGranted,
      'status': status.toString(),
      'sdkVersion': sdkInt,
    };
  }
}

/// Check if permission is already granted (without requesting)
Future<bool> hasAudioPermission() async {
  if (!Platform.isAndroid) return false;
  
  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;
  final sdkInt = androidInfo.version.sdkInt;
  
  if (sdkInt >= 33) {
    return await Permission.audio.isGranted;
  } else {
    return await Permission.storage.isGranted;
  }
}''',
      'manifestRequired': true,
      'manifestInstructions': '''
Add to android/app/src/main/AndroidManifest.xml:

<!-- For Android 13+ (API 33+) - Granular media permissions -->
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />

<!-- For Android 12 and below (API 32 and below) -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" 
                 android:maxSdkVersion="32" />

<!-- Optional: For Android 10 and below, if you need write access -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
                 android:maxSdkVersion="29" 
                 android:maxSdkVersion="29" />

<!-- Optional: For accessing media location (Android 10+) -->
<uses-permission android:name="android.permission.ACCESS_MEDIA_LOCATION" />''',
      'edgeCases': [
        'Android 13+ (API 33+): Uses READ_MEDIA_AUDIO instead of READ_EXTERNAL_STORAGE',
        'Android 10-12 (API 29-32): Scoped Storage - direct file paths may not work',
        'Android 9 and below: Traditional storage model',
        'Permanently denied permissions: Guide user to app settings',
        'Multiple permission requests: Handle gracefully',
      ],
      'conflicts': [
        'If READ_EXTERNAL_STORAGE is requested on Android 13+, it will be permanently denied',
        'Scoped Storage (Android 10+) may require Content URIs instead of file paths',
        'Some devices may have custom permission managers that behave differently',
        'Multiple packages requesting same permission: Android handles automatically',
      ],
      'resolutions': [
        'Always check SDK version before requesting permission',
        'Use maxSdkVersion in manifest to avoid conflicts',
        'Handle permanently denied state by opening app settings',
        'For Scoped Storage, consider using MediaStore API on native side',
      ],
    };
  }

  static Map<String, dynamic> _getIOSInstructions() {
    return {
      'platform': 'iOS',
      'iosVersion': 'All iOS versions',
      'permission': 'NSAppleMusicUsageDescription and NSMediaLibraryUsageDescription',
      'code': '''
// Add to pubspec.yaml:
//   permission_handler: ^11.0.0

import 'package:permission_handler/permission_handler.dart';

/// Comprehensive iOS permission handler
Future<Map<String, dynamic>> requestMediaLibraryPermission() async {
  // Check current status first
  final currentStatus = await Permission.mediaLibrary.status;
  
  // If already granted, return immediately
  if (currentStatus.isGranted) {
    return {
      'granted': true,
      'status': 'already_granted',
      'message': 'Permission already granted',
    };
  }
  
  // If permanently denied, guide to settings
  if (currentStatus.isPermanentlyDenied) {
    await openAppSettings();
    return {
      'granted': false,
      'permanentlyDenied': true,
      'action': 'openAppSettings',
      'message': 'Permission permanently denied. Please enable in Settings > Privacy > Media & Apple Music.',
    };
  }
  
  // Request permission
  final status = await Permission.mediaLibrary.request();
  
  // Handle result
  if (status.isGranted) {
    return {
      'granted': true,
      'status': 'granted',
      'message': 'Permission granted successfully',
    };
  } else if (status.isDenied) {
    return {
      'granted': false,
      'status': 'denied',
      'message': 'Permission denied by user',
    };
  } else if (status.isPermanentlyDenied) {
    await openAppSettings();
    return {
      'granted': false,
      'permanentlyDenied': true,
      'action': 'openAppSettings',
      'message': 'Permission permanently denied. Please enable in Settings.',
    };
  } else if (status.isRestricted) {
    return {
      'granted': false,
      'status': 'restricted',
      'message': 'Permission restricted (e.g., parental controls)',
    };
  }
  
  return {
    'granted': false,
    'status': status.toString(),
    'message': 'Unknown permission status',
  };
}

/// Check if permission is already granted (without requesting)
Future<bool> hasMediaLibraryPermission() async {
  if (!Platform.isIOS) return false;
  return await Permission.mediaLibrary.isGranted;
}

/// Important iOS Notes:
/// 1. NSAppleMusicUsageDescription is required in Info.plist
/// 2. NSMediaLibraryUsageDescription is also recommended
/// 3. Permission prompt only shows once per app install
/// 4. If denied, user must manually enable in Settings
/// 5. For files in app's Documents directory, no permission needed
/// 6. For Music Library access, permission is mandatory''',
      'manifestRequired': true,
      'manifestInstructions': '''
Add to ios/Runner/Info.plist:

<!-- Required for accessing Music Library -->
<key>NSAppleMusicUsageDescription</key>
<string>This app needs access to your music library to extract metadata and analyze audio features from audio files.</string>

<!-- Recommended for accessing Media Library -->
<key>NSMediaLibraryUsageDescription</key>
<string>This app needs access to your media library to extract metadata from audio files.</string>

<!-- Optional: For accessing files from Files app -->
<key>NSDocumentsFolderUsageDescription</key>
<string>This app needs access to your documents to read audio files.</string>''',
      'edgeCases': [
        'Permission prompt only shows once per app install',
        'If denied, user must manually enable in Settings app',
        'Files in app Documents directory: No permission needed',
        'Music Library access: Permission mandatory',
        'Files app access: May need different permission',
        'Restricted state: Parental controls or device restrictions',
        'Permanently denied: Guide user to Settings',
      ],
      'conflicts': [
        'Missing Info.plist key causes app crash (not just denial)',
        'Multiple permission requests: iOS handles automatically',
        'Permission state persists across app restarts',
        'Some iOS versions may have different behavior',
      ],
      'resolutions': [
        'Always include NSAppleMusicUsageDescription in Info.plist',
        'Check permission status before requesting',
        'Handle permanently denied by opening Settings',
        'Provide clear user guidance for manual permission enablement',
        'For app Documents files, no permission needed',
      ],
    };
  }

  /// Log permission instructions (use getPermissionInstructions() for full data).
  static void logPermissionInstructions() {
    final instructions = getPermissionInstructions();
    if (instructions['manifestRequired'] == true) {
      _logger.w('Manifest/Plist configuration required for audio access. See getPermissionInstructions().');
    }
  }
}

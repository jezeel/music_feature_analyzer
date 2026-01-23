import 'package:flutter/services.dart';
import '../../utils/app_logger.dart';

/// Audio metadata model returned from native platform
class AudioMetadata {
  final String? title;
  final String? artist;
  final String? album;
  final String? albumArtist;
  final String? genre;
  final String? year;
  final String? composer;
  final String? writer;
  final String? trackNumber;
  final String? discNumber;
  final int? duration; // in milliseconds
  final int? bitrate;
  final String? mimeType;
  final bool hasAlbumArt;
  final int? fileSize;

  AudioMetadata({
    this.title,
    this.artist,
    this.album,
    this.albumArtist,
    this.genre,
    this.year,
    this.composer,
    this.writer,
    this.trackNumber,
    this.discNumber,
    this.duration,
    this.bitrate,
    this.mimeType,
    this.hasAlbumArt = false,
    this.fileSize,
  });

  factory AudioMetadata.fromMap(Map<dynamic, dynamic> map) {
    return AudioMetadata(
      title: map['title'] as String?,
      artist: map['artist'] as String?,
      album: map['album'] as String?,
      albumArtist: map['albumArtist'] as String?,
      genre: map['genre'] as String?,
      year: map['year'] as String?,
      composer: map['composer'] as String?,
      writer: map['writer'] as String?,
      trackNumber: map['trackNumber']?.toString(),
      discNumber: map['discNumber']?.toString(),
      duration: map['duration'] is int
          ? map['duration'] as int
          : (map['duration'] is String
                ? int.tryParse(map['duration'] as String)
                : (map['duration'] is double
                      ? (map['duration'] as double).toInt()
                      : null)),
      bitrate: map['bitrate'] is int
          ? map['bitrate'] as int
          : (map['bitrate'] is String ? int.tryParse(map['bitrate'] as String) : null),
      mimeType: map['mimeType'] as String?,
      hasAlbumArt: map['hasAlbumArt'] as bool? ?? false,
      fileSize: map['fileSize'] as int?,
    );
  }
}

/// Service class for native audio metadata operations
/// Uses platform channels to communicate with Android/iOS native code
class NativeMetadataService {
  static const platform = MethodChannel(
    'com.music_feature_analyzer/audio_metadata',
  );
  static final _logger = AppLogger('NativeMetadataService');
  
  /// Connection verification result
  static const String loadingModePublished = 'PUBLISHED_PACKAGE';
  static const String loadingModeLocal = 'LOCAL_PATH';
  
  /// Verify method channel connection and get loading mode information
  /// Returns connection status and how the dependency is loaded
  static Future<Map<String, dynamic>?> verifyConnection() async {
    try {
      _logger.d('Verifying method channel connection...');
      final result = await platform.invokeMethod('verifyConnection');
      
      if (result != null) {
        final info = result as Map<dynamic, dynamic>;
        final connected = info['connected'] as bool? ?? false;
        final channelName = info['channelName'] as String? ?? 'unknown';
        final loadingMode = info['loadingMode'] as String? ?? 'unknown';
        final handlerSet = info['handlerSet'] as bool? ?? false;
        
        _logger.i('✅ Connection verification successful:');
        _logger.i('   Connected: $connected');
        _logger.i('   Channel: $channelName');
        _logger.i('   Loading Mode: $loadingMode');
        _logger.i('   Handler Set: $handlerSet');
        
        if (loadingMode == loadingModePublished) {
          _logger.i('📦 Plugin loaded as PUBLISHED PACKAGE (pub.dev)');
          _logger.i('   ✅ Automatic registration should work');
        } else if (loadingMode == loadingModeLocal) {
          _logger.i('🔧 Plugin loaded as LOCAL PATH dependency');
          _logger.i('   ⚙️ Manual registration may be needed in MainActivity');
        }
        
        return {
          'connected': connected,
          'channelName': channelName,
          'loadingMode': loadingMode,
          'handlerSet': handlerSet,
        };
      }
      
      _logger.w('Connection verification returned null');
      return null;
    } on PlatformException catch (e) {
      _logger.e('PlatformException during connection verification: ${e.code} - ${e.message}', error: e);
      
      if (e.code == 'not_implemented' || 
          e.message?.contains('not implemented') == true ||
          e.message?.contains('MissingPluginException') == true) {
        _logger.e('⚠️ Plugin not registered!');
        _logger.w('═══════════════════════════════════════════════════════════════');
        _logger.w('⚠️  PLUGIN REGISTRATION ISSUE');
        _logger.w('═══════════════════════════════════════════════════════════════');
        _logger.i('SOLUTION 1 (Published Package from pub.dev):');
        _logger.i('  Plugin should auto-register. Try:');
        _logger.i('  1. Run: flutter clean');
        _logger.i('  2. Run: flutter pub get');
        _logger.i('  3. Rebuild your app completely');
        _logger.i('SOLUTION 2 (Local Path Dependency):');
        _logger.i('  Manual registration may be needed');
        _logger.i('  See BUILD_COMPATIBILITY.md for details');
        _logger.w('═══════════════════════════════════════════════════════════════');
      }
      
      return {
        'connected': false,
        'error': e.message,
        'code': e.code,
      };
    } catch (e, stackTrace) {
      _logger.e('Unexpected error during connection verification: $e', error: e, stackTrace: stackTrace);
      return {
        'connected': false,
        'error': e.toString(),
      };
    }
  }

  /// Get metadata from audio file using native MediaMetadataRetriever
  static Future<AudioMetadata?> getMetadata(String filePath) async {
    try {
      // Debug logging (matching working implementation pattern)
      _logger.d('Calling getMetadata for: $filePath');
      
      final result = await platform.invokeMethod('getMetadata', {
        'path': filePath,
      });
      
      _logger.d('Received result: ${result != null ? "not null" : "null"}');

      if (result != null) {
        final map = result as Map<dynamic, dynamic>;
        
        // Check if native code returned an error
        if (map.containsKey('error')) {
          final errorMsg = map['error'] as String?;
          _logger.w('Native platform returned error: $errorMsg');
          // Return null so caller can use filename parsing fallback
          // The error is already logged in Android logcat (tag: MusicFeatureAnalyzer)
          return null;
        }
        
        _logger.i('Successfully parsed metadata');
        _logger.d('Metadata keys: ${map.keys.toList()}');
        _logger.d('Title: ${map['title']}, Artist: ${map['artist']}, Duration: ${map['duration']}');
        
        // Always return metadata if we have any data (even if just fileSize/mimeType)
        // The Android plugin always returns at least fileSize and mimeType
        // This matches the working implementation pattern
        return AudioMetadata.fromMap(map);
      }
      
      _logger.w('Result is null');
      return null;
    } on PlatformException catch (e) {
      // Platform exception means method channel not set up or error occurred
      _logger.e('PlatformException: ${e.code} - ${e.message}', error: e, stackTrace: StackTrace.current);
      _logger.d('Details: ${e.details}');
      
      // Check if it's a MissingPluginException (plugin not registered)
      if (e.code == 'not_implemented' || 
          e.message?.contains('not implemented') == true ||
          e.message?.contains('MissingPluginException') == true) {
        _logger.e('Plugin not registered! Attempting to provide setup instructions...');
        _logger.w('═══════════════════════════════════════════════════════════════');
        _logger.w('⚠️  PLUGIN REGISTRATION ISSUE');
        _logger.w('═══════════════════════════════════════════════════════════════');
        _logger.w('The MusicFeatureAnalyzerPlugin is not registered.');
        _logger.i('SOLUTION 1 (Published Package from pub.dev):');
        _logger.i('  The plugin should register automatically. Try:');
        _logger.i('  1. Run: flutter clean');
        _logger.i('  2. Run: flutter pub get');
        _logger.i('  3. Rebuild your app completely');
        _logger.i('  4. Verify GeneratedPluginRegistrant includes the plugin');
        _logger.i('SOLUTION 2 (Local Path Dependency):');
        _logger.i('  Manual registration may be needed. See BUILD_COMPATIBILITY.md');
        _logger.w('═══════════════════════════════════════════════════════════════');
        
        throw PlatformException(
          code: 'PLUGIN_NOT_REGISTERED',
          message: 'MusicFeatureAnalyzerPlugin is not registered.\n\n'
              'For published packages (pub.dev), try:\n'
              '  1. Run: flutter clean\n'
              '  2. Run: flutter pub get\n'
              '  3. Rebuild your app\n\n'
              'For local path dependencies, see BUILD_COMPATIBILITY.md\n\n'
              'Method channel: com.music_feature_analyzer/audio_metadata',
          details: {
            'methodChannel': 'com.music_feature_analyzer/audio_metadata',
            'setupGuide': 'BUILD_COMPATIBILITY.md',
            'isPublishedPackage': 'Check if using pub.dev or local path',
          },
        );
      }
      return null;
    } catch (e, stackTrace) {
      // Unexpected error
      _logger.e('Unexpected error: $e', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Get embedded album art from audio file
  static Future<Uint8List?> getAlbumArt(String filePath) async {
    try {
      _logger.d('Calling getAlbumArt for: $filePath');
      final result = await platform.invokeMethod('getAlbumArt', {
        'path': filePath,
      });
      
      if (result == null) {
        _logger.w('getAlbumArt returned null');
        return null;
      }
      
      // Handle both ByteArray (Uint8List) and List<int>
      Uint8List? albumArtData;
      if (result is Uint8List) {
        albumArtData = result;
      } else if (result is List) {
        albumArtData = Uint8List.fromList(result.cast<int>());
      } else {
        _logger.w('getAlbumArt returned unexpected type: ${result.runtimeType}');
        return null;
      }
      
      _logger.i('getAlbumArt succeeded - ${albumArtData.length} bytes');
      return albumArtData;
    } on PlatformException catch (e) {
      _logger.e('PlatformException in getAlbumArt: ${e.code} - ${e.message}', error: e);
      return null;
    } catch (e, stackTrace) {
      _logger.e('Unexpected error in getAlbumArt: $e', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Get MIME type of embedded album art
  static Future<String?> getAlbumArtMimeType(String filePath) async {
    try {
      _logger.d('Calling getAlbumArtMimeType for: $filePath');
      final result = await platform.invokeMethod('getAlbumArtMimeType', {
        'path': filePath,
      });
      final mimeType = result as String?;
      _logger.i('getAlbumArtMimeType returned: ${mimeType ?? "null"}');
      return mimeType;
    } on PlatformException catch (e) {
      _logger.e('PlatformException in getAlbumArtMimeType: ${e.code} - ${e.message}', error: e);
      return null;
    } catch (e) {
      _logger.e('Unexpected error in getAlbumArtMimeType: $e', error: e);
      return null;
    }
  }
}

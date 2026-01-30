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
  final String? date;
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
    this.date,
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

  /// Normalize bitrate to kbps; platform may return bits/sec (e.g. 160000 -> 160).
  static int? _normalizeBitrateToKbps(dynamic raw) {
    int? value;
    if (raw is int) {
      value = raw;
    } else if (raw is String) {
      value = int.tryParse(raw);
    }
    if (value == null || value <= 0) return null;
    if (value > 1000) return value ~/ 1000;
    return value;
  }

  factory AudioMetadata.fromMap(Map<dynamic, dynamic> map) {
    return AudioMetadata(
      title: map['title'] as String?,
      artist: map['artist'] as String?,
      album: map['album'] as String?,
      albumArtist: map['albumArtist'] as String?,
      genre: map['genre'] as String?,
      year: map['year'] as String?,
      date: map['date'] as String?,
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
      // Normalize bitrate to kbps (platform may return bps)
      bitrate: _normalizeBitrateToKbps(map['bitrate']),
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
      final result = await platform.invokeMethod('verifyConnection');
      if (result != null) {
        final info = result as Map<dynamic, dynamic>;
        final connected = info['connected'] as bool? ?? false;
        final channelName = info['channelName'] as String? ?? 'unknown';
        final loadingMode = info['loadingMode'] as String? ?? 'unknown';
        final handlerSet = info['handlerSet'] as bool? ?? false;
        return {
          'connected': connected,
          'channelName': channelName,
          'loadingMode': loadingMode,
          'handlerSet': handlerSet,
        };
      }
      
      return null;
    } on PlatformException catch (e) {
      _logger.e('Platform connection failed: ${e.code} - ${e.message}', error: e);
      if (e.code == 'not_implemented' || 
          e.message?.contains('not implemented') == true ||
          e.message?.contains('MissingPluginException') == true) {
        _logger.w('Plugin not registered. Run: flutter clean, flutter pub get, then rebuild. See BUILD_COMPATIBILITY.md');
      }
      
      return {
        'connected': false,
        'error': e.message,
        'code': e.code,
      };
    } catch (e, stackTrace) {
      _logger.e('Connection verification failed: $e', error: e, stackTrace: stackTrace);
      return {
        'connected': false,
        'error': e.toString(),
      };
    }
  }

  /// Get metadata from audio file using native MediaMetadataRetriever
  static Future<AudioMetadata?> getMetadata(String filePath) async {
    try {
      final result = await platform.invokeMethod('getMetadata', {
        'path': filePath,
      });
      if (result != null) {
        final map = result as Map<dynamic, dynamic>;
        if (map.containsKey('error')) {
          final errorMsg = map['error'] as String?;
          _logger.w('Native metadata error: $errorMsg');
          return null;
        }
        return AudioMetadata.fromMap(map);
      }
      return null;
    } on PlatformException catch (e) {
      _logger.e('getMetadata failed: ${e.code} - ${e.message}', error: e, stackTrace: StackTrace.current);
      if (e.code == 'not_implemented' || 
          e.message?.contains('not implemented') == true ||
          e.message?.contains('MissingPluginException') == true) {
        _logger.w('Plugin not registered. See BUILD_COMPATIBILITY.md');
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
      _logger.e('getMetadata error: $e', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Get embedded album art from audio file
  static Future<Uint8List?> getAlbumArt(String filePath) async {
    try {
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
      final result = await platform.invokeMethod('getAlbumArtMimeType', {
        'path': filePath,
      });
      return result as String?;
    } on PlatformException catch (e) {
      _logger.e('getAlbumArtMimeType failed: ${e.code} - ${e.message}', error: e);
      return null;
    } catch (e, stackTrace) {
      _logger.e('getAlbumArtMimeType error: $e', error: e, stackTrace: stackTrace);
      return null;
    }
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../../utils/app_logger.dart';
import 'native_metadata_service.dart';
import 'shared_validation.dart';
import 'metadata_utils.dart';

/// Album art extraction, optimization, and management
class AlbumArtHandler {
  static final _logger = AppLogger('AlbumArtHandler');

  /// Extract album art from metadata with optimization
  static Future<String?> extractAlbumArt(
    String filePath,
    AudioMetadata? metadata,
  ) async {
    try {
      _logger.d('🎨 Starting album art extraction for: $filePath');
      
      // ALWAYS try to extract album art, even if hasAlbumArt is false
      // Some files may have album art even if the flag is not set correctly
      _logger.d('🎨 Calling native service to get album art...');
      final albumArtData = await NativeMetadataService.getAlbumArt(filePath);

      if (albumArtData == null || albumArtData.isEmpty) {
        _logger.d('⚠️ No album art data extracted from embedded metadata for: $filePath');
        _logger.d('   hasAlbumArt flag from metadata: ${metadata?.hasAlbumArt ?? false}');
        return null;
      }

      _logger.d('🎨 Received album art data: ${albumArtData.length} bytes');

      // Validate minimum size (at least 100 bytes to be a valid image)
      if (albumArtData.length < 100) {
        _logger.w('⚠️ Album art data too small (${albumArtData.length} bytes) for: $filePath');
        return null;
      }

      _logger.i('✅ Found embedded album art (${albumArtData.length} bytes) for: $filePath');

      // Get MIME type from native service if available
      _logger.d('🎨 Getting album art MIME type...');
      final mimeType = await NativeMetadataService.getAlbumArtMimeType(filePath);
      _logger.d('🎨 Album art MIME type: ${mimeType ?? "unknown"}');

      _logger.d('🎨 Optimizing album art...');
      final optimizedData = await optimizeAlbumArt(albumArtData);
      if (optimizedData == null || optimizedData.isEmpty) {
        _logger.w('⚠️ Failed to optimize album art for: $filePath - using original data');
        final savedPath = await saveAlbumArt(filePath, albumArtData, mimeType);
        if (savedPath != null) {
          _logger.i('✅ Saved original album art to: $savedPath');
        }
        return savedPath;
      }

      _logger.d('🎨 Album art optimized: ${albumArtData.length} bytes -> ${optimizedData.length} bytes');
      final savedPath = await saveAlbumArt(filePath, optimizedData, mimeType);
      if (savedPath != null) {
        _logger.i('✅ Saved optimized album art to: $savedPath');
      }
      return savedPath;
    } catch (e, stackTrace) {
      _logger.e('❌ Error extracting album art from $filePath', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Safe extraction of album art with error handling
  static Future<String?> extractAlbumArtSafely(
    String filePath,
    AudioMetadata? metadata,
  ) async {
    return SharedValidation.extractSafely(
      () async => await extractAlbumArt(filePath, metadata),
      null,
      'album art',
    );
  }

  /// Find external album art files in the same directory
  static Future<String?> findExternalAlbumArt(String filePath) async {
    try {
      _logger.d('🔍 Searching for external album art for: $filePath');
      final file = File(filePath);
      final dir = file.parent;
      
      if (!await dir.exists()) {
        _logger.d('⚠️ Directory does not exist for external album art search: ${dir.path}');
        return null;
      }

      _logger.d('🔍 Searching in directory: ${dir.path}');

      // Common album art filenames (case-insensitive search)
      final candidates = <String>[
        'cover.jpg', 'cover.png', 'cover.jpeg',
        'folder.jpg', 'folder.png', 'folder.jpeg',
        'front.jpg', 'front.png', 'front.jpeg',
        'album.jpg', 'album.png', 'album.jpeg',
        'artwork.jpg', 'artwork.png', 'artwork.jpeg',
        'art.jpg', 'art.png', 'art.jpeg',
        'thumbnail.jpg', 'thumbnail.png', 'thumbnail.jpeg',
        'AlbumArt.jpg', 'AlbumArt.png', 'AlbumArt.jpeg',
        'Cover.jpg', 'Cover.png', 'Cover.jpeg',
        'Folder.jpg', 'Folder.png', 'Folder.jpeg',
      ];

      for (final name in candidates) {
        final f = File('${dir.path}/$name');
        if (await f.exists()) {
          final fileSize = await f.length();
          if (fileSize < 100) {
            _logger.d('   Skipping ${f.path} - too small (${fileSize} bytes)');
            continue;
          }

          _logger.i('✅ Found external album art: ${f.path} (${fileSize} bytes)');

          final data = await f.readAsBytes();
          final optimized = await optimizeAlbumArt(data);
          final savedPath = await saveAlbumArt(
            filePath,
            optimized ?? data,
            guessMimeTypeFromPath(name),
          );
          if (savedPath != null) {
            _logger.i('✅ Saved external album art to: $savedPath');
          }
          return savedPath;
        }
      }

      _logger.d('⚠️ No external album art found in directory: ${dir.path}');
    } catch (e, stackTrace) {
      _logger.w('❌ External album art search failed for $filePath', error: e, stackTrace: stackTrace);
    }
    return null;
  }

  /// Optimize album art using isolate for heavy processing
  static Future<Uint8List?> optimizeAlbumArt(Uint8List imageData) async {
    try {
      final optimized = await compute(_optimizeAlbumArtIsolate, imageData).timeout(
        const Duration(seconds: 5),
      );
      return optimized ?? imageData;
    } catch (e, stackTrace) {
      _logger.e('Error optimizing album art', error: e, stackTrace: stackTrace);
      return imageData;
    }
  }

  /// Save optimized album art to app directory
  static Future<String?> saveAlbumArt(
    String filePath,
    Uint8List data,
    String? mimeType,
  ) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final albumArtDir = Directory('${appDir.path}/album_art');
      if (!await albumArtDir.exists()) {
        await albumArtDir.create(recursive: true);
      }
      final songId = await MetadataUtils.generateSongId(filePath);
      final extension = getImageExtensionFromMimeType(mimeType);
      final albumArtPath = '${albumArtDir.path}/$songId$extension';
      final albumArtFile = File(albumArtPath);
      if (!await albumArtFile.exists()) {
        await albumArtFile.writeAsBytes(data);
        _logger.d('Saved optimized album art: $albumArtPath');
      } else {
        _logger.d('Album art already exists: $albumArtPath');
      }
      return albumArtPath;
    } catch (e) {
      _logger.w('Failed to save album art: $e');
      try {
        final tempDir = await getTemporaryDirectory();
        final albumArtDir = Directory('${tempDir.path}/album_art');
        if (!await albumArtDir.exists()) {
          await albumArtDir.create(recursive: true);
        }
        final songId = await MetadataUtils.generateSongId(filePath);
        final extension = getImageExtensionFromMimeType(mimeType);
        final albumArtPath = '${albumArtDir.path}/$songId$extension';
        final albumArtFile = File(albumArtPath);
        await albumArtFile.writeAsBytes(data);
        _logger.d('Saved album art to temp directory: $albumArtPath');
        return albumArtPath;
      } catch (tempError) {
        _logger.e('Failed to save album art to temp directory: $tempError');
        return null;
      }
    }
  }

  /// Guess MIME type from file path
  static String guessMimeTypeFromPath(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }

  /// Get image extension from MIME type
  static String getImageExtensionFromMimeType(String? mimeType) {
    switch (mimeType?.toLowerCase()) {
      case 'image/jpeg':
      case 'image/jpg':
        return '.jpg';
      case 'image/png':
        return '.png';
      case 'image/gif':
        return '.gif';
      case 'image/webp':
        return '.webp';
      case 'image/bmp':
        return '.bmp';
      default:
        return '.jpg';
    }
  }
}

/// Heavy image optimization moved to an isolate-safe top-level function
Uint8List? _optimizeAlbumArtIsolate(Uint8List imageData) {
  try {
    // Don't optimize very small images
    if (imageData.length < 50 * 1024) return imageData;

    final originalImage = img.decodeImage(imageData);
    if (originalImage == null) return imageData;

    const maxDimension = 500;
    int targetWidth = originalImage.width;
    int targetHeight = originalImage.height;

    if (originalImage.width > maxDimension || originalImage.height > maxDimension) {
      if (originalImage.width > originalImage.height) {
        targetWidth = maxDimension;
        targetHeight = (originalImage.height * maxDimension / originalImage.width).round();
      } else {
        targetHeight = maxDimension;
        targetWidth = (originalImage.width * maxDimension / originalImage.height).round();
      }
    }

    img.Image processedImage = originalImage;
    if (targetWidth != originalImage.width || targetHeight != originalImage.height) {
      processedImage = img.copyResize(
        originalImage,
        width: targetWidth,
        height: targetHeight,
        interpolation: img.Interpolation.cubic,
      );
    }

    int quality = 90;
    if (imageData.length > 500 * 1024) {
      quality = 80;
    } else if (imageData.length > 200 * 1024) {
      quality = 85;
    }

    final compressed = img.encodeJpg(processedImage, quality: quality);
    return Uint8List.fromList(compressed);
  } catch (_) {
    return imageData;
  }
}

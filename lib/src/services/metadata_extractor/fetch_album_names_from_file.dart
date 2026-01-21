import 'native_metadata_service.dart';
import 'shared_validation.dart';
import 'metadata_utils.dart';

/// Comprehensive album name extraction from filenames and metadata
class AlbumNameExtractor {

  /// Extract albums from metadata tags with fallback to filename parsing
  static List<String> extractAlbums(AudioMetadata? metadata, String filePath) {
    final album = MetadataUtils.cleanString(metadata?.album);
    if (album != null && album.isNotEmpty) {
      return splitAlbums(album);
    }
    return ['Unknown Album'];
  }

  /// Safe extraction of albums with error handling
  static List<String> extractAlbumsSafely(AudioMetadata? metadata, String filePath) {
    return SharedValidation.extractSafely(
      () => extractAlbums(metadata, filePath),
      ['Unknown Album'],
      'albums',
    );
  }

  /// Ensure albums are extracted with filename fallback
  static List<String> ensureAlbums(List<String> albums, String filePath) {
    final valid = albums
        .where((item) => item.trim().isNotEmpty && item.toLowerCase() != 'unknown album')
        .toSet()
        .toList();
    if (valid.isNotEmpty) return valid;

    // Try to extract from filename
    final fileName = filePath.split('/').last.split('.').first;
    final cleanFileName = SharedValidation.cleanFilename(fileName);
    final parsed = SharedValidation.parseFilenameIntelligently(cleanFileName);
    
    if (parsed.albums.isNotEmpty) return parsed.albums;

    // Fallback
    return ['Unknown Album'];
  }

  /// Split album string into multiple albums
  static List<String> splitAlbums(String albumString) {
    if (albumString.isEmpty) return ['Unknown Album'];
    var normalized = albumString.replaceAll(RegExp(r'\s+'), ' ');
    final replacements = {
      RegExp(r'\s*&\s*'): ' | ',
      RegExp(r'\s+and\s+', caseSensitive: false): ' | ',
      RegExp(r'\s*,\s*'): ' | ',
      RegExp(r'\s*;\s*'): ' | ',
    };
    replacements.forEach((regex, value) {
      normalized = normalized.replaceAll(regex, value);
    });
    final parts = normalized.split('|').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
    final cleaned = <String>{};
    for (final p in parts) {
      final c = MetadataUtils.cleanString(p);
      if (c != null && c.isNotEmpty && c.toLowerCase() != 'unknown album') {
        cleaned.add(c);
      }
    }
    return cleaned.isEmpty ? ['Unknown Album'] : cleaned.toList();
  }
}

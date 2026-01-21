import 'native_metadata_service.dart';
import 'shared_validation.dart';
import 'metadata_utils.dart';

/// Comprehensive artist name extraction from filenames and metadata
class ArtistNameExtractor {

  /// Extract artists from metadata tags with fallback to filename parsing
  static List<String> extractArtists(AudioMetadata? metadata, String filePath) {
    final artists = <String>[];
    var artist = MetadataUtils.cleanString(metadata?.artist);
    if (artist != null && artist.isNotEmpty) {
      artists.addAll(SharedValidation.splitArtists(artist));
    }
    if (artists.isEmpty) {
      final albumArtist = MetadataUtils.cleanString(metadata?.albumArtist);
      if (albumArtist != null && albumArtist.isNotEmpty) {
        artists.addAll(SharedValidation.splitArtists(albumArtist));
      }
    }
    return artists.isEmpty ? ['Unknown Artist'] : artists;
  }

  /// Safe extraction of artists with error handling
  static List<String> extractArtistsSafely(AudioMetadata? metadata, String filePath) {
    return SharedValidation.extractSafely(
      () => extractArtists(metadata, filePath),
      ['Unknown Artist'],
      'artists',
    );
  }

  /// Ensure artists are extracted with filename fallback
  static List<String> ensureArtists(List<String> artists, String filePath) {
    final valid = artists
        .where((item) => item.trim().isNotEmpty && item.toLowerCase() != 'unknown artist')
        .toSet()
        .toList();
    if (valid.isNotEmpty) return valid;

    // Try to extract from filename
    final fileName = filePath.split('/').last.split('.').first;
    final cleanFileName = SharedValidation.cleanFilename(fileName);
    final parsed = SharedValidation.parseFilenameIntelligently(cleanFileName);
    
    if (parsed.artists.isNotEmpty) return parsed.artists;

    // Fallback
    return ['Unknown Artist'];
  }
}

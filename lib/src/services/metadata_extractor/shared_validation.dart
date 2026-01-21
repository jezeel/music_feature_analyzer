import '../../utils/app_logger.dart';
import 'metadata_utils.dart';

/// Extension to capitalize strings
extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

/// Shared validation utilities for metadata extraction
class SharedValidation {
  static final _logger = AppLogger('SharedValidation');

  /// Enhanced validation for artist names
  static bool isValidArtistName(String text) {
    if (text.isEmpty || text.length < 2) return false;
    final lowerText = text.toLowerCase().trim();
    
    // Reject if it's clearly not an artist name
    if (containsSongIndicators(lowerText) || containsAlbumIndicators(lowerText)) {
      return false;
    }
    
    // Reject quality indicators and technical terms
    if (containsQualityIndicators(lowerText)) {
      return false;
    }
    
    // Accept if it contains artist indicators
    if (containsArtistIndicators(lowerText)) return true;
    
    // Basic validation: length and no problematic patterns
    return text.length >= 2 && 
           text.length <= 60 && 
           !containsProblematicPatterns(text) &&
           !isNumericOnly(text);
  }

  /// Enhanced validation for album names
  static bool isValidAlbumName(String text) {
    if (text.isEmpty || text.length < 2) return false;
    final lowerText = text.toLowerCase().trim();
    
    if (containsSongIndicators(lowerText) || containsArtistIndicators(lowerText)) {
      return false;
    }
    
    if (containsQualityIndicators(lowerText)) {
      return false;
    }
    
    if (containsAlbumIndicators(lowerText)) return true;
    
    return text.length >= 2 && 
           text.length <= 60 && 
           !containsProblematicPatterns(text) &&
           !isNumericOnly(text);
  }

  /// Enhanced validation for song titles
  static bool isValidSongTitle(String text) {
    if (text.isEmpty || text.length < 1) return false;
    final lowerText = text.toLowerCase().trim();
    
    // Titles can contain song indicators (like "Song", "Track")
    if (containsArtistIndicators(lowerText) && !containsSongIndicators(lowerText)) {
      return false; // If it only has artist indicators, it's likely an artist
    }
    
    if (containsQualityIndicators(lowerText)) {
      return false;
    }
    
    return text.length >= 1 && 
           text.length <= 120 && 
           !isNumericOnly(text);
  }

  /// Check for quality indicators and technical terms
  static bool containsQualityIndicators(String lowerText) {
    const qualityIndicators = [
      'mp3', 'flac', 'aac', 'wav', 'm4a', 'ogg', 'wma', 'opus', 'aiff', 'alac',
      '160k', '192k', '256k', '320k', 'vbr', 'cbr', 'kbps', 'bitrate',
      'hd', '4k', '1080p', '720p', '480p', '360p',
      'official', 'explicit', 'clean', 'radio edit', 'remix', 'cover', 'version',
      'video', 'lyric', 'lyrics', 'karaoke', 'instrumental', 'acoustic',
      'live', 'studio', 'demo', 'unreleased', 'leak', 'bootleg',
    ];
    return qualityIndicators.any((indicator) => lowerText.contains(indicator));
  }

  /// Check for song-specific indicators
  static bool containsSongIndicators(String lowerText) {
    const songIndicators = [
      'song', 'track', 'music', 'single', 'feat', 'featuring', 'ft', 'ft.',
      'remix', 'cover', 'version', 'edit', 'mix',
    ];
    return songIndicators.any((indicator) => lowerText.contains(indicator));
  }

  /// Check for album-specific indicators
  static bool containsAlbumIndicators(String lowerText) {
    const albumIndicators = [
      'album', 'ep', 'single', 'compilation', 'collection', 'greatest hits',
      'best of', 'anthology', 'soundtrack', 'ost', 'original soundtrack',
      'deluxe', 'edition', 'remastered', 'remaster', 'bonus', 'disc',
    ];
    return albumIndicators.any((indicator) => lowerText.contains(indicator));
  }

  /// Check for artist-specific indicators
  static bool containsArtistIndicators(String lowerText) {
    const artistIndicators = [
      'artist', 'band', 'group', 'singer', 'rapper', 'dj', 'producer',
      'feat', 'featuring', 'ft', 'ft.', 'with', 'and', '&', 'x', '×',
      'presents', 'presents:', 'presents -',
    ];
    return artistIndicators.any((indicator) => lowerText.contains(indicator));
  }

  /// Check for problematic patterns
  static bool containsProblematicPatterns(String text) {
    final problematicPatterns = [
      RegExp(r'^\d{4}$'), // Only year
      RegExp(r'^\[.*\]$'), // Only brackets
      RegExp(r'^\(.*\)$'), // Only parentheses
      RegExp(r'\.(mp3|flac|wav|aac|m4a|ogg|wma|opus|aiff|alac)$', caseSensitive: false), // File extensions
      RegExp(r'^\d+$'), // Only numbers
      RegExp(r'^[^\w\s]+$'), // Only special characters
    ];
    return problematicPatterns.any((pattern) => pattern.hasMatch(text.trim()));
  }

  /// Check if text is only numeric
  static bool isNumericOnly(String text) {
    return RegExp(r'^\d+$').hasMatch(text.trim());
  }

  /// Split artist string into multiple artists
  static List<String> splitArtists(String artistString) {
    if (artistString.isEmpty) return ['Unknown Artist'];
    
    var normalized = artistString
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^by\s+', caseSensitive: false), '')
        .trim();
    
    // Handle feat/featuring/with patterns
    normalized = normalized.replaceAll(
      RegExp(r'\s*[\(\[]?\s*(feat\.?|featuring|ft\.?|ft|with|presents|presents:)\s*[\)\]]?\s*', caseSensitive: false),
      ' | ',
    );
    
    // Handle various separators
    final replacements = {
      RegExp(r'\s*&\s*'): ' | ',
      RegExp(r'\s+and\s+', caseSensitive: false): ' | ',
      RegExp(r'\s*,\s*'): ' | ',
      RegExp(r'\s*;\s*'): ' | ',
      RegExp(r'\s*/\s*'): ' | ',
      RegExp(r'\s*\\\s*'): ' | ',
      RegExp(r'\s*\+\s*'): ' | ',
      RegExp(r'\s*[x×]\s*', caseSensitive: false): ' | ',
      RegExp(r'\s*[-–—]\s*', caseSensitive: false): ' | ', // Only if it looks like separator
    };
    
    replacements.forEach((regex, value) {
      normalized = normalized.replaceAll(regex, value);
    });
    
    final parts = normalized
        .split('|')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    
    final cleaned = <String>{};
    for (final p in parts) {
      final c = MetadataUtils.cleanString(p);
      if (c != null && 
          c.isNotEmpty && 
          c.toLowerCase() != 'unknown artist' &&
          isValidArtistName(c)) {
        cleaned.add(c);
      }
    }
    
    return cleaned.isEmpty ? ['Unknown Artist'] : cleaned.toList();
  }

  /// Generic safe extraction function
  static T extractSafely<T>(
    T Function() extractFunction,
    T fallbackValue,
    String errorContext,
  ) {
    try {
      return extractFunction();
    } catch (e) {
      _logger.w('Error extracting $errorContext: $e');
      return fallbackValue;
    }
  }

  /// Clean filename - comprehensive cleaning
  static String cleanFilename(String fileName) {
    var cleaned = fileName;
    
    // Remove leading track numbers
    cleaned = cleaned.replaceFirst(RegExp(r'^\d+\.?\s*'), '');
    cleaned = cleaned.replaceFirst(RegExp(r'^\d+\s*[-–—]\s*'), '');
    
    // Remove disc/CD indicators
    cleaned = cleaned.replaceAll(RegExp(r'\[CD\d+\]', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'\(Disc\s+\d+\)', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'Disc\s+\d+\s*[-–—]?\s*', caseSensitive: false), '');
    
    // Remove quality indicators in brackets and parentheses
    cleaned = cleaned.replaceAll(
      RegExp(r'\[[^\]]*(Official|Explicit|Clean|Radio Edit|Video|Lyric|HD|4K|1080p|720p|480p|360p|MP3|FLAC|AAC|WAV|M4A|OGG|WMA|OPUS|AIFF|ALAC|160K|192K|256K|320K|VBR|CBR|Kbps|Bitrate|Remix|Cover|Version|Live|Studio|Demo|Unreleased|Leak|Bootleg|Karaoke|Instrumental|Acoustic)[^\]]*\]', caseSensitive: false), 
      ''
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'\([^)]*(Official|Explicit|Clean|Radio Edit|Video|Lyric|HD|4K|1080p|720p|480p|360p|MP3|FLAC|AAC|WAV|M4A|OGG|WMA|OPUS|AIFF|ALAC|160K|192K|256K|320K|VBR|CBR|Kbps|Bitrate|Remix|Cover|Version|Live|Studio|Demo|Unreleased|Leak|Bootleg|Karaoke|Instrumental|Acoustic)[^)]*\)', caseSensitive: false), 
      ''
    );
    
    // Normalize whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return cleaned;
  }

  /// Check if folder name is a common music folder (not useful for metadata)
  static bool isCommonMusicFolderName(String folderName) {
    const commonFolders = [
      'music', 'songs', 'audio', 'tracks', 'playlist', 'albums', 'artists',
      'downloads', 'download', 'media', 'files', 'documents', 'storage',
      'my music', 'my songs', 'audio files', 'music library',
    ];
    return commonFolders.contains(folderName.toLowerCase());
  }

  /// Comprehensive intelligent filename parsing
  /// Handles all common song filename patterns
  static ({List<String> artists, List<String> albums, String title})
      parseFilenameIntelligently(String cleanFileName) {
    
    // Step 1: Pre-process filename
    var processed = cleanFilename(cleanFileName);
    
    // Remove quality indicators
    processed = processed
        .replaceAll(RegExp(r'\([^)]*(MP3|FLAC|AAC|WAV|M4A|OGG|WMA|OPUS|AIFF|ALAC|160K|192K|256K|320K|VBR|CBR|Kbps|Bitrate)[^)]*\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\[[^\]]*(MP3|FLAC|AAC|WAV|M4A|OGG|WMA|OPUS|AIFF|ALAC|160K|192K|256K|320K|VBR|CBR|Kbps|Bitrate)[^\]]*\]', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Pattern 1: "Artist - Album - Song Title" (3 parts)
    var match = RegExp(r'^(.+?)\s*[-–—]\s*(.+?)\s*[-–—]\s*(.+)$').firstMatch(processed);
    if (match != null) {
      final part1 = match.group(1)?.trim() ?? '';
      final part2 = match.group(2)?.trim() ?? '';
      final part3 = match.group(3)?.trim() ?? '';
      
      // Try different combinations
      if (isValidArtistName(part1) && isValidAlbumName(part2) && isValidSongTitle(part3)) {
        return (artists: splitArtists(part1), albums: [part2], title: cleanTitle(part3));
      }
      if (isValidArtistName(part1) && isValidSongTitle(part2) && isValidSongTitle(part3)) {
        // Part 2 might be subtitle or part of title
        return (artists: splitArtists(part1), albums: [], title: cleanTitle('$part2 $part3'));
      }
    }

    // Pattern 2: "Song Title - Artist1 _ Artist2 _ Artist3" (title first, then artists with underscores)
    match = RegExp(r'^(.+?)\s*[-–—]\s*(.+)$').firstMatch(processed);
    if (match != null) {
      final firstPart = match.group(1)?.trim() ?? '';
      final secondPart = match.group(2)?.trim() ?? '';
      
      // Check if first part is a title (short, no underscores, no artist indicators)
      final isLikelyTitle = isValidSongTitle(firstPart) && 
          !firstPart.contains('_') &&
          firstPart.split(' ').length <= 8 &&
          !containsArtistIndicators(firstPart.toLowerCase());
      
      if (isLikelyTitle) {
        // Second part might contain artists
        if (secondPart.contains('_')) {
          // Remove keywords like "Video", "Official" from start
          var cleanedSecond = secondPart.replaceFirst(
            RegExp(r'^(Video|Official|Lyric|HD|4K|1080p|720p|Remix|Cover|Version|Music|Audio|Song|Track)\s*[-–—]?\s*', caseSensitive: false), 
            ''
          );
          
          // Extract artists from underscore-separated parts
          final artistCandidates = cleanedSecond
              .split(RegExp(r'\s*_\s*'))
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .where((s) {
                // Remove quality indicators and validate
                final cleaned = s
                    .replaceAll(RegExp(r'\([^)]*(MP3|FLAC|AAC|WAV|M4A|OGG|WMA|OPUS|AIFF|ALAC|160K|192K|256K|320K|VBR|CBR|Kbps|Bitrate)[^)]*\)', caseSensitive: false), '')
                    .replaceAll(RegExp(r'\[[^\]]*(MP3|FLAC|AAC|WAV|M4A|OGG|WMA|OPUS|AIFF|ALAC|160K|192K|256K|320K|VBR|CBR|Kbps|Bitrate)[^\]]*\]', caseSensitive: false), '')
                    .trim();
                return cleaned.isNotEmpty && isValidArtistName(cleaned);
              })
              .map((s) {
                // Clean each artist name
                return s
                    .replaceAll(RegExp(r'\([^)]*(MP3|FLAC|AAC|WAV|M4A|OGG|WMA|OPUS|AIFF|ALAC|160K|192K|256K|320K|VBR|CBR|Kbps|Bitrate)[^)]*\)', caseSensitive: false), '')
                    .replaceAll(RegExp(r'\[[^\]]*(MP3|FLAC|AAC|WAV|M4A|OGG|WMA|OPUS|AIFF|ALAC|160K|192K|256K|320K|VBR|CBR|Kbps|Bitrate)[^\]]*\]', caseSensitive: false), '')
                    .trim();
              })
              .where((s) => s.isNotEmpty)
              .toList();
          
          if (artistCandidates.isNotEmpty) {
            return (artists: artistCandidates, albums: [], title: cleanTitle(firstPart));
          }
        }
        
        // Second part might be a single artist or multiple artists with other separators
        if (isValidArtistName(secondPart) || secondPart.contains(RegExp(r'[&,;]'))) {
          final artists = splitArtists(secondPart);
          if (artists.isNotEmpty && artists.first != 'Unknown Artist') {
            return (artists: artists, albums: [], title: cleanTitle(firstPart));
          }
        }
        
        // Just use first part as title
        return (artists: [], albums: [], title: cleanTitle(firstPart));
      }
      
      // Traditional "Artist - Song Title" pattern
      if (isValidArtistName(firstPart) && isValidSongTitle(secondPart)) {
        return (artists: splitArtists(firstPart), albums: [], title: cleanTitle(secondPart));
      }
      
      // "Album - Song Title" pattern
      if (isValidAlbumName(firstPart) && isValidSongTitle(secondPart)) {
        return (artists: [], albums: [firstPart], title: cleanTitle(secondPart));
      }
    }

    // Pattern 3: "Song Title _ Artist1 _ Artist2" (underscore separator, title first)
    match = RegExp(r'^(.+?)\s*_\s*(.+)$').firstMatch(processed);
    if (match != null) {
      final firstPart = match.group(1)?.trim() ?? '';
      final restPart = match.group(2)?.trim() ?? '';
      
      if (isValidSongTitle(firstPart) && !containsArtistIndicators(firstPart.toLowerCase())) {
        final artistCandidates = restPart.split(RegExp(r'\s*_\s*'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty && isValidArtistName(s))
            .toList();
        
        if (artistCandidates.isNotEmpty) {
          return (artists: artistCandidates, albums: [], title: cleanTitle(firstPart));
        }
      }
    }

    // Pattern 4: "Artist _ Song Title" (underscore separator, artist first)
    match = RegExp(r'^(.+?)\s*_\s*(.+)$').firstMatch(processed);
    if (match != null) {
      final firstPart = match.group(1)?.trim() ?? '';
      final secondPart = match.group(2)?.trim() ?? '';
      
      if (isValidArtistName(firstPart) && isValidSongTitle(secondPart)) {
        return (artists: splitArtists(firstPart), albums: [], title: cleanTitle(secondPart));
      }
    }

    // Pattern 5: "Song Title by Artist"
    match = RegExp(r'^(.+?)\s+by\s+(.+)$', caseSensitive: false).firstMatch(processed);
    if (match != null) {
      final titlePart = match.group(1)?.trim() ?? '';
      final artistPart = match.group(2)?.trim() ?? '';
      if (isValidSongTitle(titlePart) && isValidArtistName(artistPart)) {
        return (artists: splitArtists(artistPart), albums: [], title: cleanTitle(titlePart));
      }
    }

    // Pattern 6: "Artist - Song Title (feat. Other Artist)"
    match = RegExp(r'^(.+?)\s*[-–—]\s*(.+?)\s*\([^)]*(feat|featuring|ft)[^)]*\)', caseSensitive: false).firstMatch(processed);
    if (match != null) {
      final artistPart = match.group(1)?.trim() ?? '';
      final titlePart = match.group(2)?.trim() ?? '';
      if (isValidArtistName(artistPart) && isValidSongTitle(titlePart)) {
        // Extract featured artists from parentheses
        final featMatch = RegExp(r'\([^)]*(feat|featuring|ft)[^)]*\)', caseSensitive: false).firstMatch(processed);
        if (featMatch != null) {
          final featText = featMatch.group(0) ?? '';
          final featArtists = splitArtists(featText.replaceAll(RegExp(r'[()\[\]]'), ''));
          final allArtists = [...splitArtists(artistPart), ...featArtists];
          return (artists: allArtists, albums: [], title: cleanTitle(titlePart));
        }
        return (artists: splitArtists(artistPart), albums: [], title: cleanTitle(titlePart));
      }
    }

    // Pattern 7: "TrackNumber. Artist - Song Title"
    match = RegExp(r'^\d+\.?\s*(.+?)\s*[-–—]\s*(.+)$').firstMatch(processed);
    if (match != null) {
      final artistPart = match.group(1)?.trim() ?? '';
      final titlePart = match.group(2)?.trim() ?? '';
      if (isValidArtistName(artistPart) && isValidSongTitle(titlePart)) {
        return (artists: splitArtists(artistPart), albums: [], title: cleanTitle(titlePart));
      }
    }

    // Pattern 8: "Song Title (Year)" or "Artist - Song Title (Year)"
    match = RegExp(r'^(.+?)\s*\((\d{4})\)$').firstMatch(processed);
    if (match != null) {
      final mainPart = match.group(1)?.trim() ?? '';
      // Try to parse main part
      final subMatch = RegExp(r'^(.+?)\s*[-–—]\s*(.+)$').firstMatch(mainPart);
      if (subMatch != null) {
        final part1 = subMatch.group(1)?.trim() ?? '';
        final part2 = subMatch.group(2)?.trim() ?? '';
        if (isValidArtistName(part1) && isValidSongTitle(part2)) {
          return (artists: splitArtists(part1), albums: [], title: cleanTitle(part2));
        }
      }
      return (artists: [], albums: [], title: cleanTitle(mainPart));
    }

    // Fallback: return the filename as title (cleaned)
    return (artists: [], albums: [], title: cleanTitle(processed));
  }
  
  /// Clean title by removing quality indicators and technical info
  static String cleanTitle(String title) {
    if (title.isEmpty) return 'Unknown Title';
    
    var cleaned = title;
    
    // Remove quality indicators in parentheses and brackets
    cleaned = cleaned.replaceAll(
      RegExp(r'\([^)]*(MP3|FLAC|AAC|WAV|M4A|OGG|WMA|OPUS|AIFF|ALAC|160K|192K|256K|320K|VBR|CBR|Kbps|Bitrate|Video|Official|Explicit|Clean|Radio Edit|Lyric|HD|4K|1080p|720p|480p|360p|Remix|Cover|Version|Live|Studio|Demo|Unreleased|Leak|Bootleg|Karaoke|Instrumental|Acoustic)[^)]*\)', caseSensitive: false), 
      ''
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'\[[^\]]*(MP3|FLAC|AAC|WAV|M4A|OGG|WMA|OPUS|AIFF|ALAC|160K|192K|256K|320K|VBR|CBR|Kbps|Bitrate|Video|Official|Explicit|Clean|Radio Edit|Lyric|HD|4K|1080p|720p|480p|360p|Remix|Cover|Version|Live|Studio|Demo|Unreleased|Leak|Bootleg|Karaoke|Instrumental|Acoustic)[^\]]*\]', caseSensitive: false), 
      ''
    );
    
    // Remove standalone quality keywords
    cleaned = cleaned.replaceAll(
      RegExp(r'\s*[-–—]?\s*(Video|Official|Lyric|HD|4K|1080p|720p|480p|360p|Remix|Cover|Version|Live|Studio|Demo|Unreleased|Leak|Bootleg|Karaoke|Instrumental|Acoustic)\s*[-–—]?\s*', caseSensitive: false), 
      ' '
    );
    
    // Normalize whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return cleaned.isEmpty ? 'Unknown Title' : cleaned;
  }
}

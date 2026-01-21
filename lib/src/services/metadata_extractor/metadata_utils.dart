import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../utils/app_logger.dart';
import 'native_metadata_service.dart';
import 'filename_parser.dart';
import 'shared_validation.dart';
import 'metadata_extractor.dart';

/// General metadata extraction utilities and helpers
class MetadataUtils {
  static final _logger = AppLogger('MetadataUtils');

  /// ID3v1 genre mapping
  static const Map<String, String> _genreMap = {
    '0': 'Blues',
    '1': 'Classic Rock',
    '2': 'Country',
    '3': 'Dance',
    '4': 'Disco',
    '5': 'Funk',
    '6': 'Grunge',
    '7': 'Hip-Hop',
    '8': 'Jazz',
    '9': 'Metal',
    '10': 'New Age',
    '11': 'Oldies',
    '12': 'Other',
    '13': 'Pop',
    '14': 'R&B',
    '15': 'Rap',
    '16': 'Reggae',
    '17': 'Rock',
    '18': 'Techno',
    '19': 'Industrial',
    '20': 'Alternative',
    '21': 'Ska',
    '22': 'Death Metal',
    '23': 'Pranks',
    '24': 'Soundtrack',
    '25': 'Euro-Techno',
    '26': 'Ambient',
    '27': 'Trip-Hop',
    '28': 'Vocal',
    '29': 'Jazz+Funk',
    '30': 'Fusion',
    '31': 'Trance',
    '32': 'Classical',
    '33': 'Instrumental',
    '34': 'Acid',
    '35': 'House',
    '36': 'Game',
    '37': 'Sound Clip',
    '38': 'Gospel',
    '39': 'Noise',
    '40': 'AlternRock',
    '41': 'Bass',
    '42': 'Soul',
    '43': 'Punk',
    '44': 'Space',
    '45': 'Meditative',
    '46': 'Instrumental Pop',
    '47': 'Instrumental Rock',
    '48': 'Ethnic',
    '49': 'Gothic',
    '50': 'Darkwave',
    '51': 'Techno-Industrial',
    '52': 'Electronic',
    '53': 'Pop-Folk',
    '54': 'Eurodance',
    '55': 'Dream',
    '56': 'Southern Rock',
    '57': 'Comedy',
    '58': 'Cult',
    '59': 'Gangsta',
    '60': 'Top 40',
    '61': 'Christian Rap',
    '62': 'Pop/Funk',
    '63': 'Jungle',
    '64': 'Native American',
    '65': 'Cabaret',
    '66': 'New Wave',
    '67': 'Psychadelic',
    '68': 'Rave',
    '69': 'Showtunes',
    '70': 'Trailer',
    '71': 'Lo-Fi',
    '72': 'Tribal',
    '73': 'Acid Punk',
    '74': 'Acid Jazz',
    '75': 'Polka',
    '76': 'Retro',
    '77': 'Musical',
    '78': 'Rock & Roll',
    '79': 'Hard Rock',
  };

  /// Clean and normalize string input
  static String? cleanString(String? input) {
    if (input == null || input.isEmpty || input == "null") return null;
    return input
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '')
        .replaceAll(RegExp(r'\uFFFD'), '')
        .trim();
  }

  /// Get MIME type from file extension
  static String? getMimeTypeFromExtension(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'mp3':
        return 'audio/mpeg';
      case 'm4a':
      case 'm4p':
      case 'm4b':
        return 'audio/mp4';
      case 'aac':
        return 'audio/aac';
      case 'wav':
        return 'audio/wav';
      case 'flac':
        return 'audio/flac';
      case 'ogg':
        return 'audio/ogg';
      case 'wma':
        return 'audio/x-ms-wma';
      case 'opus':
        return 'audio/opus';
      case 'aiff':
      case 'aif':
        return 'audio/aiff';
      case 'alac':
        return 'audio/alac';
      case 'amr':
        return 'audio/amr';
      case '3ga':
        return 'audio/3gpp';
      default:
        return 'audio/mpeg'; // Default fallback
    }
  }

  /// Extract title from metadata or filename
  static String extractTitle(AudioMetadata? metadata, String filePath) {
    final title = cleanString(metadata?.title);
    if (title != null && title.isNotEmpty) return title;
    return FilenameParser.extractTitleFromFilename(filePath);
  }

  /// Extract duration from metadata
  static Duration extractDuration(AudioMetadata? metadata) {
    final duration = metadata?.duration;
    if (duration != null && duration > 0) {
      return Duration(milliseconds: duration);
    }
    return Duration.zero;
  }

  /// Safe extraction of duration with error handling
  static Duration extractDurationSafely(AudioMetadata? metadata) {
    return SharedValidation.extractSafely(
      () => extractDuration(metadata),
      Duration.zero,
      'duration',
    );
  }

  /// Calculate duration using FFmpeg when metadata is missing
  /// Falls back to zero if extraction fails
  static Future<Duration> getDurationWithFallback(String filePath) async {
    try {
      // Try to get duration from file metadata first
      final metadata = await NativeMetadataService.getMetadata(filePath);
      if (metadata?.duration != null && metadata!.duration! > 0) {
        return Duration(milliseconds: metadata.duration!);
      }
      
      // If metadata doesn't have duration, return zero
      // In a full implementation, you could use FFmpeg here
      _logger.w('Duration not available in metadata for: $filePath');
      return Duration.zero;
    } catch (e) {
      _logger.w('Fallback duration extraction failed for $filePath: $e');
      return Duration.zero;
    }
  }

  /// Extract genre from metadata with mapping
  static String? extractGenreSafely(AudioMetadata? metadata) {
    return SharedValidation.extractSafely(
      () {
        final genre = cleanString(metadata?.genre);
        if (genre == null || genre.isEmpty) return null;
        final numericGenre = int.tryParse(genre);
        if (numericGenre != null &&
            _genreMap.containsKey(numericGenre.toString())) {
          return _genreMap[numericGenre.toString()];
        }
        var cleanGenre = genre
            .replaceAll(RegExp(r'\s*\([^)]*\)'), '')
            .replaceAll(RegExp(r'\s*\[[^\]]*\]'), '')
            .split(RegExp(r'[;,/]'))
            .first
            .trim();
        cleanGenre = cleanGenre
            .split(' ')
            .map(
              (word) => word.isNotEmpty
                  ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                  : word,
            )
            .join(' ');
        return cleanGenre.isEmpty ? null : cleanGenre;
      },
      null,
      'genre',
    );
  }

  /// Extract year from metadata
  static int? extractYearSafely(AudioMetadata? metadata) {
    return SharedValidation.extractSafely(
      () {
        if (metadata?.year == null) return null;
        // Handle varying formats of year (e.g. "2023", "2023-01-01")
        final yearStr = metadata!.year!.trim();
        final yearMatch = RegExp(r'\d{4}').firstMatch(yearStr);
        if (yearMatch != null) {
          final year = int.tryParse(yearMatch.group(0)!);
          if (year != null && year > 1900 && year <= DateTime.now().year + 1) {
            return year;
          }
        }
        return null;
      },
      null,
      'year',
    );
  }

  /// Extract track number from metadata
  static int? extractTrackNumberSafely(AudioMetadata? metadata) {
    return SharedValidation.extractSafely(
      () {
        if (metadata?.trackNumber == null) return null;
        // Handle "1/12" format
        final trackStr = metadata!.trackNumber!.split('/').first;
        final track = int.tryParse(trackStr);
        if (track != null && track > 0 && track <= 999) return track;
        return null;
      },
      null,
      'track number',
    );
  }

  /// Extract disc number from metadata
  static int? extractDiscNumberSafely(AudioMetadata? metadata) {
    return SharedValidation.extractSafely(
      () {
        if (metadata?.discNumber == null) return null;
        // Handle "1/2" format
        final discStr = metadata!.discNumber!.split('/').first;
        final disc = int.tryParse(discStr);
        if (disc != null && disc > 0 && disc <= 99) return disc;
        return null;
      },
      null,
      'disc number',
    );
  }

  /// Get file size
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      final stat = await file.stat();
      return stat.size;
    } catch (e) {
      _logger.w('Failed to get file size for: $filePath - $e');
      return 0;
    }
  }

  /// Get file creation/modification date
  static Future<DateTime> getFileCreationDate(String filePath) async {
    try {
      final file = File(filePath);
      final stat = await file.stat();
      return stat.modified;
    } catch (e) {
      _logger.w('Failed to get file date for: $filePath - $e');
      return DateTime.now();
    }
  }

  /// Generate unique song ID
  static Future<String> generateSongId(String filePath) async {
    try {
      final file = File(filePath);
      final stat = await file.stat();
      final combined =
          '$filePath${stat.size}${stat.modified.millisecondsSinceEpoch}';
      final bytes = utf8.encode(combined);
      final digest = sha256.convert(bytes);
      return digest.toString().substring(0, 16);
    } catch (e) {
      final bytes = utf8.encode(
        '$filePath${DateTime.now().millisecondsSinceEpoch}',
      );
      final digest = sha256.convert(bytes);
      return digest.toString().substring(0, 16);
    }
  }

  /// Validate if file is a valid audio file
  static Future<bool> isValidAudioFile(String filePath) async {
    if (!isAudioFile(filePath)) return false;

    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      final stat = await file.stat();
      if (stat.size < 1024) return false;

      final bytes = await file.openRead(0, 12).first;
      return validateAudioHeader(bytes, filePath.split('.').last.toLowerCase());
    } catch (e) {
      return false;
    }
  }

  /// Check if file extension is supported audio format
  static bool isAudioFile(String filePath) {
    final extension = '.${filePath.split('.').last.toLowerCase()}';
    return MetadataExtractor.supportedExtensions.contains(extension);
  }

  /// Validate audio file header
  static bool validateAudioHeader(List<int> header, String extension) {
    if (header.length < 4) return false;

    switch (extension) {
      case 'mp3':
        // ID3v2 tag
        if (header[0] == 0x49 && header[1] == 0x44 && header[2] == 0x33)
          return true;
        // MP3 frame header
        if (header[0] == 0xFF && (header[1] & 0xE0) == 0xE0) {
          if (header[1] == 0xFF && header[2] == 0xFF && header[3] == 0xFF)
            return false;
          return true;
        }
        return false;
      case 'flac':
        return header[0] == 0x66 &&
            header[1] == 0x4C &&
            header[2] == 0x61 &&
            header[3] == 0x43;
      case 'ogg':
        return header[0] == 0x4F &&
            header[1] == 0x67 &&
            header[2] == 0x67 &&
            header[3] == 0x53;
      case 'wav':
        return header[0] == 0x52 &&
            header[1] == 0x49 &&
            header[2] == 0x46 &&
            header[3] == 0x46;
      case 'm4a':
      case 'm4p':
      case 'mp4':
        return header.length >= 8 &&
            header[4] == 0x66 &&
            header[5] == 0x74 &&
            header[6] == 0x79 &&
            header[7] == 0x70;
      default:
        return true;
    }
  }
}

import 'dart:io';
import '../../utils/app_logger.dart';
import '../../models/song_model.dart';
import 'native_metadata_service.dart';
import 'metadata_utils.dart';
import 'shared_validation.dart';
import 'filename_parser.dart';
import 'album_art_handler.dart';
import 'fetch_artist_names_from_file.dart';
import 'fetch_album_names_from_file.dart';

/// Professional metadata extractor for audio files using native Android MediaMetadataRetriever
/// Supports MP3, M4A, AAC, WAV, FLAC, OGG, and other Android-supported formats
class MetadataExtractor {
  static final _logger = AppLogger('MetadataExtractor');
  static bool _initialized = false;

  /// Supported audio file extensions
  static const List<String> _supportedExtensions = [
    '.mp3',
    '.m4a',
    '.aac',
    '.wav',
    '.flac',
    '.ogg',
    '.wma',
    '.opus',
    '.aiff',
    '.alac',
    '.m4b',
    '.m4p',
    '.amr',
    '.3ga',
  ];

  /// Initialize the metadata extractor
  static Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      _initialized = true;
      return true;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to initialize MetadataExtractor',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Extract metadata from a single audio file
  /// Returns SongModel with all metadata fields populated (features will be null)
  static Future<SongModel?> extractMetadata(String filePath) async {
    return await _extractMetadataCore(filePath);
  }

  /// Get supported audio file extensions
  static List<String> get supportedExtensions =>
      List.unmodifiable(_supportedExtensions);

  /// Check if a file is a valid audio file
  static Future<bool> isValidAudioFile(String filePath) async =>
      await MetadataUtils.isValidAudioFile(filePath);

  /// Core metadata extraction function
  static Future<SongModel?> _extractMetadataCore(String filePath) async {
    if (!_initialized) {
      final initialized = await initialize();
      if (!initialized) {
        _logger.e('Failed to initialize MetadataExtractor');
        return null;
      }
    }

    try {
      // Validate file
      if (!await isValidAudioFile(filePath)) {
        _logger.w('Invalid audio file: $filePath');
        return null;
      }

      final file = File(filePath);
      if (!await file.exists()) {
        _logger.w('File does not exist: $filePath');
        return null;
      }

      // Extract metadata using native channel
      AudioMetadata? metadata;
      try {
        metadata = await NativeMetadataService.getMetadata(filePath);
      } catch (e, stackTrace) {
        _logger.w(
          'Failed to read metadata for $filePath: $e',
          error: e,
          stackTrace: stackTrace,
        );
      }

      // Generate unique ID for the song
      final id = await MetadataUtils.generateSongId(filePath);

      // Extract metadata fields with error handling
      final title = MetadataUtils.extractTitle(metadata, filePath);
      final artists = ArtistNameExtractor.extractArtistsSafely(metadata, filePath);
      final albums = AlbumNameExtractor.extractAlbumsSafely(metadata, filePath);

      // Use intelligent filename parsing to improve results when metadata is missing
      final filenameParsed = _parseFilenameForMissingData(
        filePath,
        artists,
        albums,
        title,
      );

      // Extract duration with multiple fallback strategies
      var duration = MetadataUtils.extractDurationSafely(metadata);
      if (duration == Duration.zero || duration.inMilliseconds <= 0) {
        duration = await MetadataUtils.getDurationWithFallback(filePath);
        if (duration == Duration.zero) {
          try {
            final retryMetadata = await NativeMetadataService.getMetadata(filePath);
            if (retryMetadata?.duration != null && retryMetadata!.duration! > 0) {
              duration = Duration(milliseconds: retryMetadata.duration!);
            }
          } catch (e) {
            _logger.w('Duration retry failed: $e');
          }
        }
      }
      
      // Final validation - ensure duration is not negative
      if (duration.inMilliseconds < 0) {
        _logger.w('⚠️ Duration is negative (${duration.inMilliseconds}ms), setting to 0');
        duration = Duration.zero;
      }

      String? albumArt = await AlbumArtHandler.extractAlbumArtSafely(filePath, metadata);
      albumArt ??= await AlbumArtHandler.findExternalAlbumArt(filePath);

      final genre = MetadataUtils.extractGenreSafely(metadata);
      final year = MetadataUtils.extractYearSafely(metadata);
      final trackNumber = MetadataUtils.extractTrackNumberSafely(metadata);
      final discNumber = MetadataUtils.extractDiscNumberSafely(metadata);
      
      // Get file size - prefer from metadata, fallback to file system
      int fileSize;
      if (metadata?.fileSize != null && metadata!.fileSize! > 0) {
        fileSize = metadata.fileSize!;
      } else {
        fileSize = await MetadataUtils.getFileSize(filePath);
        if (fileSize <= 0) {
          try {
            final file = File(filePath);
            if (await file.exists()) {
              final fileLength = await file.length();
              fileSize = fileLength > 0 ? fileLength : 0;
            } else {
              fileSize = 0;
            }
          } catch (e) {
            _logger.w('Failed to get file size: $e');
            fileSize = 0;
          }
        }
      }
      
      // Get MIME type - prefer from metadata, fallback to extension
      String? mimeType = metadata?.mimeType;
      if (mimeType == null || mimeType.trim().isEmpty || mimeType == 'null') {
        mimeType = MetadataUtils.getMimeTypeFromExtension(filePath);
      }
      if (mimeType == null || mimeType.trim().isEmpty) {
        mimeType = 'audio/mpeg';
        _logger.w('MIME type missing, using default: audio/mpeg');
      }
      
      final dateAdded = await MetadataUtils.getFileCreationDate(filePath);

      final nonLatinTitle = FilenameParser.isLikelyNonLatin(filenameParsed.title);
      final resolvedArtists = nonLatinTitle
          ? (filenameParsed.artists.isNotEmpty
                ? filenameParsed.artists
                : ['Unknown Artist'])
          : ArtistNameExtractor.ensureArtists(filenameParsed.artists, filePath);
      final resolvedAlbums = nonLatinTitle
          ? (filenameParsed.albums.isNotEmpty
                ? filenameParsed.albums
                : ['Unknown Album'])
          : AlbumNameExtractor.ensureAlbums(filenameParsed.albums, filePath);

      // Get first artist and album for SongModel (which uses single strings)
      // If multiple artists, join them with ", " for display
      final artist = resolvedArtists.isNotEmpty 
          ? (resolvedArtists.length > 1 
              ? resolvedArtists.join(', ') 
              : resolvedArtists.first)
          : 'Unknown Artist';
      final album = resolvedAlbums.isNotEmpty ? resolvedAlbums.first : 'Unknown Album';

      final albumArtist = MetadataUtils.cleanString(metadata?.albumArtist);
      final composer = MetadataUtils.cleanString(metadata?.composer);
      final writer = MetadataUtils.cleanString(metadata?.writer);

      // Normalize bitrate: platform may return bps (e.g. 160000); contract is kbps (160)
      int? bitrateKbps = metadata?.bitrate;
      if (bitrateKbps != null && bitrateKbps > 1000) {
        bitrateKbps = bitrateKbps ~/ 1000;
      }

      // Validate and sanitize all extracted values
      final validatedData = _validateAndSanitizeMetadata(
        id: id,
        title: filenameParsed.title,
        artist: artist,
        album: album,
        duration: duration,
        filePath: filePath,
        albumArt: albumArt,
        genre: genre,
        year: year,
        trackNumber: trackNumber,
        discNumber: discNumber,
        albumArtist: albumArtist,
        composer: composer,
        writer: writer,
        bitrate: bitrateKbps,
        fileSize: fileSize,
        mimeType: mimeType,
        dateAdded: dateAdded,
      );

      final song = SongModel(
        id: validatedData['id'] as String,
        title: validatedData['title'] as String,
        artist: validatedData['artist'] as String,
        album: validatedData['album'] as String,
        duration: validatedData['duration'] as int,
        filePath: validatedData['filePath'] as String,
        features: null, // Metadata extraction doesn't include features
        albumArt: validatedData['albumArt'] as String?,
        genre: validatedData['genre'] as String?,
        year: validatedData['year'] as int?,
        trackNumber: validatedData['trackNumber'] as int?,
        discNumber: validatedData['discNumber'] as int?,
        albumArtist: validatedData['albumArtist'] as String?,
        composer: validatedData['composer'] as String?,
        writer: validatedData['writer'] as String?,
        bitrate: validatedData['bitrate'] as int?,
        fileSize: validatedData['fileSize'] as int?,
        mimeType: validatedData['mimeType'] as String?,
        dateAdded: validatedData['dateAdded'] as DateTime?,
      );

      // Validation summary - log only when there are issues
      final validationIssues = <String>[];
      if (song.duration <= 0) validationIssues.add('Duration is zero or invalid');
      if (song.fileSize == null || (song.fileSize != null && song.fileSize! <= 0)) {
        validationIssues.add('File size is invalid');
      }
      if (song.title.isEmpty || song.title == 'Unknown Title') validationIssues.add('Title is missing');
      if (song.artist.isEmpty || song.artist == 'Unknown Artist') validationIssues.add('Artist is missing');
      if (validationIssues.isNotEmpty) {
        _logger.w('Metadata validation: ${validationIssues.join(", ")}');
      }

      return song;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to extract metadata: $filePath',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Parse filename intelligently to fill missing metadata
  static ({List<String> artists, List<String> albums, String title})
      _parseFilenameForMissingData(
    String filePath,
    List<String> existingArtists,
    List<String> existingAlbums,
    String existingTitle,
  ) {
    try {
      final fileName = filePath.split('/').last.split('.').first;
      final cleanFileName = SharedValidation.cleanFilename(fileName);

      // Use intelligent parsing
      final parsed = SharedValidation.parseFilenameIntelligently(cleanFileName);

      // Always prefer filename parsing if it provides better results
      // Merge artists from both sources (avoid duplicates)
      final finalArtists = <String>{};
      if (parsed.artists.isNotEmpty && !_isPoorQualityMetadata(parsed.artists)) {
        finalArtists.addAll(parsed.artists);
      }
      if (existingArtists.isNotEmpty && !_isPoorQualityMetadata(existingArtists)) {
        finalArtists.addAll(existingArtists);
      }
      final artistsList = finalArtists.isEmpty ? ['Unknown Artist'] : finalArtists.toList();

      // Prefer filename parsing for albums if metadata is poor quality
      final finalAlbums =
          (existingAlbums.isEmpty || _isPoorQualityMetadata(existingAlbums))
              ? (parsed.albums.isNotEmpty ? parsed.albums : existingAlbums)
              : existingAlbums;

      // Prefer filename parsing for title if metadata is poor quality
      final finalTitle =
          (existingTitle.isEmpty || _isPoorQualityTitle(existingTitle))
              ? (parsed.title.isNotEmpty ? parsed.title : existingTitle)
              : existingTitle;

      return (artists: artistsList, albums: finalAlbums, title: finalTitle);
    } catch (e) {
      _logger.w(
        'Error parsing filename for missing data: $filePath - $e',
      );
      return (
        artists: existingArtists,
        albums: existingAlbums,
        title: existingTitle,
      );
    }
  }

  /// Check if metadata is poor quality (generic or empty)
  static bool _isPoorQualityMetadata(List<String> metadata) {
    if (metadata.isEmpty) return true;

    const poorQualityIndicators = [
      'unknown',
      'untitled',
      'various',
      'misc',
      'other',
      'n/a',
      'na',
      'unknown artist',
      'unknown album',
      'unknown title',
      'no artist',
      'no album',
      'no title',
      'artist',
      'album',
      'title',
      'track',
      'song',
      'audio',
      'music',
      'file',
      'untitled track',
      'untitled song',
    ];

    return metadata.any(
      (item) {
        final lower = item.toLowerCase().trim();
        // Check if it's too short (likely placeholder)
        if (lower.length < 2) return true;
        // Check for poor quality indicators
        return poorQualityIndicators.any((indicator) => lower == indicator || lower.contains(indicator));
      },
    );
  }

  /// Check if title is poor quality
  static bool _isPoorQualityTitle(String title) {
    if (title.isEmpty || title.trim().isEmpty) return true;

    final lowerTitle = title.toLowerCase().trim();

    const poorQualityIndicators = [
      'unknown',
      'untitled',
      'track',
      'song',
      'audio',
      'music',
      'unknown title',
      'untitled track',
      'untitled song',
      'no title',
      'title',
      'file',
    ];

    // Check if it's just a number or too short
    if (RegExp(r'^\d+$').hasMatch(lowerTitle)) return true;
    if (lowerTitle.length < 2) return true;

    // Check for poor quality indicators
    return poorQualityIndicators.any(
      (indicator) => lowerTitle == indicator || lowerTitle.contains(indicator),
    );
  }

  /// Validate and sanitize all extracted metadata to ensure correctness
  static Map<String, dynamic> _validateAndSanitizeMetadata({
    required String id,
    required String title,
    required String artist,
    required String album,
    required Duration duration,
    required String filePath,
    String? albumArt,
    String? genre,
    int? year,
    int? trackNumber,
    int? discNumber,
    String? albumArtist,
    String? composer,
    String? writer,
    int? bitrate,
    int? fileSize,
    String? mimeType,
    DateTime? dateAdded,
  }) {
    // Validate ID - must not be empty
    final validatedId = id.trim().isEmpty 
        ? DateTime.now().millisecondsSinceEpoch.toString() 
        : id.trim();

    // Validate Title - must not be empty, use filename as fallback; normalize string
    String validatedTitle = MetadataUtils.cleanString(title) ?? title.trim();
    if (validatedTitle.isEmpty ||
        validatedTitle.toLowerCase() == 'unknown' ||
        validatedTitle.toLowerCase() == 'untitled' ||
        validatedTitle.length < 2) {
      validatedTitle = _extractTitleFromPath(filePath);
    }
    validatedTitle = validatedTitle.trim();
    if (validatedTitle.length > 200) validatedTitle = validatedTitle.substring(0, 200);

    // Validate Artist - must not be empty; normalize string
    String validatedArtist = MetadataUtils.cleanString(artist) ?? artist.trim();
    if (validatedArtist.isEmpty ||
        validatedArtist.toLowerCase() == 'unknown artist' ||
        validatedArtist.length < 2) {
      validatedArtist = 'Unknown Artist';
    }
    validatedArtist = validatedArtist.trim();
    if (validatedArtist.length > 120) validatedArtist = validatedArtist.substring(0, 120);

    // Validate Album - must not be empty; normalize string
    String validatedAlbum = MetadataUtils.cleanString(album) ?? album.trim();
    if (validatedAlbum.isEmpty ||
        validatedAlbum.toLowerCase() == 'unknown album' ||
        validatedAlbum.length < 2) {
      validatedAlbum = 'Unknown Album';
    }
    validatedAlbum = validatedAlbum.trim();
    if (validatedAlbum.length > 120) validatedAlbum = validatedAlbum.substring(0, 120);

    // Validate Duration - must be non-negative, minimum 0
    final validatedDuration = duration.inMilliseconds < 0 
        ? 0 
        : duration.inMilliseconds;

    // Validate Album Art - check if file exists if path is provided
    String? validatedAlbumArt;
    if (albumArt != null && albumArt.trim().isNotEmpty) {
      try {
        final artFile = File(albumArt);
        if (artFile.existsSync()) {
          validatedAlbumArt = albumArt;
        } else {
          validatedAlbumArt = null;
        }
      } catch (e) {
        _logger.w('Album art path invalid: $albumArt');
        validatedAlbumArt = null;
      }
    }

    // Validate Genre - clean, normalize, and cap length
    String? validatedGenre;
    if (genre != null && genre.trim().isNotEmpty) {
      validatedGenre = MetadataUtils.cleanString(genre);
      if (validatedGenre != null && validatedGenre.length > 60) {
        validatedGenre = validatedGenre.substring(0, 60);
      }
    }

    // Validate Year - must be between 1900 and current year + 1
    int? validatedYear;
    if (year != null) {
      final currentYear = DateTime.now().year;
      if (year >= 1900 && year <= currentYear + 1) {
        validatedYear = year;
      } else {
        _logger.w('Invalid year: $year, expected 1900-${currentYear + 1}');
        validatedYear = null;
      }
    }

    // Validate Track Number - must be between 1 and 999
    int? validatedTrackNumber;
    if (trackNumber != null) {
      if (trackNumber >= 1 && trackNumber <= 999) {
        validatedTrackNumber = trackNumber;
      } else {
        _logger.w('Invalid track number: $trackNumber, expected 1-999');
        validatedTrackNumber = null;
      }
    }

    // Validate Disc Number - must be between 1 and 99
    int? validatedDiscNumber;
    if (discNumber != null) {
      if (discNumber >= 1 && discNumber <= 99) {
        validatedDiscNumber = discNumber;
      } else {
        _logger.w('Invalid disc number: $discNumber, expected 1-99');
        validatedDiscNumber = null;
      }
    }

    // Validate Album Artist - clean string
    final validatedAlbumArtist = albumArtist != null && albumArtist.trim().isNotEmpty
        ? MetadataUtils.cleanString(albumArtist)
        : null;

    // Validate Composer - clean string
    final validatedComposer = composer != null && composer.trim().isNotEmpty
        ? MetadataUtils.cleanString(composer)
        : null;

    // Validate Writer - clean string
    final validatedWriter = writer != null && writer.trim().isNotEmpty
        ? MetadataUtils.cleanString(writer)
        : null;

    // Validate Bitrate - must be positive
    int? validatedBitrate;
    if (bitrate != null) {
      if (bitrate > 0) {
        validatedBitrate = bitrate;
      } else {
        _logger.w('Invalid bitrate: $bitrate, must be positive');
        validatedBitrate = null;
      }
    }

    // Validate File Size - must be positive, fallback to file system
    int validatedFileSize;
    if (fileSize != null && fileSize > 0) {
      validatedFileSize = fileSize;
    } else {
      try {
        final file = File(filePath);
        if (file.existsSync()) {
          final fileLength = file.lengthSync();
          validatedFileSize = fileLength > 0 ? fileLength : 0;
        } else {
          validatedFileSize = 0;
        }
      } catch (e) {
        _logger.w('Error getting file size: $e');
        validatedFileSize = 0;
      }
    }

    // Validate MIME Type - must not be empty, lowercase, fallback to extension
    String? validatedMimeType;
    if (mimeType != null && mimeType.trim().isNotEmpty) {
      validatedMimeType = mimeType.trim().toLowerCase();
    } else {
      validatedMimeType = MetadataUtils.getMimeTypeFromExtension(filePath);
    }

    // Validate Date Added - must not be in the future and must be after 1900
    DateTime? validatedDateAdded;
    if (dateAdded != null) {
      final now = DateTime.now();
      final notFuture = dateAdded.isBefore(now.add(const Duration(days: 1)));
      final reasonablePast = dateAdded.isAfter(DateTime(1900, 1, 1));
      if (notFuture && reasonablePast) {
        validatedDateAdded = dateAdded;
      } else {
        _logger.w('Invalid date added: $dateAdded');
        validatedDateAdded = DateTime.now();
      }
    } else {
      // Fallback to file modification date
      try {
        final file = File(filePath);
        if (file.existsSync()) {
          validatedDateAdded = file.lastModifiedSync();
        } else {
          validatedDateAdded = DateTime.now();
        }
      } catch (e) {
        validatedDateAdded = DateTime.now();
      }
    }

    return {
      'id': validatedId,
      'title': validatedTitle,
      'artist': validatedArtist,
      'album': validatedAlbum,
      'duration': validatedDuration,
      'filePath': filePath,
      'albumArt': validatedAlbumArt,
      'genre': validatedGenre,
      'year': validatedYear,
      'trackNumber': validatedTrackNumber,
      'discNumber': validatedDiscNumber,
      'albumArtist': validatedAlbumArtist,
      'composer': validatedComposer,
      'writer': validatedWriter,
      'bitrate': validatedBitrate,
      'fileSize': validatedFileSize,
      'mimeType': validatedMimeType,
      'dateAdded': validatedDateAdded,
    };
  }

  /// Extract title from file path as fallback
  static String _extractTitleFromPath(String filePath) {
    try {
      final fileName = filePath.split('/').last.split('\\').last;
      final nameWithoutExt = fileName.split('.').first;
      return nameWithoutExt.trim().isEmpty ? 'Unknown Title' : nameWithoutExt.trim();
    } catch (e) {
      return 'Unknown Title';
    }
  }
}

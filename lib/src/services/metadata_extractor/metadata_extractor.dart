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
      _logger.i('Initializing MetadataExtractor...');
      _initialized = true;
      _logger.i('MetadataExtractor initialization completed successfully');
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
      _logger.i('MetadataExtractor initializing on first use...');
      final initialized = await initialize();
      if (!initialized) {
        _logger.e('Failed to initialize MetadataExtractor');
        return null;
      }
    }

    try {
      _logger.d('Extracting metadata from: $filePath');

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
        if (metadata != null) {
          _logger.d('✅ Successfully read metadata from: $filePath');
        } else {
          _logger.d(
            '⚠️ Native metadata service returned null for: $filePath - will use filename parsing fallback',
          );
        }
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
        _logger.d('Duration is zero or invalid, trying fallback methods...');
        duration = await MetadataUtils.getDurationWithFallback(filePath);
        
        // If still zero, try to get from file system metadata
        if (duration == Duration.zero) {
          try {
            // Try one more time with native service (sometimes it works on retry)
            final retryMetadata = await NativeMetadataService.getMetadata(filePath);
            if (retryMetadata?.duration != null && retryMetadata!.duration! > 0) {
              duration = Duration(milliseconds: retryMetadata.duration!);
              _logger.d('✅ Duration extracted on retry: ${duration.inMilliseconds}ms');
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
        _logger.d('File size not in metadata or invalid, getting from file system...');
        fileSize = await MetadataUtils.getFileSize(filePath);
        
        // Final validation - ensure file size is valid
        if (fileSize <= 0) {
          try {
            final file = File(filePath);
            if (await file.exists()) {
              final fileLength = await file.length();
              if (fileLength > 0) {
                fileSize = fileLength;
                _logger.d('✅ File size obtained from file system: $fileSize bytes');
              } else {
                fileSize = 0;
              }
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
        _logger.d('MIME type not in metadata, using extension...');
        mimeType = MetadataUtils.getMimeTypeFromExtension(filePath);
      }
      
      // Final validation - ensure MIME type is not null
      if (mimeType == null || mimeType.trim().isEmpty) {
        mimeType = 'audio/mpeg'; // Safe default
        _logger.w('⚠️ MIME type is null, using default: $mimeType');
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
        bitrate: metadata?.bitrate,
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

      // Comprehensive logging of all extracted metadata (using validated data)
      _logger.i('✅ Successfully extracted and validated metadata for: ${song.title} by ${song.artist}');
      _logger.d('📋 Metadata Summary (All Fields Validated):');
      _logger.d('   ID: ${song.id}');
      _logger.d('   Title: ${song.title}');
      _logger.d('   Artist: ${song.artist}');
      _logger.d('   Album: ${song.album}');
      _logger.d('   Duration: ${song.duration}ms (${(song.duration / 1000).toStringAsFixed(1)}s)');
      _logger.d('   Album Art: ${song.albumArt ?? "N/A"}');
      _logger.d('   Genre: ${song.genre ?? "N/A"}');
      _logger.d('   Year: ${song.year ?? "N/A"}');
      _logger.d('   Track Number: ${song.trackNumber ?? "N/A"}');
      _logger.d('   Disc Number: ${song.discNumber ?? "N/A"}');
      _logger.d('   Album Artist: ${song.albumArtist ?? "N/A"}');
      _logger.d('   Composer: ${song.composer ?? "N/A"}');
      _logger.d('   Writer: ${song.writer ?? "N/A"}');
      _logger.d('   Bitrate: ${song.bitrate ?? "N/A"} kbps');
      final fileSizeMB = song.fileSize != null && song.fileSize! > 0
          ? (song.fileSize! / (1024 * 1024)).toStringAsFixed(2)
          : '0.00';
      _logger.d('   File Size: ${song.fileSize ?? 0} bytes ($fileSizeMB MB)');
      _logger.d('   MIME Type: ${song.mimeType ?? "N/A"}');
      _logger.d('   Date Added: ${song.dateAdded ?? "N/A"}');
      
      // Validation summary
      final validationIssues = <String>[];
      if (song.duration <= 0) validationIssues.add('Duration is zero or invalid');
      if (song.fileSize == null || (song.fileSize != null && song.fileSize! <= 0)) {
        validationIssues.add('File size is invalid');
      }
      if (song.title.isEmpty || song.title == 'Unknown Title') validationIssues.add('Title is missing');
      if (song.artist.isEmpty || song.artist == 'Unknown Artist') validationIssues.add('Artist is missing');
      
      if (validationIssues.isNotEmpty) {
        _logger.w('⚠️ Validation warnings: ${validationIssues.join(", ")}');
      } else {
        _logger.d('✅ All metadata fields validated successfully');
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

    // Validate Title - must not be empty, use filename as fallback
    String validatedTitle = title.trim();
    if (validatedTitle.isEmpty || 
        validatedTitle.toLowerCase() == 'unknown' ||
        validatedTitle.toLowerCase() == 'untitled' ||
        validatedTitle.length < 2) {
      validatedTitle = _extractTitleFromPath(filePath);
      _logger.d('Title was empty or invalid, using filename: $validatedTitle');
    }

    // Validate Artist - must not be empty
    String validatedArtist = artist.trim();
    if (validatedArtist.isEmpty || 
        validatedArtist.toLowerCase() == 'unknown artist' ||
        validatedArtist.length < 2) {
      validatedArtist = 'Unknown Artist';
      _logger.d('Artist was empty or invalid, using default: $validatedArtist');
    }

    // Validate Album - must not be empty
    String validatedAlbum = album.trim();
    if (validatedAlbum.isEmpty || 
        validatedAlbum.toLowerCase() == 'unknown album' ||
        validatedAlbum.length < 2) {
      validatedAlbum = 'Unknown Album';
      _logger.d('Album was empty or invalid, using default: $validatedAlbum');
    }

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
          _logger.w('Album art file does not exist: $albumArt');
          validatedAlbumArt = null;
        }
      } catch (e) {
        _logger.w('Error validating album art path: $albumArt - $e');
        validatedAlbumArt = null;
      }
    }

    // Validate Genre - clean and validate
    final validatedGenre = genre != null && genre.trim().isNotEmpty 
        ? MetadataUtils.cleanString(genre) 
        : null;

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
          if (validatedFileSize > 0) {
            _logger.d('File size validated from file system: $validatedFileSize bytes');
          }
        } else {
          _logger.w('File does not exist for size validation: $filePath');
          validatedFileSize = 0;
        }
      } catch (e) {
        _logger.w('Error getting file size: $e');
        validatedFileSize = 0;
      }
    }

    // Validate MIME Type - must not be empty, fallback to extension
    String? validatedMimeType;
    if (mimeType != null && mimeType.trim().isNotEmpty) {
      validatedMimeType = mimeType.trim();
    } else {
      validatedMimeType = MetadataUtils.getMimeTypeFromExtension(filePath);
    }

    // Validate Date Added - must not be in the future
    DateTime? validatedDateAdded;
    if (dateAdded != null) {
      final now = DateTime.now();
      if (dateAdded.isBefore(now.add(const Duration(days: 1))) || 
          dateAdded.isAfter(DateTime(1900))) {
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

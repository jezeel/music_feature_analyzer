import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music_feature_analyzer/music_feature_analyzer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../utils/app_logger.dart';
import '../utils/app_utils.dart';
import 'song_detail_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static final AppLogger _logger = AppLogger('HomeScreen');

  bool _isInitialized = false;
  bool _isProcessingFeatures = false;
  List<SongModel> _songs = [];
  Map<String, ExtractedSongFeatures> _songFeatures = {};
  Map<String, bool> _extractingMetadata = {};
  Map<String, bool> _extractingFeatures = {};
  bool _isLoadingMetadata = false;

  static const int _maxSongs = 100;

  @override
  void initState() {
    super.initState();
    _requestPermissions().then((_) => _checkInitialization());
  }

  /// Request storage/audio permissions based on platform and Android version.
  /// Android 13+ (API 33+): READ_MEDIA_AUDIO. Android 12 and below: READ_EXTERNAL_STORAGE.
  /// iOS: Media Library (NSAppleMusicUsageDescription / NSMediaLibraryUsageDescription).
  Future<void> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        _logger.i('Android SDK: $sdkInt - requesting appropriate permission');
        if (sdkInt >= 33) {
          final status = await Permission.audio.request();
          if (status.isPermanentlyDenied) {
            _logger.w('Audio permission permanently denied - user may need to open app settings');
            await openAppSettings();
          } else if (status.isGranted) {
            _logger.i('READ_MEDIA_AUDIO granted (Android 13+)');
          }
        } else {
          final status = await Permission.storage.request();
          if (status.isPermanentlyDenied) {
            _logger.w('Storage permission permanently denied - user may need to open app settings');
            await openAppSettings();
          } else if (status.isGranted) {
            _logger.i('READ_EXTERNAL_STORAGE granted (Android 12-)');
          }
        }
      } else if (Platform.isIOS) {
        final status = await Permission.mediaLibrary.request();
        if (status.isPermanentlyDenied) {
          _logger.w('Media library permission permanently denied');
          await openAppSettings();
        } else if (status.isGranted) {
          _logger.i('Media library permission granted (iOS)');
        }
      }
    } catch (e) {
      _logger.e('Error requesting permissions: $e');
    }
  }

  void _checkInitialization() {
    setState(() {
      _isInitialized = MusicFeatureAnalyzer.isInitialized;
    });
    _logger.i('System status - Initialized: $_isInitialized');

    if (!_isInitialized) {
      _initializeAnalyzer();
    }
  }

  Future<void> _initializeAnalyzer() async {
    try {
      _logger.i('Initializing Music Feature Analyzer...');
      final success = await MusicFeatureAnalyzer.initialize();

      setState(() {
        _isInitialized = success;
      });

      if (success) {
        _logger.i('✅ Music Feature Analyzer initialized successfully');
      }
    } catch (e) {
      _logger.e('Initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Music Library',
          style: GoogleFonts.poppins(
            fontSize: 22.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          if (_songs.isNotEmpty && _isInitialized)
            IconButton(
              onPressed: _isProcessingFeatures ? null : _extractAllFeatures,
              icon: _isProcessingFeatures
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : Icon(Icons.psychology_outlined, size: 24.sp),
              tooltip: 'Extract AI Features',
            ),
        ],
      ),
      body: Stack(
        children: [
          _songs.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        itemCount: _songs.length,
                        itemBuilder: (context, index) {
                          final song = _songs[index];
                          final features = _songFeatures[song.id];
                          final isExtracting =
                              _extractingMetadata[song.filePath] ?? false;
                          return _buildSongCard(song, features, isExtracting);
                        },
                      ),
                    ),
                  ],
                ),
          if (_isLoadingMetadata) _buildLoadingOverlay(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _songs.length < _maxSongs ? _showSelectionDialog : null,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Add Songs',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note_outlined,
            size: 80.sp,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: 24.h),
          Text(
            'No songs yet',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the button below to add music files',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 56.w,
              height: 56.w,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Loading songs...',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Extracting metadata',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongCard(
    SongModel song,
    ExtractedSongFeatures? features,
    bool isExtracting,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showSongDetail(song, features),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              // Album Art
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: FutureBuilder<bool>(
                    future: song.albumArt != null
                        ? File(song.albumArt!).exists()
                        : Future.value(false),
                    builder: (context, snapshot) {
                      final hasArt = snapshot.data ?? false;
                      return hasArt
                          ? Image.file(
                              File(song.albumArt!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  AppUtils.buildAlbumArtPlaceholder(context),
                            )
                          : AppUtils.buildAlbumArtPlaceholder(context);
                    },
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Song Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      song.artist,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        if (song.album.isNotEmpty) ...[
                          Expanded(
                            child: Text(
                              song.album,
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '•',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                          ),
                          SizedBox(width: 8.w),
                        ],
                        Text(
                          AppUtils.formatDuration(song.duration),
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Status Indicator
              if (isExtracting)
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              else if (features != null)
                Icon(
                  Icons.check_circle_outline,
                  size: 20.sp,
                  color: Colors.green,
                )
              else
                IconButton(
                  onPressed: _isProcessingFeatures
                      ? null
                      : () => _extractSingleSongFeatures(song),
                  icon: Icon(Icons.psychology_outlined, size: 20.sp),
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.6),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Add Songs',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.music_note_rounded),
              title: const Text('Select Files'),
              onTap: () {
                Navigator.pop(context);
                _selectMusicFiles();
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_rounded),
              title: const Text('Select Folder'),
              onTap: () {
                Navigator.pop(context);
                _selectMusicFolder();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectMusicFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final remainingSlots = _maxSongs - _songs.length;
        final filePaths = result.files
            .where((file) => file.path != null)
            .map((file) => file.path!)
            .take(remainingSlots)
            .toList();

        setState(() => _isLoadingMetadata = true);
        await _extractMetadataForFiles(filePaths);
      }
    } catch (e) {
      _logger.e('Error selecting music files: $e');
      _showSnackBar('Error selecting files: $e', Colors.red);
      if (mounted) setState(() => _isLoadingMetadata = false);
    }
  }

  Future<void> _selectMusicFolder() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath();

      if (result != null) {
        final directory = Directory(result);
        final remainingSlots = _maxSongs - _songs.length;

        // Build list of audio file paths line by line (scan folder, optionally subfolders)
        final List<String> filePaths = [];
        await for (final entity in directory.list(recursive: true)) {
          if (filePaths.length >= remainingSlots) break;
          if (entity is File && _isAudioFile(entity.path)) {
            filePaths.add(entity.path);
            _logger.d('Found audio: ${entity.path}');
          }
        }

        if (filePaths.isEmpty) {
          _showSnackBar('No audio files found in this folder', Colors.orange);
          return;
        }

        _logger.i('Folder: ${filePaths.length} audio file(s) to process');
        setState(() => _isLoadingMetadata = true);
        await _extractMetadataForFiles(filePaths);
      }
    } catch (e) {
      _logger.e('Error selecting music folder: $e');
      _showSnackBar('Error selecting folder: $e', Colors.red);
      if (mounted) setState(() => _isLoadingMetadata = false);
    }
  }

  Future<void> _extractMetadataForFiles(List<String> filePaths) async {
    // Filter out existing songs and invalid paths
    final newFilePaths = filePaths
        .where(
          (filePath) =>
              filePath.isNotEmpty && !_songs.any((s) => s.filePath == filePath),
        )
        .toList();

    if (newFilePaths.isEmpty) {
      _logger.w('No new files to process');
      if (mounted) setState(() => _isLoadingMetadata = false);
      return;
    }

    // Mark all files as extracting
    if (mounted) {
      setState(() {
        for (final filePath in newFilePaths) {
          _extractingMetadata[filePath] = true;
        }
      });
    }

    try {
      _logger.i('📋 Extracting metadata for ${newFilePaths.length} file(s)...');

      // Use batch extraction: first get list of paths, then call metadata extractor with that list
      final songs = await MusicFeatureAnalyzer.extractMetadataBatch(
        newFilePaths,
      );

      if (mounted) {
        final List<SongModel> validSongs = [];

        // Validate and add songs (process result line by line)
        for (int i = 0; i < songs.length; i++) {
          final song = songs[i];
          final filePath = newFilePaths[i];

          if (song != null && _validateSong(song)) {
            validSongs.add(song);
            _logger.i('✅ Metadata extracted for: ${song.title}');
            _logMetadataValues(song);
          } else {
            _logger.w('⚠️ Invalid or null metadata for: $filePath');
          }

          setState(() {
            _extractingMetadata[filePath] = false;
          });
        }

        // After result: show the list of songs
        if (validSongs.isNotEmpty) {
          setState(() {
            _songs.addAll(validSongs);
            _isLoadingMetadata = false;
          });

          _logger.i('✅ Successfully added ${validSongs.length} song(s)');

          if (_isInitialized) {
            _logger.i(
              '🚀 Starting background feature extraction for ${validSongs.length} song(s)...',
            );
            _extractFeaturesInBackgroundForSongs(validSongs);
          } else {
            _logger.w(
              '⚠️ Analyzer not initialized - features will be extracted after initialization',
            );
            _initializeAnalyzer().then((_) {
              if (_isInitialized && validSongs.isNotEmpty) {
                _extractFeaturesInBackgroundForSongs(validSongs);
              }
            });
          }
        } else {
          setState(() => _isLoadingMetadata = false);
        }
      }
    } catch (e) {
      _logger.e('❌ Error extracting metadata: $e');
      if (mounted) {
        setState(() {
          for (final filePath in newFilePaths) {
            _extractingMetadata[filePath] = false;
          }
          _isLoadingMetadata = false;
        });
      }
      _showSnackBar('Error extracting metadata: $e', Colors.red);
    }
  }

  bool _validateSong(SongModel song) {
    // Validate required fields
    if (song.filePath.isEmpty) {
      _logger.w('⚠️ Song validation failed: filePath is empty');
      return false;
    }

    // Validate file exists
    try {
      final file = File(song.filePath);
      if (!file.existsSync()) {
        _logger.w(
          '⚠️ Song validation failed: file does not exist: ${song.filePath}',
        );
        return false;
      }
    } catch (e) {
      _logger.w('⚠️ Song validation failed: cannot check file existence: $e');
      return false;
    }

    // Validate title and artist (should not be empty, but allow "Unknown" as fallback)
    if (song.title.trim().isEmpty) {
      _logger.w(
        '⚠️ Song validation warning: title is empty for ${song.filePath}',
      );
    }

    if (song.artist.trim().isEmpty) {
      _logger.w(
        '⚠️ Song validation warning: artist is empty for ${song.filePath}',
      );
    }

    return true;
  }

  void _extractFeaturesInBackgroundForSongs(List<SongModel> songs) {
    if (!_isInitialized) {
      _logger.w('⚠️ Cannot extract features: analyzer not initialized');
      return;
    }

    if (songs.isEmpty) {
      return;
    }

    // Mark all songs as extracting
    setState(() {
      for (final song in songs) {
        _extractingFeatures[song.id] = true;
      }
    });

    // Extract features in background without blocking UI
    Future.microtask(() async {
      try {
        final filePaths = songs.map((s) => s.filePath).toList();
        _logger.i(
          '🎵 Starting background feature extraction for ${filePaths.length} song(s)...',
        );

        await MusicFeatureAnalyzer.extractFeaturesInBackground(
          filePaths,
          onProgress: (current, total) {
            _logger.d('📊 Feature extraction progress: $current/$total');
          },
          onSongUpdated: (filePath, features) =>
              _handleFeatureUpdate(filePath, features, songs),
          onCompleted: () {
            if (mounted) {
              setState(() {
                for (final song in songs) {
                  _extractingFeatures[song.id] = false;
                }
              });
              _logger.i('✅ Background feature extraction completed!');
              _showSnackBar('Features extracted successfully!', Colors.green);
            }
          },
          onError: (error) {
            _logger.e('❌ Feature extraction error: $error');
            if (mounted) {
              setState(() {
                for (final song in songs) {
                  _extractingFeatures[song.id] = false;
                }
              });
              _showSnackBar('Some features failed to extract', Colors.orange);
            }
          },
        );
      } catch (e) {
        _logger.e('❌ Background feature extraction failed: $e');
        if (mounted) {
          setState(() {
            for (final song in songs) {
              _extractingFeatures[song.id] = false;
            }
          });
          _showSnackBar('Feature extraction failed: $e', Colors.red);
        }
      }
    });
  }

  void _handleFeatureUpdate(
    String filePath,
    ExtractedSongFeatures? features, [
    List<SongModel>? fallbackSongs,
  ]) {
    if (features == null || !mounted) return;

    try {
      SongModel? song;
      try {
        song = _songs.firstWhere((s) => s.filePath == filePath);
      } catch (_) {
        song = fallbackSongs?.firstWhere(
          (s) => s.filePath == filePath,
          orElse: () => throw StateError('Song not found'),
        );
      }

      if (song != null && _validateFeatures(features)) {
        final validSong = song;
        setState(() {
          _songFeatures[validSong.id] = features;
          _extractingFeatures[validSong.id] = false;
        });
        _logger.i('✅ Features extracted for: ${validSong.title}');
        _logFeatureValues(features, validSong.title);
      } else if (song != null) {
        final invalidSong = song;
        setState(() {
          _extractingFeatures[invalidSong.id] = false;
        });
        _logger.w('⚠️ Invalid features for: ${invalidSong.title}');
      }
    } catch (e) {
      _logger.w('⚠️ Song not found for filePath: $filePath');
    }
  }

  bool _validateFeatures(ExtractedSongFeatures features) {
    // Validate that features are reasonable
    if (features.tempoBpm < 0 || features.tempoBpm > 300) {
      _logger.w('⚠️ Invalid tempo: ${features.tempoBpm} BPM');
      return false;
    }

    if (features.danceability < 0 || features.danceability > 1) {
      _logger.w('⚠️ Invalid danceability: ${features.danceability}');
      return false;
    }

    if (features.loudness < 0 || features.loudness > 1) {
      _logger.w('⚠️ Invalid loudness: ${features.loudness}');
      return false;
    }

    if (features.overallEnergy < 0 || features.overallEnergy > 1) {
      _logger.w('⚠️ Invalid energy: ${features.overallEnergy}');
      return false;
    }

    if (features.confidence < 0 || features.confidence > 1) {
      _logger.w('⚠️ Invalid confidence: ${features.confidence}');
      return false;
    }

    return true;
  }

  Future<void> _extractSingleSongFeatures(SongModel song) async {
    if (!_isInitialized) {
      _showSnackBar('Please wait for initialization', Colors.orange);
      // Try to initialize
      await _initializeAnalyzer();
      if (!_isInitialized) {
        _showSnackBar('Initialization failed. Please try again.', Colors.red);
        return;
      }
    }

    // Validate song before extraction
    if (!_validateSong(song)) {
      _showSnackBar('Invalid song data. Cannot extract features.', Colors.red);
      return;
    }

    // Mark as extracting
    setState(() {
      _extractingFeatures[song.id] = true;
    });

    try {
      _logger.i('🎵 Extracting features for: ${song.title}');
      final features = await MusicFeatureAnalyzer.analyzeSong(song);

      if (features != null && mounted) {
        if (_validateFeatures(features)) {
          final validSong = song;
          setState(() {
            _songFeatures[validSong.id] = features;
            _extractingFeatures[validSong.id] = false;
          });
          _logger.i('✅ Features extracted for: ${validSong.title}');
          _logFeatureValues(features, validSong.title);
          _showSnackBar('Features extracted successfully!', Colors.green);
        } else {
          final invalidSong = song;
          setState(() {
            _extractingFeatures[invalidSong.id] = false;
          });
          _logger.w('⚠️ Invalid features extracted for: ${invalidSong.title}');
          _showSnackBar(
            'Features extracted but validation failed',
            Colors.orange,
          );
        }
      } else {
        final noFeaturesSong = song;
        setState(() {
          _extractingFeatures[noFeaturesSong.id] = false;
        });
        _logger.w('⚠️ No features returned for: ${noFeaturesSong.title}');
        _showSnackBar('Failed to extract features', Colors.orange);
      }
    } catch (e) {
      _logger.e('❌ Error extracting features: $e');
      if (mounted) {
        final errorSong = song;
        setState(() {
          _extractingFeatures[errorSong.id] = false;
        });
        _showSnackBar('Error extracting features: $e', Colors.red);
      }
    }
  }

  Future<void> _extractAllFeatures() async {
    if (!_isInitialized) {
      _showSnackBar('Please wait for initialization', Colors.orange);
      // Try to initialize
      await _initializeAnalyzer();
      if (!_isInitialized) {
        _showSnackBar('Initialization failed. Please try again.', Colors.red);
        return;
      }
    }

    if (_songs.isEmpty) {
      _showSnackBar('No songs to process', Colors.orange);
      return;
    }

    // Filter valid songs
    final validSongs = _songs.where((s) => _validateSong(s)).toList();
    if (validSongs.isEmpty) {
      _showSnackBar('No valid songs to process', Colors.red);
      return;
    }

    setState(() {
      _isProcessingFeatures = true;
      for (final song in validSongs) {
        _extractingFeatures[song.id] = true;
      }
    });

    try {
      _logger.i('🎵 Extracting features for ${validSongs.length} song(s)');

      await MusicFeatureAnalyzer.extractFeaturesInBackground(
        validSongs.map((s) => s.filePath).toList(),
        onProgress: (current, total) {
          _logger.d('📊 Progress: $current/$total');
        },
        onSongUpdated: (filePath, features) {
          _handleFeatureUpdate(filePath, features, validSongs);
        },
        onCompleted: () {
          if (mounted) {
            setState(() {
              _isProcessingFeatures = false;
              for (final song in validSongs) {
                _extractingFeatures[song.id] = false;
              }
            });
            _showSnackBar('All features extracted!', Colors.green);
            _logger.i('✅ All features extraction completed!');
          }
        },
        onError: (error) {
          _logger.e('❌ Feature extraction error: $error');
          if (mounted) {
            setState(() {
              _isProcessingFeatures = false;
              for (final song in validSongs) {
                _extractingFeatures[song.id] = false;
              }
            });
            _showSnackBar('Some features failed to extract', Colors.orange);
          }
        },
      );
    } catch (e) {
      _logger.e('❌ Feature extraction failed: $e');
      if (mounted) {
        setState(() {
          _isProcessingFeatures = false;
          for (final song in validSongs) {
            _extractingFeatures[song.id] = false;
          }
        });
        _showSnackBar('Feature extraction failed: $e', Colors.red);
      }
    }
  }

  void _showSongDetail(SongModel song, ExtractedSongFeatures? features) {
    final isExtracting = _extractingFeatures[song.id] ?? false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SongDetailSheet(
        song: song,
        features: features,
        isExtractingFeatures: isExtracting,
        onExtractFeatures: features == null && !isExtracting
            ? () {
                Navigator.pop(context);
                _extractSingleSongFeatures(song);
              }
            : null,
      ),
    );
  }

  bool _isAudioFile(String path) {
    final extension = path.toLowerCase().split('.').last;
    return [
      'mp3',
      'wav',
      'flac',
      'm4a',
      'aac',
      'ogg',
      'wma',
      'opus',
      'aiff',
      'alac',
      'm4b',
      'm4p',
      'amr',
      '3ga',
    ].contains(extension);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _logMetadataValues(SongModel song) {
    _logger.i('📋 Metadata Values for: ${song.title}');
    _logger.d('ID: ${song.id}');
    _logger.d('Title: ${song.title}');
    _logger.d('Artist: ${song.artist}');
    _logger.d('Album: ${song.album}');
    _logger.d(
      'Duration: ${song.duration}ms (${AppUtils.formatDuration(song.duration)})',
    );
    _logger.d('File Path: ${song.filePath}');
    _logger.d('Album Art: ${song.albumArt ?? "N/A"}');
    _logger.d('Year: ${song.year ?? "N/A"}');
    _logger.d('Genre: ${song.genre ?? "N/A"}');
    _logger.d('Track Number: ${song.trackNumber ?? "N/A"}');
    _logger.d('Disc Number: ${song.discNumber ?? "N/A"}');
    _logger.d('Album Artist: ${song.albumArtist ?? "N/A"}');
    _logger.d('Composer: ${song.composer ?? "N/A"}');
    _logger.d('Writer: ${song.writer ?? "N/A"}');
    _logger.d(
      'Bitrate: ${song.bitrate != null ? "${song.bitrate} kbps" : "N/A"}',
    );
    _logger.d(
      'File Size: ${song.fileSize != null ? AppUtils.formatFileSize(song.fileSize!) : "N/A"}',
    );
    _logger.d('MIME Type: ${song.mimeType ?? "N/A"}');
    _logger.d(
      'Date Added: ${song.dateAdded != null ? AppUtils.formatDate(song.dateAdded!) : "N/A"}',
    );
  }

  void _logFeatureValues(ExtractedSongFeatures features, String songTitle) {
    _logger.i('🎵 Feature Values for: $songTitle');
    _logger.d(
      'Basic Features - Tempo: ${features.tempo}, Beat: ${features.beat}, Energy: ${features.energy}, Mood: ${features.mood}',
    );
    _logger.d(
      'Vocals: ${features.vocals ?? "N/A"}, Instruments: ${features.instruments.isEmpty ? "N/A" : features.instruments.join(", ")}',
    );
    _logger.d(
      'YAMNet - Genre: ${features.estimatedGenre}, Has Vocals: ${features.hasVocals}, Energy: ${features.yamnetEnergy.toStringAsFixed(3)}',
    );
    _logger.d(
      'YAMNet Instruments: ${features.yamnetInstruments.isEmpty ? "N/A" : features.yamnetInstruments.join(", ")}, Mood Tags: ${features.moodTags.isEmpty ? "N/A" : features.moodTags.join(", ")}',
    );
    _logger.d(
      'Signal Processing - Tempo BPM: ${features.tempoBpm.toStringAsFixed(1)}, Beat Strength: ${features.beatStrength.toStringAsFixed(3)}, Signal Energy: ${features.signalEnergy.toStringAsFixed(3)}',
    );
    _logger.d(
      'Brightness: ${features.brightness.toStringAsFixed(3)}, Danceability: ${features.danceability.toStringAsFixed(3)}, Loudness: ${features.loudness.toStringAsFixed(3)}',
    );
    _logger.d(
      'Combined Metrics - Overall Energy: ${features.overallEnergy.toStringAsFixed(3)}, Intensity: ${features.intensity.toStringAsFixed(3)}',
    );
    _logger.d(
      'Spectral Centroid: ${features.spectralCentroid.toStringAsFixed(2)} Hz, Spectral Rolloff: ${features.spectralRolloff.toStringAsFixed(2)} Hz',
    );
    _logger.d(
      'Zero Crossing Rate: ${features.zeroCrossingRate.toStringAsFixed(4)}, Spectral Flux: ${features.spectralFlux.toStringAsFixed(4)}',
    );
    _logger.d(
      'Complexity: ${features.complexity.toStringAsFixed(3)}, Valence: ${features.valence.toStringAsFixed(3)}, Arousal: ${features.arousal.toStringAsFixed(3)}',
    );
    _logger.d('Confidence: ${features.confidence.toStringAsFixed(3)}');
    _logger.d(
      'Analysis Metadata - Analyzed At: ${AppUtils.formatDate(features.analyzedAt)}, Version: ${features.analyzerVersion}',
    );
  }
}

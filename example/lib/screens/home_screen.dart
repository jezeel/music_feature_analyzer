import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music_feature_analyzer/music_feature_analyzer.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../utils/app_logger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static final AppLogger _logger = AppLogger('HomeScreen');

  bool _isInitialized = false;
  bool _isProcessingInBackground = false;
  List<SongModel> _selectedSongs = [];
  Map<String, ExtractedSongFeatures> _songFeatures = {};

  // Constants
  static const int _maxSongs = 100;

  @override
  void initState() {
    super.initState();
    _checkInitialization();
  }

  void _checkInitialization() {
    setState(() {
      _isInitialized = MusicFeatureAnalyzer.isInitialized;
    });
    _logger.i('System status - Initialized: $_isInitialized');

    // If not initialized, try to initialize
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
        _showSnackBar('✅ System ready for analysis!', Colors.green);
      } else {
        _logger.e('❌ Music Feature Analyzer initialization failed');
        _showSnackBar(
          '❌ Initialization failed - will retry later',
          Colors.orange,
        );
      }
    } catch (e) {
      _logger.e('Initialization error: $e');
      _showSnackBar('❌ Initialization error: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Music Feature Analyzer',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_selectedSongs.isNotEmpty)
            IconButton(
              onPressed: _extractAllFeatures,
              icon: const Icon(Icons.psychology_rounded),
              tooltip: 'AI Analyze All Songs',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            _buildWelcomeCard(),
            SizedBox(height: 30.h),

            // Upload Section
            _buildUploadSection(),
            SizedBox(height: 30.h),

            // Songs List
            if (_selectedSongs.isNotEmpty) _buildSongsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          Icon(Icons.analytics_rounded, size: 60.sp, color: Colors.white),
          SizedBox(height: 16.h),
          Text(
            'AI-Powered Music Analysis',
            style: GoogleFonts.poppins(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Extract 28+ musical features using YAMNet AI',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isProcessingInBackground
                    ? Icons.sync_rounded
                    : _isInitialized
                    ? Icons.check_circle_rounded
                    : Icons.schedule_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                _isProcessingInBackground
                    ? 'Processing in Background...'
                    : _isInitialized
                    ? 'System Ready'
                    : 'Model Loading...',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Music Files',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Select audio files or folder to analyze',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedSongs.length < _maxSongs
                        ? _selectMusicFiles
                        : null,
                    icon: const Icon(Icons.music_note_rounded),
                    label: const Text('Select Files'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectedSongs.length < _maxSongs
                        ? _selectMusicFolder
                        : null,
                    icon: const Icon(Icons.folder_rounded),
                    label: const Text('Select Folder'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedSongs.length >= _maxSongs) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_rounded, color: Colors.orange, size: 16.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Maximum $_maxSongs songs reached',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSongsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Songs (${_selectedSongs.length})',
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (_selectedSongs.isNotEmpty)
              IconButton(
                onPressed: _isProcessingInBackground
                    ? null
                    : _extractAllFeatures,
                icon: _isProcessingInBackground
                    ? const Icon(Icons.sync_rounded)
                    : const Icon(Icons.psychology_rounded),
                tooltip: _isProcessingInBackground
                    ? 'Processing in background...'
                    : 'AI Analyze All Songs',
                style: IconButton.styleFrom(
                  backgroundColor: _isProcessingInBackground
                      ? Colors.grey
                      : Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
        SizedBox(height: 16.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _selectedSongs.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final song = _selectedSongs[index];
            final features = _songFeatures[song.id];
            return _buildSongTile(song, features);
          },
        ),
      ],
    );
  }

  Widget _buildSongTile(SongModel song, ExtractedSongFeatures? features) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Song Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  song.title,
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  song.artist,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  _formatDuration(song.duration),
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          Row(
            children: [
              // AI Button
              IconButton(
                onPressed: _isProcessingInBackground
                    ? null
                    : () => _extractSingleSongFeatures(song),
                icon: _isProcessingInBackground
                    ? const Icon(Icons.sync_rounded)
                    : const Icon(Icons.psychology_rounded),
                tooltip: _isProcessingInBackground
                    ? 'Processing in background...'
                    : 'AI Analyze This Song',
                style: IconButton.styleFrom(
                  backgroundColor: _isProcessingInBackground
                      ? Colors.grey.withValues(alpha: 0.1)
                      : features != null
                      ? Colors.green.withValues(alpha: 0.1)
                      : Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                  foregroundColor: _isProcessingInBackground
                      ? Colors.grey
                      : features != null
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(width: 8.w),
              // Features Button
              IconButton(
                onPressed: features != null
                    ? () => _showFeaturePopup(song, features)
                    : null,
                icon: const Icon(Icons.arrow_forward_ios_rounded),
                tooltip: 'View Features',
                style: IconButton.styleFrom(
                  backgroundColor: features != null
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  foregroundColor: features != null
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFeaturePopup(SongModel song, ExtractedSongFeatures features) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.analytics_rounded,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            song.artist,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Features Grid
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: _buildFeaturesGrid(features),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid(ExtractedSongFeatures features) {
    final featureData = [
      {
        'name': 'Genre',
        'value': features.estimatedGenre,
        'color': Colors.purple,
        'icon': Icons.music_note_rounded,
      },
      {
        'name': 'Tempo',
        'value': '${features.tempoBpm.toStringAsFixed(0)} BPM',
        'color': Colors.blue,
        'icon': Icons.speed_rounded,
      },
      {
        'name': 'Energy',
        'value': features.energy,
        'color': Colors.orange,
        'icon': Icons.flash_on_rounded,
      },
      {
        'name': 'Mood',
        'value': features.mood,
        'color': Colors.green,
        'icon': Icons.sentiment_very_satisfied_rounded,
      },
      {
        'name': 'Danceability',
        'value': features.danceability.toStringAsFixed(2),
        'color': Colors.pink,
        'icon': Icons.music_note_rounded,
      },
      {
        'name': 'Confidence',
        'value': features.confidence.toStringAsFixed(2),
        'color': Colors.indigo,
        'icon': Icons.psychology_rounded,
      },
      {
        'name': 'Has Vocals',
        'value': features.hasVocals ? 'Yes' : 'No',
        'color': Colors.teal,
        'icon': Icons.mic_rounded,
      },
      {
        'name': 'Spectral Centroid',
        'value': features.spectralCentroid.toStringAsFixed(1),
        'color': Colors.cyan,
        'icon': Icons.trending_up_rounded,
      },
      {
        'name': 'Zero Crossing Rate',
        'value': features.zeroCrossingRate.toStringAsFixed(3),
        'color': Colors.amber,
        'icon': Icons.waves_rounded,
      },
      {
        'name': 'Spectral Rolloff',
        'value': features.spectralRolloff.toStringAsFixed(1),
        'color': Colors.deepOrange,
        'icon': Icons.show_chart_rounded,
      },
      {
        'name': 'Spectral Flux',
        'value': features.spectralFlux.toStringAsFixed(3),
        'color': Colors.lime,
        'icon': Icons.auto_graph_rounded,
      },
      {
        'name': 'Beat Strength',
        'value': features.beatStrength.toStringAsFixed(2),
        'color': Colors.red,
        'icon': Icons.trending_up_rounded,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 10.h,
        childAspectRatio: 6,
      ),
      itemCount: featureData.length,
      itemBuilder: (context, index) {
        final feature = featureData[index];
        final color = feature['color'] as Color;
        final icon = feature['icon'] as IconData;

        return Container(
          padding: EdgeInsets.all(7.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Icon(icon, size: 16.sp, color: color),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${feature['name'] as String}: ',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    feature['value'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _analyzeNewSongs(List<SongModel> newSongs) async {
    if (!_isInitialized) {
      _logger.w('System not initialized, skipping automatic analysis');
      return;
    }

    _logger.i(
      '🤖 Automatically analyzing ${newSongs.length} new songs in background...',
    );

    setState(() {
      _isProcessingInBackground = true;
    });

    try {
      await MusicFeatureAnalyzer.extractFeaturesInBackground(
        newSongs.map((s) => s.filePath).toList(),
        onProgress: (current, total) {
          _logger.d(
            '📊 Auto-analysis progress: $current/$total songs processed',
          );
        },
        onSongUpdated: (filePath, features) {
          _logger.d('🔄 Auto-analysis updated: ${filePath.split('/').last}');
          if (features != null) {
            setState(() {
              final songId = filePath.hashCode.toString();
              _songFeatures[songId] = features;
            });
          }
        },
        onCompleted: () {
          _logger.i(
            '✅ Automatic background analysis completed for ${newSongs.length} songs',
          );
          setState(() {
            _isProcessingInBackground = false;
          });
        },
        onError: (error) {
          _logger.e('❌ Auto-analysis error: $error');
          setState(() {
            _isProcessingInBackground = false;
          });
        },
      );
    } catch (e) {
      _logger.e('Auto-analysis failed: $e');
      setState(() {
        _isProcessingInBackground = false;
      });
    }
  }

  Future<void> _extractSingleSongFeatures(SongModel song) async {
    if (!_isInitialized) {
      _showSnackBar('Please initialize the analyzer first', Colors.orange);
      return;
    }

    try {
      _logger.i('Starting analysis for: ${song.title}');

      final features = await MusicFeatureAnalyzer.analyzeSong(song);

      if (features != null) {
        setState(() {
          _songFeatures[song.id] = features;
        });
        _logger.i('✅ Analysis completed for: ${song.title}');
        _showSnackBar('✅ Analysis completed for ${song.title}', Colors.green);
      } else {
        _logger.e('❌ Analysis failed for: ${song.title}');
        _showSnackBar('❌ Analysis failed for ${song.title}', Colors.red);
      }
    } catch (e) {
      _logger.e('Analysis error for ${song.title}: $e');
      _showSnackBar('❌ Analysis error: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _selectMusicFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result != null) {
        final remainingSlots = _maxSongs - _selectedSongs.length;
        final newSongs = <SongModel>[];
        for (final file in result.files.take(remainingSlots)) {
          final duration = await _getAudioDuration(file.path!);
          newSongs.add(
            SongModel(
              id: file.path!.hashCode.toString(),
              title: file.name,
              artist: 'Unknown',
              album: 'Unknown',
              duration: duration,
              filePath: file.path!,
            ),
          );
        }

        setState(() {
          _selectedSongs.addAll(newSongs);
        });
        _logger.i('Added ${newSongs.length} music files');

        // Automatically analyze new songs if system is initialized
        if (_isInitialized && newSongs.isNotEmpty) {
          _analyzeNewSongs(newSongs);
        }
      }
    } catch (e) {
      _logger.e('Error selecting music files: $e');
      _showSnackBar('Error selecting music files: $e', Colors.red);
    }
  }

  Future<void> _selectMusicFolder() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath();

      if (result != null) {
        final directory = Directory(result);
        final remainingSlots = _maxSongs - _selectedSongs.length;
        final audioFiles = await directory
            .list()
            .where((entity) => entity is File && _isAudioFile(entity.path))
            .cast<File>()
            .take(remainingSlots)
            .toList();

        final newSongs = <SongModel>[];
        for (final file in audioFiles) {
          final duration = await _getAudioDuration(file.path);
          newSongs.add(
            SongModel(
              id: file.path.hashCode.toString(),
              title: file.path.split('/').last,
              artist: 'Unknown',
              album: 'Unknown',
              duration: duration,
              filePath: file.path,
            ),
          );
        }

        setState(() {
          _selectedSongs.addAll(newSongs);
        });
        _logger.i('Added ${newSongs.length} music files from folder');

        // Automatically analyze new songs if system is initialized
        if (_isInitialized && newSongs.isNotEmpty) {
          _analyzeNewSongs(newSongs);
        }
      }
    } catch (e) {
      _logger.e('Error selecting music folder: $e');
      _showSnackBar('Error selecting music folder: $e', Colors.red);
    }
  }

  bool _isAudioFile(String path) {
    final extension = path.toLowerCase().split('.').last;
    return ['mp3', 'wav', 'flac', 'm4a', 'aac', 'ogg'].contains(extension);
  }

  Future<int> _getAudioDuration(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        // For now, return a placeholder duration
        // In a real implementation, you'd use a package like audio_service or ffmpeg
        return 180; // 3 minutes placeholder
      }
    } catch (e) {
      _logger.e('Error getting duration for $filePath: $e');
    }
    return 0;
  }

  Future<void> _extractAllFeatures() async {
    if (!_isInitialized) {
      _showSnackBar('Please initialize the analyzer first', Colors.orange);
      return;
    }

    if (_selectedSongs.isEmpty) {
      _showSnackBar('Please add songs first', Colors.orange);
      return;
    }

    setState(() {
      _isProcessingInBackground = true;
    });

    try {
      _logger.i(
        'Starting background analysis of ${_selectedSongs.length} songs',
      );

      await MusicFeatureAnalyzer.extractFeaturesInBackground(
        _selectedSongs.map((s) => s.filePath).toList(),
        onProgress: (current, total) {
          _logger.d(
            '📊 Feature extraction progress: $current/$total songs processed',
          );
        },
        onSongUpdated: (filePath, features) {
          _logger.d('🔄 Updated song: ${filePath.split('/').last}');
          if (features != null) {
            setState(() {
              final songId = filePath.hashCode.toString();
              _songFeatures[songId] = features;
            });
          }
        },
        onCompleted: () {
          _logger.i('✅ Background feature extraction completed');
          setState(() {
            _isProcessingInBackground = false;
          });
          _showSnackBar('All features extracted successfully!', Colors.green);
        },
        onError: (error) {
          _logger.e('❌ Background feature extraction error: $error');
          setState(() {
            _isProcessingInBackground = false;
          });
          _showSnackBar('Feature extraction failed: $error', Colors.red);
        },
      );
    } catch (e) {
      _logger.e('Feature extraction failed: $e');
      setState(() {
        _isProcessingInBackground = false;
      });
      _showSnackBar('Feature extraction failed: $e', Colors.red);
    }
  }
}

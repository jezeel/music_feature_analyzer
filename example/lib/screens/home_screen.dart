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
  bool _isAnalyzing = false;
  double _progress = 0.0;
  String _currentSong = '';
  List<Song> _selectedSongs = [];
  Map<String, SongFeatures> _songFeatures = {};
  int _processedCount = 0;
  int _totalCount = 0;

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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header Section
            _buildHeader(),
            SizedBox(height: 30.h),
            
            // Status Card
            _buildStatusCard(),
            SizedBox(height: 30.h),
            
            // What This Package Does
            _buildPackageInfo(),
            SizedBox(height: 30.h),
            
            // Add Music Section
            _buildAddMusicSection(),
            SizedBox(height: 30.h),
            
            // Selected Songs
            if (_selectedSongs.isNotEmpty) _buildSelectedSongs(),
            
            // Analysis Section
            if (_selectedSongs.isNotEmpty) _buildAnalysisSection(),
            
            // Progress Section
            if (_isAnalyzing) _buildProgressSection(),
            
            // Results Section
            if (_songFeatures.isNotEmpty) _buildResultsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
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
              Icon(
                Icons.analytics_rounded,
                size: 60.sp,
                color: Colors.white,
              ),
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: _isInitialized ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                _isInitialized ? Icons.check_circle_rounded : Icons.schedule_rounded,
                color: _isInitialized ? Colors.green : Colors.orange,
                size: 28.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Status',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _isInitialized ? 'Ready for Analysis' : 'Not Initialized',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (!_isInitialized)
              ElevatedButton(
                onPressed: _initializeAnalyzer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: const Text('Initialize'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'What This Package Does',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildFeatureItem('🎵 Genre Detection', 'Automatically identify music genre'),
            _buildFeatureItem('🎼 Tempo Analysis', 'Detect BPM and rhythm patterns'),
            _buildFeatureItem('🎤 Vocal Detection', 'Identify if song has vocals'),
            _buildFeatureItem('🎹 Instrument Recognition', 'Detect musical instruments'),
            _buildFeatureItem('😊 Mood Analysis', 'Analyze emotional content'),
            _buildFeatureItem('⚡ Energy Levels', 'Measure song intensity'),
            _buildFeatureItem('📊 Spectral Features', 'Advanced audio analysis'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMusicSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Music Files',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Select audio files to analyze (Maximum 4 songs)',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedSongs.length < 4 ? _selectMusicFiles : null,
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
                    onPressed: _selectedSongs.length < 4 ? _selectMusicFolder : null,
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
            if (_selectedSongs.length >= 4) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_rounded, color: Colors.orange, size: 16.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Maximum 4 songs reached',
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

  Widget _buildSelectedSongs() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Selected Songs (${_selectedSongs.length}/4)',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _clearAllSongs,
                  icon: const Icon(Icons.clear_all_rounded, size: 16),
                  label: const Text('Clear All'),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ...List.generate(_selectedSongs.length, (index) {
              final song = _selectedSongs[index];
              final features = _songFeatures[song.id];
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.music_note_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            song.artist,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (features != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'Analyzed',
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'Pending',
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analysis Options',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isInitialized && !_isAnalyzing ? _extractAllFeatures : null,
                    icon: const Icon(Icons.analytics_rounded),
                    label: const Text('Analyze All'),
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
                    onPressed: _isInitialized && !_isAnalyzing ? _extractPendingFeatures : null,
                    icon: const Icon(Icons.pending_actions_rounded),
                    label: const Text('Analyze Pending'),
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
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _songFeatures.isNotEmpty ? _clearAllFeatures : null,
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text('Clear All Features'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Analysis in Progress',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _cancelAnalysis,
                  icon: const Icon(Icons.cancel_rounded),
                  tooltip: 'Cancel Analysis',
                ),
              ],
            ),
            SizedBox(height: 20.h),
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              minHeight: 8.h,
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Text(
                  'Progress: $_processedCount/$_totalCount songs',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(_progress * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (_currentSong.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Text(
                'Processing: $_currentSong',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analysis Results',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            ..._songFeatures.entries.map((entry) {
              final songId = entry.key;
              final features = entry.value;
              final song = _selectedSongs.firstWhere((s) => s.id == songId);
              
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.music_note_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            song.title,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showDetailedResults(song, features),
                          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          tooltip: 'View Details',
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        _buildFeatureChip('Genre', features.estimatedGenre, Colors.purple),
                        _buildFeatureChip('Tempo', '${features.tempoBpm.toStringAsFixed(0)} BPM', Colors.blue),
                        _buildFeatureChip('Energy', features.energy, Colors.orange),
                        _buildFeatureChip('Mood', features.mood, Colors.green),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: color,
            ),
          ),
        ],
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
        final newSongs = result.files.take(4 - _selectedSongs.length).map((file) => Song(
          id: file.path!.hashCode.toString(),
          title: file.name,
          artist: 'Unknown',
          album: 'Unknown',
          duration: 0,
          filePath: file.path!,
        )).toList();
        
        setState(() {
          _selectedSongs.addAll(newSongs);
        });
        _logger.i('Added ${newSongs.length} music files');
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
        final audioFiles = await directory.list()
            .where((entity) => entity is File && _isAudioFile(entity.path))
            .cast<File>()
            .take(4 - _selectedSongs.length)
            .toList();
        
        final newSongs = audioFiles.map((file) => Song(
          id: file.path.hashCode.toString(),
          title: file.path.split('/').last,
          artist: 'Unknown',
          album: 'Unknown',
          duration: 0,
          filePath: file.path,
        )).toList();
        
        setState(() {
          _selectedSongs.addAll(newSongs);
        });
        _logger.i('Added ${newSongs.length} music files from folder');
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

  void _clearAllSongs() {
    setState(() {
      _selectedSongs.clear();
      _songFeatures.clear();
    });
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
      _isAnalyzing = true;
      _progress = 0.0;
      _processedCount = 0;
      _totalCount = _selectedSongs.length;
    });

    try {
      _logger.i('Starting analysis of ${_selectedSongs.length} songs');
      
      await MusicFeatureAnalyzer.extractFeaturesInBackground(
        _selectedSongs.map((s) => s.filePath).toList(),
        onProgress: (current, total) {
          _logger.d('📊 Feature extraction progress: $current/$total songs processed');
          setState(() {
            _progress = current / total;
            _processedCount = current;
            _totalCount = total;
          });
        },
        onSongUpdated: (filePath, features) {
          _logger.d('🔄 Updated song: ${filePath.split('/').last}');
          if (features != null) {
            _logger.d('🔍 Features: ${features.estimatedGenre} | ${features.tempoBpm} BPM');
            setState(() {
              _currentSong = filePath.split('/').last;
              final songId = filePath.hashCode.toString();
              _songFeatures[songId] = features;
            });
          }
        },
        onCompleted: () {
          _logger.i('✅ Background feature extraction completed');
          setState(() {
            _isAnalyzing = false;
            _progress = 1.0;
            _processedCount = _totalCount;
          });
          _showSnackBar('All features extracted successfully!', Colors.green);
        },
        onError: (error) {
          _logger.e('❌ Background feature extraction error: $error');
          setState(() {
            _isAnalyzing = false;
          });
          _showSnackBar('Feature extraction failed: $error', Colors.red);
        },
      );
    } catch (e) {
      _logger.e('Feature extraction failed: $e');
      setState(() {
        _isAnalyzing = false;
      });
      _showSnackBar('Feature extraction failed: $e', Colors.red);
    }
  }

  Future<void> _extractPendingFeatures() async {
    if (!_isInitialized) {
      _showSnackBar('Please initialize the analyzer first', Colors.orange);
      return;
    }

    final pendingSongs = _selectedSongs.where((song) => !_songFeatures.containsKey(song.id)).toList();
    
    if (pendingSongs.isEmpty) {
      _showSnackBar('No pending songs to analyze', Colors.blue);
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _progress = 0.0;
      _processedCount = 0;
      _totalCount = pendingSongs.length;
    });

    try {
      _logger.i('Starting analysis of ${pendingSongs.length} pending songs');
      
      await MusicFeatureAnalyzer.extractFeaturesInBackground(
        pendingSongs.map((s) => s.filePath).toList(),
        onProgress: (current, total) {
          _logger.d('📊 Feature extraction progress: $current/$total songs processed');
          setState(() {
            _progress = current / total;
            _processedCount = current;
            _totalCount = total;
          });
        },
        onSongUpdated: (filePath, features) {
          _logger.d('🔄 Updated song: ${filePath.split('/').last}');
          if (features != null) {
            _logger.d('🔍 Features: ${features.estimatedGenre} | ${features.tempoBpm} BPM');
            setState(() {
              _currentSong = filePath.split('/').last;
              final songId = filePath.hashCode.toString();
              _songFeatures[songId] = features;
            });
          }
        },
        onCompleted: () {
          _logger.i('✅ Pending feature extraction completed');
          setState(() {
            _isAnalyzing = false;
            _progress = 1.0;
            _processedCount = _totalCount;
          });
          _showSnackBar('Pending features extracted successfully!', Colors.green);
        },
        onError: (error) {
          _logger.e('❌ Pending feature extraction error: $error');
          setState(() {
            _isAnalyzing = false;
          });
          _showSnackBar('Pending feature extraction failed: $error', Colors.red);
        },
      );
    } catch (e) {
      _logger.e('Pending feature extraction failed: $e');
      setState(() {
        _isAnalyzing = false;
      });
      _showSnackBar('Pending feature extraction failed: $e', Colors.red);
    }
  }

  void _clearAllFeatures() {
    setState(() {
      _songFeatures.clear();
    });
    _logger.i('All features cleared');
    _showSnackBar('All features cleared!', Colors.blue);
  }

  void _cancelAnalysis() {
    setState(() {
      _isAnalyzing = false;
      _progress = 0.0;
      _currentSong = '';
      _processedCount = 0;
      _totalCount = 0;
    });
    _logger.i('Analysis cancelled');
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
        _showSnackBar('✅ Analyzer initialized successfully!', Colors.green);
      } else {
        _logger.e('❌ Music Feature Analyzer initialization failed');
        _showSnackBar('❌ Initialization failed', Colors.red);
      }
    } catch (e) {
      _logger.e('Initialization error: $e');
      _showSnackBar('❌ Initialization error: $e', Colors.red);
    }
  }

  void _showDetailedResults(Song song, SongFeatures features) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          song.title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                song.artist,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 20.h),
              _buildDetailRow('Genre', features.estimatedGenre),
              _buildDetailRow('Tempo', '${features.tempoBpm.toStringAsFixed(1)} BPM'),
              _buildDetailRow('Energy', features.energy),
              _buildDetailRow('Mood', features.mood),
              _buildDetailRow('Instruments', features.instruments.join(', ')),
              _buildDetailRow('Has Vocals', features.hasVocals ? 'Yes' : 'No'),
              _buildDetailRow('Danceability', features.danceability.toStringAsFixed(2)),
              _buildDetailRow('Confidence', features.confidence.toStringAsFixed(2)),
              _buildDetailRow('Spectral Centroid', features.spectralCentroid.toStringAsFixed(1)),
              _buildDetailRow('Zero Crossing Rate', features.zeroCrossingRate.toStringAsFixed(3)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
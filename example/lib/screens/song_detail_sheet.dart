import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music_feature_analyzer/music_feature_analyzer.dart';
import 'dart:io';
import '../utils/app_utils.dart';

class SongDetailSheet extends StatefulWidget {
  final SongModel song;
  final ExtractedSongFeatures? features;
  final bool isExtractingFeatures;
  final VoidCallback? onExtractFeatures;

  const SongDetailSheet({
    super.key,
    required this.song,
    this.features,
    this.isExtractingFeatures = false,
    this.onExtractFeatures,
  });

  @override
  State<SongDetailSheet> createState() => _SongDetailSheetState();
}

class _SongDetailSheetState extends State<SongDetailSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final hasFeatures = widget.features != null || widget.isExtractingFeatures;
    _tabController = TabController(
      length: hasFeatures ? 2 : 1,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(SongDetailSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.features != widget.features || oldWidget.isExtractingFeatures != widget.isExtractingFeatures) {
      final hasFeatures = widget.features != null || widget.isExtractingFeatures;
      if (_tabController.length != (hasFeatures ? 2 : 1)) {
        _tabController.dispose();
        _tabController = TabController(
          length: hasFeatures ? 2 : 1,
          vsync: this,
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              // Header with Album Art
              _buildHeader(),
              // Tabs
              if (widget.features != null || widget.isExtractingFeatures)
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'Metadata'),
                    Tab(text: 'Features'),
                  ],
                ),
              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMetadataSection(scrollController),
                    if (widget.features != null || widget.isExtractingFeatures)
                      _buildFeaturesSection(scrollController)
                    else
                      const SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          // Album Art
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: Theme.of(context).colorScheme.surfaceVariant,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: FutureBuilder<bool>(
                future: widget.song.albumArt != null
                    ? File(widget.song.albumArt!).exists()
                    : Future.value(false),
                builder: (context, snapshot) {
                  final hasArt = snapshot.data ?? false;
                  return hasArt
                      ? Image.file(
                          File(widget.song.albumArt!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              AppUtils.buildLargeAlbumArtPlaceholder(context),
                        )
                      : AppUtils.buildLargeAlbumArtPlaceholder(context);
                },
              ),
            ),
          ),
          SizedBox(width: 16.w),
          // Song Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.song.title,
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Text(
                  widget.song.artist,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.song.album,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Close Button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection(ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetadataSectionTitle('Basic Information'),
          SizedBox(height: 12.h),
          _buildMetadataItem('Title', AppUtils.getValidatedValue(widget.song.title, 'Unknown Title')),
          _buildMetadataItem('Artist', AppUtils.getValidatedValue(widget.song.artist, 'Unknown Artist')),
          _buildMetadataItem('Album', AppUtils.getValidatedValue(widget.song.album, 'Unknown Album')),
          _buildMetadataItem('Duration', AppUtils.formatDuration(widget.song.duration)),
          if (AppUtils.hasValue(widget.song.albumArtist))
            _buildMetadataItem('Album Artist', widget.song.albumArtist!),
          if (AppUtils.hasValue(widget.song.genre))
            _buildMetadataItem('Genre', widget.song.genre!),
          if (widget.song.year != null && widget.song.year! > 0)
            _buildMetadataItem('Year', widget.song.year.toString()),
          if (widget.song.trackNumber != null && widget.song.trackNumber! > 0)
            _buildMetadataItem('Track Number', widget.song.trackNumber.toString()),
          if (widget.song.discNumber != null && widget.song.discNumber! > 0)
            _buildMetadataItem('Disc Number', widget.song.discNumber.toString()),
          if (AppUtils.hasValue(widget.song.composer))
            _buildMetadataItem('Composer', widget.song.composer!),
          if (AppUtils.hasValue(widget.song.writer))
            _buildMetadataItem('Writer', widget.song.writer!),
          if (_hasTechnicalMetadata()) ...[
            SizedBox(height: 24.h),
            _buildMetadataSectionTitle('Technical Information'),
            SizedBox(height: 12.h),
            if (widget.song.bitrate != null && widget.song.bitrate! > 0)
              _buildMetadataItem('Bitrate', '${widget.song.bitrate} kbps'),
            if (widget.song.fileSize != null && widget.song.fileSize! > 0)
              _buildMetadataItem('File Size', AppUtils.formatFileSize(widget.song.fileSize!)),
            if (AppUtils.hasValue(widget.song.mimeType))
              _buildMetadataItem('MIME Type', widget.song.mimeType!),
            if (widget.song.dateAdded != null)
              _buildMetadataItem('Date Added', AppUtils.formatDate(widget.song.dateAdded!)),
          ],
          SizedBox(height: 24.h),
          _buildMetadataSectionTitle('File Information'),
          SizedBox(height: 12.h),
          _buildMetadataItem('File Path', widget.song.filePath, isLongText: true),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(ScrollController scrollController) {
    // Show loading state if features are being extracted
    if (widget.isExtractingFeatures && widget.features == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 64.w,
              height: 64.w,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Extracting Features...',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please wait while we analyze the audio',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'This may take a few moments',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    // Show empty state if no features and not extracting
    if (widget.features == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology_outlined,
              size: 64.sp,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              'No features extracted',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (widget.onExtractFeatures != null) ...[
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: widget.onExtractFeatures,
                child: const Text('Extract Features'),
              ),
            ],
          ],
        ),
      );
    }

    final features = widget.features!;
    final featureData = [
      {
        'name': 'Genre',
        'value': AppUtils.getValidatedValue(features.estimatedGenre, 'Unknown'),
        'icon': Icons.music_note_rounded
      },
      {
        'name': 'Tempo',
        'value': '${AppUtils.validateAndFormatBpm(features.tempoBpm)} BPM',
        'icon': Icons.speed_rounded
      },
      {
        'name': 'Energy',
        'value': AppUtils.getValidatedValue(features.energy, 'Unknown'),
        'icon': Icons.flash_on_rounded
      },
      {
        'name': 'Mood',
        'value': AppUtils.getValidatedValue(features.mood, 'Unknown'),
        'icon': Icons.sentiment_very_satisfied_rounded
      },
      {
        'name': 'Danceability',
        'value': AppUtils.validateAndFormatDouble(features.danceability, 0.0, 1.0),
        'icon': Icons.music_note_rounded
      },
      {
        'name': 'Confidence',
        'value': AppUtils.validateAndFormatDouble(features.confidence, 0.0, 1.0),
        'icon': Icons.psychology_rounded
      },
      {
        'name': 'Has Vocals',
        'value': features.hasVocals ? 'Yes' : 'No',
        'icon': Icons.mic_rounded
      },
      {
        'name': 'Overall Energy',
        'value': AppUtils.validateAndFormatDouble(features.overallEnergy, 0.0, 1.0),
        'icon': Icons.flash_on_rounded
      },
      {
        'name': 'Spectral Centroid',
        'value': '${AppUtils.validateAndFormatDouble(features.spectralCentroid, 0.0, double.infinity)} Hz',
        'icon': Icons.trending_up_rounded
      },
      {
        'name': 'Zero Crossing Rate',
        'value': AppUtils.validateAndFormatDouble(features.zeroCrossingRate, 0.0, 1.0),
        'icon': Icons.waves_rounded
      },
      {
        'name': 'Spectral Rolloff',
        'value': '${AppUtils.validateAndFormatDouble(features.spectralRolloff, 0.0, double.infinity)} Hz',
        'icon': Icons.show_chart_rounded
      },
      {
        'name': 'Spectral Flux',
        'value': AppUtils.validateAndFormatDouble(features.spectralFlux, 0.0, double.infinity),
        'icon': Icons.auto_graph_rounded
      },
      {
        'name': 'Beat Strength',
        'value': AppUtils.validateAndFormatDouble(features.beatStrength, 0.0, 1.0),
        'icon': Icons.trending_up_rounded
      },
      if (features.instruments.isNotEmpty)
        {
          'name': 'Instruments',
          'value': features.instruments.join(', '),
          'icon': Icons.piano_rounded
        },
      if (AppUtils.hasValue(features.vocals))
        {
          'name': 'Vocals',
          'value': features.vocals!,
          'icon': Icons.mic_rounded
        },
    ];

    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetadataSectionTitle('AI Analysis Results'),
          SizedBox(height: 16.h),
          ...featureData.map((feature) => _buildFeatureCard(
                feature['name'] as String,
                feature['value'] as String,
                feature['icon'] as IconData,
              )),
        ],
      ),
    );
  }

  Widget _buildMetadataSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildMetadataItem(String label, String value, {bool isLongText = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
            ),
            maxLines: isLongText ? 3 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String name, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              size: 20.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasTechnicalMetadata() {
    return widget.song.bitrate != null ||
        widget.song.fileSize != null ||
        widget.song.mimeType != null ||
        widget.song.dateAdded != null;
  }

}

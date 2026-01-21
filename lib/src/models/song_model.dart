import 'package:freezed_annotation/freezed_annotation.dart';
import 'extracted_song_features.dart';

part 'song_model.freezed.dart';
part 'song_model.g.dart';

/// Song model for the music feature analyzer package
/// Contains all metadata information extracted from audio files
@freezed
abstract class SongModel with _$SongModel {
  const factory SongModel({
    required String id,
    required String title,
    required String artist,
    required String album,
    required int duration, // Duration in milliseconds
    required String filePath,
    
    // Feature analysis (null when only metadata is extracted)
    ExtractedSongFeatures? features,
    
    // Metadata fields
    String? albumArt, // Path to album art image file
    int? year, // Release year
    String? genre, // Genre classification
    int? trackNumber, // Track number in album
    int? discNumber, // Disc number for multi-disc albums
    String? albumArtist, // Album artist (may differ from track artist)
    String? composer, // Composer name
    String? writer, // Songwriter name
    
    // Technical metadata
    int? bitrate, // Audio bitrate in kbps
    int? fileSize, // File size in bytes
    String? mimeType, // Audio file MIME type
    
    // File metadata
    DateTime? dateAdded, // When file was added/created
  }) = _SongModel;

  factory SongModel.fromJson(Map<String, dynamic> json) => _$SongModelFromJson(json);
}

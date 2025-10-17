import 'package:freezed_annotation/freezed_annotation.dart';
import 'song_features.dart';

part 'song_model.freezed.dart';
part 'song_model.g.dart';

/// Song model for the music feature analyzer package
@freezed
class Song with _$Song {
  const factory Song({
    required String id,
    required String title,
    required String artist,
    required String album,
    required int duration,
    required String filePath,
    SongFeatures? features,
    String? albumArt,
    int? year,
    String? genre,
    int? trackNumber,
  }) = _Song;

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);
}

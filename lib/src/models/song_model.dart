import 'package:freezed_annotation/freezed_annotation.dart';
import 'song_features.dart';

part 'song_model.freezed.dart';
part 'song_model.g.dart';

/// Song model for the music feature analyzer package
@freezed
class SongModel with _$SongModel {
  const factory SongModel({
    required String id,
    required String title,
    required String artist,
    required String album,
    required int duration,
    required String filePath,
    SongFeaturesModel? features,
    String? albumArt,
    int? year,
    String? genre,
    int? trackNumber,
  }) = _SongModel;

  factory SongModel.fromJson(Map<String, dynamic> json) => _$SongModelFromJson(json);
}

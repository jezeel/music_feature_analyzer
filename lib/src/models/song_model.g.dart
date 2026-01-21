// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SongModel _$SongModelFromJson(Map<String, dynamic> json) => _SongModel(
  id: json['id'] as String,
  title: json['title'] as String,
  artist: json['artist'] as String,
  album: json['album'] as String,
  duration: (json['duration'] as num).toInt(),
  filePath: json['filePath'] as String,
  features: json['features'] == null
      ? null
      : ExtractedSongFeatures.fromJson(
          json['features'] as Map<String, dynamic>,
        ),
  albumArt: json['albumArt'] as String?,
  year: (json['year'] as num?)?.toInt(),
  genre: json['genre'] as String?,
  trackNumber: (json['trackNumber'] as num?)?.toInt(),
  discNumber: (json['discNumber'] as num?)?.toInt(),
  albumArtist: json['albumArtist'] as String?,
  composer: json['composer'] as String?,
  writer: json['writer'] as String?,
  bitrate: (json['bitrate'] as num?)?.toInt(),
  fileSize: (json['fileSize'] as num?)?.toInt(),
  mimeType: json['mimeType'] as String?,
  dateAdded: json['dateAdded'] == null
      ? null
      : DateTime.parse(json['dateAdded'] as String),
);

Map<String, dynamic> _$SongModelToJson(_SongModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'artist': instance.artist,
      'album': instance.album,
      'duration': instance.duration,
      'filePath': instance.filePath,
      'features': instance.features,
      'albumArt': instance.albumArt,
      'year': instance.year,
      'genre': instance.genre,
      'trackNumber': instance.trackNumber,
      'discNumber': instance.discNumber,
      'albumArtist': instance.albumArtist,
      'composer': instance.composer,
      'writer': instance.writer,
      'bitrate': instance.bitrate,
      'fileSize': instance.fileSize,
      'mimeType': instance.mimeType,
      'dateAdded': instance.dateAdded?.toIso8601String(),
    };

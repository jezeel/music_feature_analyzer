// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SongModelImpl _$$SongModelImplFromJson(Map<String, dynamic> json) =>
    _$SongModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String,
      duration: (json['duration'] as num).toInt(),
      filePath: json['filePath'] as String,
      features: json['features'] == null
          ? null
          : SongFeatures.fromJson(json['features'] as Map<String, dynamic>),
      albumArt: json['albumArt'] as String?,
      year: (json['year'] as num?)?.toInt(),
      genre: json['genre'] as String?,
      trackNumber: (json['trackNumber'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$SongModelImplToJson(_$SongModelImpl instance) =>
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
    };

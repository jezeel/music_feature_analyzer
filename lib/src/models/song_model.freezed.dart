// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SongModel {

 String get id; String get title; String get artist; String get album; int get duration;// Duration in milliseconds
 String get filePath;// Feature analysis (null when only metadata is extracted)
 ExtractedSongFeatures? get features;// Metadata fields
 String? get albumArt;// Path to album art image file
 int? get year;// Release year
 String? get genre;// Genre classification
 int? get trackNumber;// Track number in album
 int? get discNumber;// Disc number for multi-disc albums
 String? get albumArtist;// Album artist (may differ from track artist)
 String? get composer;// Composer name
 String? get writer;// Songwriter name
// Technical metadata
 int? get bitrate;// Audio bitrate in kbps
 int? get fileSize;// File size in bytes
 String? get mimeType;// Audio file MIME type
// File metadata
 DateTime? get dateAdded;
/// Create a copy of SongModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SongModelCopyWith<SongModel> get copyWith => _$SongModelCopyWithImpl<SongModel>(this as SongModel, _$identity);

  /// Serializes this SongModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SongModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.album, album) || other.album == album)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.features, features) || other.features == features)&&(identical(other.albumArt, albumArt) || other.albumArt == albumArt)&&(identical(other.year, year) || other.year == year)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.trackNumber, trackNumber) || other.trackNumber == trackNumber)&&(identical(other.discNumber, discNumber) || other.discNumber == discNumber)&&(identical(other.albumArtist, albumArtist) || other.albumArtist == albumArtist)&&(identical(other.composer, composer) || other.composer == composer)&&(identical(other.writer, writer) || other.writer == writer)&&(identical(other.bitrate, bitrate) || other.bitrate == bitrate)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.dateAdded, dateAdded) || other.dateAdded == dateAdded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,artist,album,duration,filePath,features,albumArt,year,genre,trackNumber,discNumber,albumArtist,composer,writer,bitrate,fileSize,mimeType,dateAdded]);

@override
String toString() {
  return 'SongModel(id: $id, title: $title, artist: $artist, album: $album, duration: $duration, filePath: $filePath, features: $features, albumArt: $albumArt, year: $year, genre: $genre, trackNumber: $trackNumber, discNumber: $discNumber, albumArtist: $albumArtist, composer: $composer, writer: $writer, bitrate: $bitrate, fileSize: $fileSize, mimeType: $mimeType, dateAdded: $dateAdded)';
}


}

/// @nodoc
abstract mixin class $SongModelCopyWith<$Res>  {
  factory $SongModelCopyWith(SongModel value, $Res Function(SongModel) _then) = _$SongModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String artist, String album, int duration, String filePath, ExtractedSongFeatures? features, String? albumArt, int? year, String? genre, int? trackNumber, int? discNumber, String? albumArtist, String? composer, String? writer, int? bitrate, int? fileSize, String? mimeType, DateTime? dateAdded
});


$ExtractedSongFeaturesCopyWith<$Res>? get features;

}
/// @nodoc
class _$SongModelCopyWithImpl<$Res>
    implements $SongModelCopyWith<$Res> {
  _$SongModelCopyWithImpl(this._self, this._then);

  final SongModel _self;
  final $Res Function(SongModel) _then;

/// Create a copy of SongModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? artist = null,Object? album = null,Object? duration = null,Object? filePath = null,Object? features = freezed,Object? albumArt = freezed,Object? year = freezed,Object? genre = freezed,Object? trackNumber = freezed,Object? discNumber = freezed,Object? albumArtist = freezed,Object? composer = freezed,Object? writer = freezed,Object? bitrate = freezed,Object? fileSize = freezed,Object? mimeType = freezed,Object? dateAdded = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,album: null == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,features: freezed == features ? _self.features : features // ignore: cast_nullable_to_non_nullable
as ExtractedSongFeatures?,albumArt: freezed == albumArt ? _self.albumArt : albumArt // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,trackNumber: freezed == trackNumber ? _self.trackNumber : trackNumber // ignore: cast_nullable_to_non_nullable
as int?,discNumber: freezed == discNumber ? _self.discNumber : discNumber // ignore: cast_nullable_to_non_nullable
as int?,albumArtist: freezed == albumArtist ? _self.albumArtist : albumArtist // ignore: cast_nullable_to_non_nullable
as String?,composer: freezed == composer ? _self.composer : composer // ignore: cast_nullable_to_non_nullable
as String?,writer: freezed == writer ? _self.writer : writer // ignore: cast_nullable_to_non_nullable
as String?,bitrate: freezed == bitrate ? _self.bitrate : bitrate // ignore: cast_nullable_to_non_nullable
as int?,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,dateAdded: freezed == dateAdded ? _self.dateAdded : dateAdded // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SongModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExtractedSongFeaturesCopyWith<$Res>? get features {
    if (_self.features == null) {
    return null;
  }

  return $ExtractedSongFeaturesCopyWith<$Res>(_self.features!, (value) {
    return _then(_self.copyWith(features: value));
  });
}
}


/// Adds pattern-matching-related methods to [SongModel].
extension SongModelPatterns on SongModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SongModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SongModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SongModel value)  $default,){
final _that = this;
switch (_that) {
case _SongModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SongModel value)?  $default,){
final _that = this;
switch (_that) {
case _SongModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String artist,  String album,  int duration,  String filePath,  ExtractedSongFeatures? features,  String? albumArt,  int? year,  String? genre,  int? trackNumber,  int? discNumber,  String? albumArtist,  String? composer,  String? writer,  int? bitrate,  int? fileSize,  String? mimeType,  DateTime? dateAdded)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SongModel() when $default != null:
return $default(_that.id,_that.title,_that.artist,_that.album,_that.duration,_that.filePath,_that.features,_that.albumArt,_that.year,_that.genre,_that.trackNumber,_that.discNumber,_that.albumArtist,_that.composer,_that.writer,_that.bitrate,_that.fileSize,_that.mimeType,_that.dateAdded);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String artist,  String album,  int duration,  String filePath,  ExtractedSongFeatures? features,  String? albumArt,  int? year,  String? genre,  int? trackNumber,  int? discNumber,  String? albumArtist,  String? composer,  String? writer,  int? bitrate,  int? fileSize,  String? mimeType,  DateTime? dateAdded)  $default,) {final _that = this;
switch (_that) {
case _SongModel():
return $default(_that.id,_that.title,_that.artist,_that.album,_that.duration,_that.filePath,_that.features,_that.albumArt,_that.year,_that.genre,_that.trackNumber,_that.discNumber,_that.albumArtist,_that.composer,_that.writer,_that.bitrate,_that.fileSize,_that.mimeType,_that.dateAdded);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String artist,  String album,  int duration,  String filePath,  ExtractedSongFeatures? features,  String? albumArt,  int? year,  String? genre,  int? trackNumber,  int? discNumber,  String? albumArtist,  String? composer,  String? writer,  int? bitrate,  int? fileSize,  String? mimeType,  DateTime? dateAdded)?  $default,) {final _that = this;
switch (_that) {
case _SongModel() when $default != null:
return $default(_that.id,_that.title,_that.artist,_that.album,_that.duration,_that.filePath,_that.features,_that.albumArt,_that.year,_that.genre,_that.trackNumber,_that.discNumber,_that.albumArtist,_that.composer,_that.writer,_that.bitrate,_that.fileSize,_that.mimeType,_that.dateAdded);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SongModel implements SongModel {
  const _SongModel({required this.id, required this.title, required this.artist, required this.album, required this.duration, required this.filePath, this.features, this.albumArt, this.year, this.genre, this.trackNumber, this.discNumber, this.albumArtist, this.composer, this.writer, this.bitrate, this.fileSize, this.mimeType, this.dateAdded});
  factory _SongModel.fromJson(Map<String, dynamic> json) => _$SongModelFromJson(json);

@override final  String id;
@override final  String title;
@override final  String artist;
@override final  String album;
@override final  int duration;
// Duration in milliseconds
@override final  String filePath;
// Feature analysis (null when only metadata is extracted)
@override final  ExtractedSongFeatures? features;
// Metadata fields
@override final  String? albumArt;
// Path to album art image file
@override final  int? year;
// Release year
@override final  String? genre;
// Genre classification
@override final  int? trackNumber;
// Track number in album
@override final  int? discNumber;
// Disc number for multi-disc albums
@override final  String? albumArtist;
// Album artist (may differ from track artist)
@override final  String? composer;
// Composer name
@override final  String? writer;
// Songwriter name
// Technical metadata
@override final  int? bitrate;
// Audio bitrate in kbps
@override final  int? fileSize;
// File size in bytes
@override final  String? mimeType;
// Audio file MIME type
// File metadata
@override final  DateTime? dateAdded;

/// Create a copy of SongModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SongModelCopyWith<_SongModel> get copyWith => __$SongModelCopyWithImpl<_SongModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SongModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SongModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.album, album) || other.album == album)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.features, features) || other.features == features)&&(identical(other.albumArt, albumArt) || other.albumArt == albumArt)&&(identical(other.year, year) || other.year == year)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.trackNumber, trackNumber) || other.trackNumber == trackNumber)&&(identical(other.discNumber, discNumber) || other.discNumber == discNumber)&&(identical(other.albumArtist, albumArtist) || other.albumArtist == albumArtist)&&(identical(other.composer, composer) || other.composer == composer)&&(identical(other.writer, writer) || other.writer == writer)&&(identical(other.bitrate, bitrate) || other.bitrate == bitrate)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.dateAdded, dateAdded) || other.dateAdded == dateAdded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,artist,album,duration,filePath,features,albumArt,year,genre,trackNumber,discNumber,albumArtist,composer,writer,bitrate,fileSize,mimeType,dateAdded]);

@override
String toString() {
  return 'SongModel(id: $id, title: $title, artist: $artist, album: $album, duration: $duration, filePath: $filePath, features: $features, albumArt: $albumArt, year: $year, genre: $genre, trackNumber: $trackNumber, discNumber: $discNumber, albumArtist: $albumArtist, composer: $composer, writer: $writer, bitrate: $bitrate, fileSize: $fileSize, mimeType: $mimeType, dateAdded: $dateAdded)';
}


}

/// @nodoc
abstract mixin class _$SongModelCopyWith<$Res> implements $SongModelCopyWith<$Res> {
  factory _$SongModelCopyWith(_SongModel value, $Res Function(_SongModel) _then) = __$SongModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String artist, String album, int duration, String filePath, ExtractedSongFeatures? features, String? albumArt, int? year, String? genre, int? trackNumber, int? discNumber, String? albumArtist, String? composer, String? writer, int? bitrate, int? fileSize, String? mimeType, DateTime? dateAdded
});


@override $ExtractedSongFeaturesCopyWith<$Res>? get features;

}
/// @nodoc
class __$SongModelCopyWithImpl<$Res>
    implements _$SongModelCopyWith<$Res> {
  __$SongModelCopyWithImpl(this._self, this._then);

  final _SongModel _self;
  final $Res Function(_SongModel) _then;

/// Create a copy of SongModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? artist = null,Object? album = null,Object? duration = null,Object? filePath = null,Object? features = freezed,Object? albumArt = freezed,Object? year = freezed,Object? genre = freezed,Object? trackNumber = freezed,Object? discNumber = freezed,Object? albumArtist = freezed,Object? composer = freezed,Object? writer = freezed,Object? bitrate = freezed,Object? fileSize = freezed,Object? mimeType = freezed,Object? dateAdded = freezed,}) {
  return _then(_SongModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,album: null == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,features: freezed == features ? _self.features : features // ignore: cast_nullable_to_non_nullable
as ExtractedSongFeatures?,albumArt: freezed == albumArt ? _self.albumArt : albumArt // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,trackNumber: freezed == trackNumber ? _self.trackNumber : trackNumber // ignore: cast_nullable_to_non_nullable
as int?,discNumber: freezed == discNumber ? _self.discNumber : discNumber // ignore: cast_nullable_to_non_nullable
as int?,albumArtist: freezed == albumArtist ? _self.albumArtist : albumArtist // ignore: cast_nullable_to_non_nullable
as String?,composer: freezed == composer ? _self.composer : composer // ignore: cast_nullable_to_non_nullable
as String?,writer: freezed == writer ? _self.writer : writer // ignore: cast_nullable_to_non_nullable
as String?,bitrate: freezed == bitrate ? _self.bitrate : bitrate // ignore: cast_nullable_to_non_nullable
as int?,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,dateAdded: freezed == dateAdded ? _self.dateAdded : dateAdded // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SongModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExtractedSongFeaturesCopyWith<$Res>? get features {
    if (_self.features == null) {
    return null;
  }

  return $ExtractedSongFeaturesCopyWith<$Res>(_self.features!, (value) {
    return _then(_self.copyWith(features: value));
  });
}
}

// dart format on

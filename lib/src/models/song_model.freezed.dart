// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SongModel _$SongModelFromJson(Map<String, dynamic> json) {
  return _SongModel.fromJson(json);
}

/// @nodoc
mixin _$SongModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get artist => throw _privateConstructorUsedError;
  String get album => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  String get filePath => throw _privateConstructorUsedError;
  SongFeaturesModel? get features => throw _privateConstructorUsedError;
  String? get albumArt => throw _privateConstructorUsedError;
  int? get year => throw _privateConstructorUsedError;
  String? get genre => throw _privateConstructorUsedError;
  int? get trackNumber => throw _privateConstructorUsedError;

  /// Serializes this SongModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SongModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SongModelCopyWith<SongModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SongModelCopyWith<$Res> {
  factory $SongModelCopyWith(SongModel value, $Res Function(SongModel) then) =
      _$SongModelCopyWithImpl<$Res, SongModel>;
  @useResult
  $Res call({
    String id,
    String title,
    String artist,
    String album,
    int duration,
    String filePath,
    SongFeaturesModel? features,
    String? albumArt,
    int? year,
    String? genre,
    int? trackNumber,
  });

  $SongFeaturesModelCopyWith<$Res>? get features;
}

/// @nodoc
class _$SongModelCopyWithImpl<$Res, $Val extends SongModel>
    implements $SongModelCopyWith<$Res> {
  _$SongModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SongModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? artist = null,
    Object? album = null,
    Object? duration = null,
    Object? filePath = null,
    Object? features = freezed,
    Object? albumArt = freezed,
    Object? year = freezed,
    Object? genre = freezed,
    Object? trackNumber = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            artist: null == artist
                ? _value.artist
                : artist // ignore: cast_nullable_to_non_nullable
                      as String,
            album: null == album
                ? _value.album
                : album // ignore: cast_nullable_to_non_nullable
                      as String,
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as int,
            filePath: null == filePath
                ? _value.filePath
                : filePath // ignore: cast_nullable_to_non_nullable
                      as String,
            features: freezed == features
                ? _value.features
                : features // ignore: cast_nullable_to_non_nullable
                      as SongFeaturesModel?,
            albumArt: freezed == albumArt
                ? _value.albumArt
                : albumArt // ignore: cast_nullable_to_non_nullable
                      as String?,
            year: freezed == year
                ? _value.year
                : year // ignore: cast_nullable_to_non_nullable
                      as int?,
            genre: freezed == genre
                ? _value.genre
                : genre // ignore: cast_nullable_to_non_nullable
                      as String?,
            trackNumber: freezed == trackNumber
                ? _value.trackNumber
                : trackNumber // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }

  /// Create a copy of SongModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SongFeaturesModelCopyWith<$Res>? get features {
    if (_value.features == null) {
      return null;
    }

    return $SongFeaturesModelCopyWith<$Res>(_value.features!, (value) {
      return _then(_value.copyWith(features: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SongModelImplCopyWith<$Res>
    implements $SongModelCopyWith<$Res> {
  factory _$$SongModelImplCopyWith(
    _$SongModelImpl value,
    $Res Function(_$SongModelImpl) then,
  ) = __$$SongModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String artist,
    String album,
    int duration,
    String filePath,
    SongFeaturesModel? features,
    String? albumArt,
    int? year,
    String? genre,
    int? trackNumber,
  });

  @override
  $SongFeaturesModelCopyWith<$Res>? get features;
}

/// @nodoc
class __$$SongModelImplCopyWithImpl<$Res>
    extends _$SongModelCopyWithImpl<$Res, _$SongModelImpl>
    implements _$$SongModelImplCopyWith<$Res> {
  __$$SongModelImplCopyWithImpl(
    _$SongModelImpl _value,
    $Res Function(_$SongModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SongModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? artist = null,
    Object? album = null,
    Object? duration = null,
    Object? filePath = null,
    Object? features = freezed,
    Object? albumArt = freezed,
    Object? year = freezed,
    Object? genre = freezed,
    Object? trackNumber = freezed,
  }) {
    return _then(
      _$SongModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        artist: null == artist
            ? _value.artist
            : artist // ignore: cast_nullable_to_non_nullable
                  as String,
        album: null == album
            ? _value.album
            : album // ignore: cast_nullable_to_non_nullable
                  as String,
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as int,
        filePath: null == filePath
            ? _value.filePath
            : filePath // ignore: cast_nullable_to_non_nullable
                  as String,
        features: freezed == features
            ? _value.features
            : features // ignore: cast_nullable_to_non_nullable
                  as SongFeaturesModel?,
        albumArt: freezed == albumArt
            ? _value.albumArt
            : albumArt // ignore: cast_nullable_to_non_nullable
                  as String?,
        year: freezed == year
            ? _value.year
            : year // ignore: cast_nullable_to_non_nullable
                  as int?,
        genre: freezed == genre
            ? _value.genre
            : genre // ignore: cast_nullable_to_non_nullable
                  as String?,
        trackNumber: freezed == trackNumber
            ? _value.trackNumber
            : trackNumber // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SongModelImpl implements _SongModel {
  const _$SongModelImpl({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.filePath,
    this.features,
    this.albumArt,
    this.year,
    this.genre,
    this.trackNumber,
  });

  factory _$SongModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SongModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String artist;
  @override
  final String album;
  @override
  final int duration;
  @override
  final String filePath;
  @override
  final SongFeaturesModel? features;
  @override
  final String? albumArt;
  @override
  final int? year;
  @override
  final String? genre;
  @override
  final int? trackNumber;

  @override
  String toString() {
    return 'SongModel(id: $id, title: $title, artist: $artist, album: $album, duration: $duration, filePath: $filePath, features: $features, albumArt: $albumArt, year: $year, genre: $genre, trackNumber: $trackNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SongModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.artist, artist) || other.artist == artist) &&
            (identical(other.album, album) || other.album == album) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.features, features) ||
                other.features == features) &&
            (identical(other.albumArt, albumArt) ||
                other.albumArt == albumArt) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.genre, genre) || other.genre == genre) &&
            (identical(other.trackNumber, trackNumber) ||
                other.trackNumber == trackNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    artist,
    album,
    duration,
    filePath,
    features,
    albumArt,
    year,
    genre,
    trackNumber,
  );

  /// Create a copy of SongModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SongModelImplCopyWith<_$SongModelImpl> get copyWith =>
      __$$SongModelImplCopyWithImpl<_$SongModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SongModelImplToJson(this);
  }
}

abstract class _SongModel implements SongModel {
  const factory _SongModel({
    required final String id,
    required final String title,
    required final String artist,
    required final String album,
    required final int duration,
    required final String filePath,
    final SongFeaturesModel? features,
    final String? albumArt,
    final int? year,
    final String? genre,
    final int? trackNumber,
  }) = _$SongModelImpl;

  factory _SongModel.fromJson(Map<String, dynamic> json) =
      _$SongModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get artist;
  @override
  String get album;
  @override
  int get duration;
  @override
  String get filePath;
  @override
  SongFeaturesModel? get features;
  @override
  String? get albumArt;
  @override
  int? get year;
  @override
  String? get genre;
  @override
  int? get trackNumber;

  /// Create a copy of SongModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SongModelImplCopyWith<_$SongModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

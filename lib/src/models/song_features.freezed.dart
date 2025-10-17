// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song_features.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SongFeatures _$SongFeaturesFromJson(Map<String, dynamic> json) {
  return _SongFeatures.fromJson(json);
}

/// @nodoc
mixin _$SongFeatures {
  // Basic categorical features
  String get tempo =>
      throw _privateConstructorUsedError; // e.g. "Fast", "Medium", "Slow"
  String get beat =>
      throw _privateConstructorUsedError; // e.g. "Strong", "Soft", "No Beat"
  String get energy =>
      throw _privateConstructorUsedError; // e.g. "High", "Medium", "Low"
  List<String> get instruments =>
      throw _privateConstructorUsedError; // e.g. ["Piano", "Guitar"]
  String? get vocals =>
      throw _privateConstructorUsedError; // e.g. "Emotional", "Energetic", or null for instrumental
  String get mood =>
      throw _privateConstructorUsedError; // e.g. "Happy", "Sad", "Calm"
  // YAMNet analysis results
  List<String> get yamnetInstruments =>
      throw _privateConstructorUsedError; // YAMNet detected instruments
  bool get hasVocals =>
      throw _privateConstructorUsedError; // YAMNet vocal detection
  String get estimatedGenre =>
      throw _privateConstructorUsedError; // YAMNet genre classification
  double get yamnetEnergy =>
      throw _privateConstructorUsedError; // YAMNet energy score (0.0-1.0)
  List<String> get moodTags =>
      throw _privateConstructorUsedError; // YAMNet mood tags
  // Signal processing features
  double get tempoBpm => throw _privateConstructorUsedError; // Actual BPM value
  double get beatStrength =>
      throw _privateConstructorUsedError; // Beat strength (0.0-1.0)
  double get signalEnergy =>
      throw _privateConstructorUsedError; // Signal energy (0.0-1.0)
  double get brightness =>
      throw _privateConstructorUsedError; // Spectral brightness
  double get danceability =>
      throw _privateConstructorUsedError; // Danceability score (0.0-1.0)
  // Combined metrics
  double get overallEnergy =>
      throw _privateConstructorUsedError; // Combined energy score
  double get intensity =>
      throw _privateConstructorUsedError; // Overall intensity
  double get spectralCentroid =>
      throw _privateConstructorUsedError; // Spectral centroid
  double get spectralRolloff =>
      throw _privateConstructorUsedError; // Spectral rolloff
  double get zeroCrossingRate =>
      throw _privateConstructorUsedError; // Zero crossing rate
  double get spectralFlux =>
      throw _privateConstructorUsedError; // Spectral flux
  double get complexity =>
      throw _privateConstructorUsedError; // Complexity score
  double get valence =>
      throw _privateConstructorUsedError; // Valence (emotional positivity)
  double get arousal =>
      throw _privateConstructorUsedError; // Arousal (emotional intensity)
  double get confidence =>
      throw _privateConstructorUsedError; // Analysis confidence
  // Analysis metadata
  DateTime get analyzedAt =>
      throw _privateConstructorUsedError; // When analysis was performed
  String get analyzerVersion => throw _privateConstructorUsedError;

  /// Serializes this SongFeatures to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SongFeatures
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SongFeaturesCopyWith<SongFeatures> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SongFeaturesCopyWith<$Res> {
  factory $SongFeaturesCopyWith(
    SongFeatures value,
    $Res Function(SongFeatures) then,
  ) = _$SongFeaturesCopyWithImpl<$Res, SongFeatures>;
  @useResult
  $Res call({
    String tempo,
    String beat,
    String energy,
    List<String> instruments,
    String? vocals,
    String mood,
    List<String> yamnetInstruments,
    bool hasVocals,
    String estimatedGenre,
    double yamnetEnergy,
    List<String> moodTags,
    double tempoBpm,
    double beatStrength,
    double signalEnergy,
    double brightness,
    double danceability,
    double overallEnergy,
    double intensity,
    double spectralCentroid,
    double spectralRolloff,
    double zeroCrossingRate,
    double spectralFlux,
    double complexity,
    double valence,
    double arousal,
    double confidence,
    DateTime analyzedAt,
    String analyzerVersion,
  });
}

/// @nodoc
class _$SongFeaturesCopyWithImpl<$Res, $Val extends SongFeatures>
    implements $SongFeaturesCopyWith<$Res> {
  _$SongFeaturesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SongFeatures
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tempo = null,
    Object? beat = null,
    Object? energy = null,
    Object? instruments = null,
    Object? vocals = freezed,
    Object? mood = null,
    Object? yamnetInstruments = null,
    Object? hasVocals = null,
    Object? estimatedGenre = null,
    Object? yamnetEnergy = null,
    Object? moodTags = null,
    Object? tempoBpm = null,
    Object? beatStrength = null,
    Object? signalEnergy = null,
    Object? brightness = null,
    Object? danceability = null,
    Object? overallEnergy = null,
    Object? intensity = null,
    Object? spectralCentroid = null,
    Object? spectralRolloff = null,
    Object? zeroCrossingRate = null,
    Object? spectralFlux = null,
    Object? complexity = null,
    Object? valence = null,
    Object? arousal = null,
    Object? confidence = null,
    Object? analyzedAt = null,
    Object? analyzerVersion = null,
  }) {
    return _then(
      _value.copyWith(
            tempo: null == tempo
                ? _value.tempo
                : tempo // ignore: cast_nullable_to_non_nullable
                      as String,
            beat: null == beat
                ? _value.beat
                : beat // ignore: cast_nullable_to_non_nullable
                      as String,
            energy: null == energy
                ? _value.energy
                : energy // ignore: cast_nullable_to_non_nullable
                      as String,
            instruments: null == instruments
                ? _value.instruments
                : instruments // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            vocals: freezed == vocals
                ? _value.vocals
                : vocals // ignore: cast_nullable_to_non_nullable
                      as String?,
            mood: null == mood
                ? _value.mood
                : mood // ignore: cast_nullable_to_non_nullable
                      as String,
            yamnetInstruments: null == yamnetInstruments
                ? _value.yamnetInstruments
                : yamnetInstruments // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            hasVocals: null == hasVocals
                ? _value.hasVocals
                : hasVocals // ignore: cast_nullable_to_non_nullable
                      as bool,
            estimatedGenre: null == estimatedGenre
                ? _value.estimatedGenre
                : estimatedGenre // ignore: cast_nullable_to_non_nullable
                      as String,
            yamnetEnergy: null == yamnetEnergy
                ? _value.yamnetEnergy
                : yamnetEnergy // ignore: cast_nullable_to_non_nullable
                      as double,
            moodTags: null == moodTags
                ? _value.moodTags
                : moodTags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            tempoBpm: null == tempoBpm
                ? _value.tempoBpm
                : tempoBpm // ignore: cast_nullable_to_non_nullable
                      as double,
            beatStrength: null == beatStrength
                ? _value.beatStrength
                : beatStrength // ignore: cast_nullable_to_non_nullable
                      as double,
            signalEnergy: null == signalEnergy
                ? _value.signalEnergy
                : signalEnergy // ignore: cast_nullable_to_non_nullable
                      as double,
            brightness: null == brightness
                ? _value.brightness
                : brightness // ignore: cast_nullable_to_non_nullable
                      as double,
            danceability: null == danceability
                ? _value.danceability
                : danceability // ignore: cast_nullable_to_non_nullable
                      as double,
            overallEnergy: null == overallEnergy
                ? _value.overallEnergy
                : overallEnergy // ignore: cast_nullable_to_non_nullable
                      as double,
            intensity: null == intensity
                ? _value.intensity
                : intensity // ignore: cast_nullable_to_non_nullable
                      as double,
            spectralCentroid: null == spectralCentroid
                ? _value.spectralCentroid
                : spectralCentroid // ignore: cast_nullable_to_non_nullable
                      as double,
            spectralRolloff: null == spectralRolloff
                ? _value.spectralRolloff
                : spectralRolloff // ignore: cast_nullable_to_non_nullable
                      as double,
            zeroCrossingRate: null == zeroCrossingRate
                ? _value.zeroCrossingRate
                : zeroCrossingRate // ignore: cast_nullable_to_non_nullable
                      as double,
            spectralFlux: null == spectralFlux
                ? _value.spectralFlux
                : spectralFlux // ignore: cast_nullable_to_non_nullable
                      as double,
            complexity: null == complexity
                ? _value.complexity
                : complexity // ignore: cast_nullable_to_non_nullable
                      as double,
            valence: null == valence
                ? _value.valence
                : valence // ignore: cast_nullable_to_non_nullable
                      as double,
            arousal: null == arousal
                ? _value.arousal
                : arousal // ignore: cast_nullable_to_non_nullable
                      as double,
            confidence: null == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                      as double,
            analyzedAt: null == analyzedAt
                ? _value.analyzedAt
                : analyzedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            analyzerVersion: null == analyzerVersion
                ? _value.analyzerVersion
                : analyzerVersion // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SongFeaturesImplCopyWith<$Res>
    implements $SongFeaturesCopyWith<$Res> {
  factory _$$SongFeaturesImplCopyWith(
    _$SongFeaturesImpl value,
    $Res Function(_$SongFeaturesImpl) then,
  ) = __$$SongFeaturesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String tempo,
    String beat,
    String energy,
    List<String> instruments,
    String? vocals,
    String mood,
    List<String> yamnetInstruments,
    bool hasVocals,
    String estimatedGenre,
    double yamnetEnergy,
    List<String> moodTags,
    double tempoBpm,
    double beatStrength,
    double signalEnergy,
    double brightness,
    double danceability,
    double overallEnergy,
    double intensity,
    double spectralCentroid,
    double spectralRolloff,
    double zeroCrossingRate,
    double spectralFlux,
    double complexity,
    double valence,
    double arousal,
    double confidence,
    DateTime analyzedAt,
    String analyzerVersion,
  });
}

/// @nodoc
class __$$SongFeaturesImplCopyWithImpl<$Res>
    extends _$SongFeaturesCopyWithImpl<$Res, _$SongFeaturesImpl>
    implements _$$SongFeaturesImplCopyWith<$Res> {
  __$$SongFeaturesImplCopyWithImpl(
    _$SongFeaturesImpl _value,
    $Res Function(_$SongFeaturesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SongFeatures
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tempo = null,
    Object? beat = null,
    Object? energy = null,
    Object? instruments = null,
    Object? vocals = freezed,
    Object? mood = null,
    Object? yamnetInstruments = null,
    Object? hasVocals = null,
    Object? estimatedGenre = null,
    Object? yamnetEnergy = null,
    Object? moodTags = null,
    Object? tempoBpm = null,
    Object? beatStrength = null,
    Object? signalEnergy = null,
    Object? brightness = null,
    Object? danceability = null,
    Object? overallEnergy = null,
    Object? intensity = null,
    Object? spectralCentroid = null,
    Object? spectralRolloff = null,
    Object? zeroCrossingRate = null,
    Object? spectralFlux = null,
    Object? complexity = null,
    Object? valence = null,
    Object? arousal = null,
    Object? confidence = null,
    Object? analyzedAt = null,
    Object? analyzerVersion = null,
  }) {
    return _then(
      _$SongFeaturesImpl(
        tempo: null == tempo
            ? _value.tempo
            : tempo // ignore: cast_nullable_to_non_nullable
                  as String,
        beat: null == beat
            ? _value.beat
            : beat // ignore: cast_nullable_to_non_nullable
                  as String,
        energy: null == energy
            ? _value.energy
            : energy // ignore: cast_nullable_to_non_nullable
                  as String,
        instruments: null == instruments
            ? _value._instruments
            : instruments // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        vocals: freezed == vocals
            ? _value.vocals
            : vocals // ignore: cast_nullable_to_non_nullable
                  as String?,
        mood: null == mood
            ? _value.mood
            : mood // ignore: cast_nullable_to_non_nullable
                  as String,
        yamnetInstruments: null == yamnetInstruments
            ? _value._yamnetInstruments
            : yamnetInstruments // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        hasVocals: null == hasVocals
            ? _value.hasVocals
            : hasVocals // ignore: cast_nullable_to_non_nullable
                  as bool,
        estimatedGenre: null == estimatedGenre
            ? _value.estimatedGenre
            : estimatedGenre // ignore: cast_nullable_to_non_nullable
                  as String,
        yamnetEnergy: null == yamnetEnergy
            ? _value.yamnetEnergy
            : yamnetEnergy // ignore: cast_nullable_to_non_nullable
                  as double,
        moodTags: null == moodTags
            ? _value._moodTags
            : moodTags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        tempoBpm: null == tempoBpm
            ? _value.tempoBpm
            : tempoBpm // ignore: cast_nullable_to_non_nullable
                  as double,
        beatStrength: null == beatStrength
            ? _value.beatStrength
            : beatStrength // ignore: cast_nullable_to_non_nullable
                  as double,
        signalEnergy: null == signalEnergy
            ? _value.signalEnergy
            : signalEnergy // ignore: cast_nullable_to_non_nullable
                  as double,
        brightness: null == brightness
            ? _value.brightness
            : brightness // ignore: cast_nullable_to_non_nullable
                  as double,
        danceability: null == danceability
            ? _value.danceability
            : danceability // ignore: cast_nullable_to_non_nullable
                  as double,
        overallEnergy: null == overallEnergy
            ? _value.overallEnergy
            : overallEnergy // ignore: cast_nullable_to_non_nullable
                  as double,
        intensity: null == intensity
            ? _value.intensity
            : intensity // ignore: cast_nullable_to_non_nullable
                  as double,
        spectralCentroid: null == spectralCentroid
            ? _value.spectralCentroid
            : spectralCentroid // ignore: cast_nullable_to_non_nullable
                  as double,
        spectralRolloff: null == spectralRolloff
            ? _value.spectralRolloff
            : spectralRolloff // ignore: cast_nullable_to_non_nullable
                  as double,
        zeroCrossingRate: null == zeroCrossingRate
            ? _value.zeroCrossingRate
            : zeroCrossingRate // ignore: cast_nullable_to_non_nullable
                  as double,
        spectralFlux: null == spectralFlux
            ? _value.spectralFlux
            : spectralFlux // ignore: cast_nullable_to_non_nullable
                  as double,
        complexity: null == complexity
            ? _value.complexity
            : complexity // ignore: cast_nullable_to_non_nullable
                  as double,
        valence: null == valence
            ? _value.valence
            : valence // ignore: cast_nullable_to_non_nullable
                  as double,
        arousal: null == arousal
            ? _value.arousal
            : arousal // ignore: cast_nullable_to_non_nullable
                  as double,
        confidence: null == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double,
        analyzedAt: null == analyzedAt
            ? _value.analyzedAt
            : analyzedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        analyzerVersion: null == analyzerVersion
            ? _value.analyzerVersion
            : analyzerVersion // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SongFeaturesImpl implements _SongFeatures {
  const _$SongFeaturesImpl({
    required this.tempo,
    required this.beat,
    required this.energy,
    required final List<String> instruments,
    this.vocals,
    required this.mood,
    required final List<String> yamnetInstruments,
    required this.hasVocals,
    required this.estimatedGenre,
    required this.yamnetEnergy,
    required final List<String> moodTags,
    required this.tempoBpm,
    required this.beatStrength,
    required this.signalEnergy,
    required this.brightness,
    required this.danceability,
    required this.overallEnergy,
    required this.intensity,
    required this.spectralCentroid,
    required this.spectralRolloff,
    required this.zeroCrossingRate,
    required this.spectralFlux,
    required this.complexity,
    required this.valence,
    required this.arousal,
    required this.confidence,
    required this.analyzedAt,
    required this.analyzerVersion,
  }) : _instruments = instruments,
       _yamnetInstruments = yamnetInstruments,
       _moodTags = moodTags;

  factory _$SongFeaturesImpl.fromJson(Map<String, dynamic> json) =>
      _$$SongFeaturesImplFromJson(json);

  // Basic categorical features
  @override
  final String tempo;
  // e.g. "Fast", "Medium", "Slow"
  @override
  final String beat;
  // e.g. "Strong", "Soft", "No Beat"
  @override
  final String energy;
  // e.g. "High", "Medium", "Low"
  final List<String> _instruments;
  // e.g. "High", "Medium", "Low"
  @override
  List<String> get instruments {
    if (_instruments is EqualUnmodifiableListView) return _instruments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_instruments);
  }

  // e.g. ["Piano", "Guitar"]
  @override
  final String? vocals;
  // e.g. "Emotional", "Energetic", or null for instrumental
  @override
  final String mood;
  // e.g. "Happy", "Sad", "Calm"
  // YAMNet analysis results
  final List<String> _yamnetInstruments;
  // e.g. "Happy", "Sad", "Calm"
  // YAMNet analysis results
  @override
  List<String> get yamnetInstruments {
    if (_yamnetInstruments is EqualUnmodifiableListView)
      return _yamnetInstruments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_yamnetInstruments);
  }

  // YAMNet detected instruments
  @override
  final bool hasVocals;
  // YAMNet vocal detection
  @override
  final String estimatedGenre;
  // YAMNet genre classification
  @override
  final double yamnetEnergy;
  // YAMNet energy score (0.0-1.0)
  final List<String> _moodTags;
  // YAMNet energy score (0.0-1.0)
  @override
  List<String> get moodTags {
    if (_moodTags is EqualUnmodifiableListView) return _moodTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_moodTags);
  }

  // YAMNet mood tags
  // Signal processing features
  @override
  final double tempoBpm;
  // Actual BPM value
  @override
  final double beatStrength;
  // Beat strength (0.0-1.0)
  @override
  final double signalEnergy;
  // Signal energy (0.0-1.0)
  @override
  final double brightness;
  // Spectral brightness
  @override
  final double danceability;
  // Danceability score (0.0-1.0)
  // Combined metrics
  @override
  final double overallEnergy;
  // Combined energy score
  @override
  final double intensity;
  // Overall intensity
  @override
  final double spectralCentroid;
  // Spectral centroid
  @override
  final double spectralRolloff;
  // Spectral rolloff
  @override
  final double zeroCrossingRate;
  // Zero crossing rate
  @override
  final double spectralFlux;
  // Spectral flux
  @override
  final double complexity;
  // Complexity score
  @override
  final double valence;
  // Valence (emotional positivity)
  @override
  final double arousal;
  // Arousal (emotional intensity)
  @override
  final double confidence;
  // Analysis confidence
  // Analysis metadata
  @override
  final DateTime analyzedAt;
  // When analysis was performed
  @override
  final String analyzerVersion;

  @override
  String toString() {
    return 'SongFeatures(tempo: $tempo, beat: $beat, energy: $energy, instruments: $instruments, vocals: $vocals, mood: $mood, yamnetInstruments: $yamnetInstruments, hasVocals: $hasVocals, estimatedGenre: $estimatedGenre, yamnetEnergy: $yamnetEnergy, moodTags: $moodTags, tempoBpm: $tempoBpm, beatStrength: $beatStrength, signalEnergy: $signalEnergy, brightness: $brightness, danceability: $danceability, overallEnergy: $overallEnergy, intensity: $intensity, spectralCentroid: $spectralCentroid, spectralRolloff: $spectralRolloff, zeroCrossingRate: $zeroCrossingRate, spectralFlux: $spectralFlux, complexity: $complexity, valence: $valence, arousal: $arousal, confidence: $confidence, analyzedAt: $analyzedAt, analyzerVersion: $analyzerVersion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SongFeaturesImpl &&
            (identical(other.tempo, tempo) || other.tempo == tempo) &&
            (identical(other.beat, beat) || other.beat == beat) &&
            (identical(other.energy, energy) || other.energy == energy) &&
            const DeepCollectionEquality().equals(
              other._instruments,
              _instruments,
            ) &&
            (identical(other.vocals, vocals) || other.vocals == vocals) &&
            (identical(other.mood, mood) || other.mood == mood) &&
            const DeepCollectionEquality().equals(
              other._yamnetInstruments,
              _yamnetInstruments,
            ) &&
            (identical(other.hasVocals, hasVocals) ||
                other.hasVocals == hasVocals) &&
            (identical(other.estimatedGenre, estimatedGenre) ||
                other.estimatedGenre == estimatedGenre) &&
            (identical(other.yamnetEnergy, yamnetEnergy) ||
                other.yamnetEnergy == yamnetEnergy) &&
            const DeepCollectionEquality().equals(other._moodTags, _moodTags) &&
            (identical(other.tempoBpm, tempoBpm) ||
                other.tempoBpm == tempoBpm) &&
            (identical(other.beatStrength, beatStrength) ||
                other.beatStrength == beatStrength) &&
            (identical(other.signalEnergy, signalEnergy) ||
                other.signalEnergy == signalEnergy) &&
            (identical(other.brightness, brightness) ||
                other.brightness == brightness) &&
            (identical(other.danceability, danceability) ||
                other.danceability == danceability) &&
            (identical(other.overallEnergy, overallEnergy) ||
                other.overallEnergy == overallEnergy) &&
            (identical(other.intensity, intensity) ||
                other.intensity == intensity) &&
            (identical(other.spectralCentroid, spectralCentroid) ||
                other.spectralCentroid == spectralCentroid) &&
            (identical(other.spectralRolloff, spectralRolloff) ||
                other.spectralRolloff == spectralRolloff) &&
            (identical(other.zeroCrossingRate, zeroCrossingRate) ||
                other.zeroCrossingRate == zeroCrossingRate) &&
            (identical(other.spectralFlux, spectralFlux) ||
                other.spectralFlux == spectralFlux) &&
            (identical(other.complexity, complexity) ||
                other.complexity == complexity) &&
            (identical(other.valence, valence) || other.valence == valence) &&
            (identical(other.arousal, arousal) || other.arousal == arousal) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.analyzedAt, analyzedAt) ||
                other.analyzedAt == analyzedAt) &&
            (identical(other.analyzerVersion, analyzerVersion) ||
                other.analyzerVersion == analyzerVersion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    tempo,
    beat,
    energy,
    const DeepCollectionEquality().hash(_instruments),
    vocals,
    mood,
    const DeepCollectionEquality().hash(_yamnetInstruments),
    hasVocals,
    estimatedGenre,
    yamnetEnergy,
    const DeepCollectionEquality().hash(_moodTags),
    tempoBpm,
    beatStrength,
    signalEnergy,
    brightness,
    danceability,
    overallEnergy,
    intensity,
    spectralCentroid,
    spectralRolloff,
    zeroCrossingRate,
    spectralFlux,
    complexity,
    valence,
    arousal,
    confidence,
    analyzedAt,
    analyzerVersion,
  ]);

  /// Create a copy of SongFeatures
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SongFeaturesImplCopyWith<_$SongFeaturesImpl> get copyWith =>
      __$$SongFeaturesImplCopyWithImpl<_$SongFeaturesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SongFeaturesImplToJson(this);
  }
}

abstract class _SongFeatures implements SongFeatures {
  const factory _SongFeatures({
    required final String tempo,
    required final String beat,
    required final String energy,
    required final List<String> instruments,
    final String? vocals,
    required final String mood,
    required final List<String> yamnetInstruments,
    required final bool hasVocals,
    required final String estimatedGenre,
    required final double yamnetEnergy,
    required final List<String> moodTags,
    required final double tempoBpm,
    required final double beatStrength,
    required final double signalEnergy,
    required final double brightness,
    required final double danceability,
    required final double overallEnergy,
    required final double intensity,
    required final double spectralCentroid,
    required final double spectralRolloff,
    required final double zeroCrossingRate,
    required final double spectralFlux,
    required final double complexity,
    required final double valence,
    required final double arousal,
    required final double confidence,
    required final DateTime analyzedAt,
    required final String analyzerVersion,
  }) = _$SongFeaturesImpl;

  factory _SongFeatures.fromJson(Map<String, dynamic> json) =
      _$SongFeaturesImpl.fromJson;

  // Basic categorical features
  @override
  String get tempo; // e.g. "Fast", "Medium", "Slow"
  @override
  String get beat; // e.g. "Strong", "Soft", "No Beat"
  @override
  String get energy; // e.g. "High", "Medium", "Low"
  @override
  List<String> get instruments; // e.g. ["Piano", "Guitar"]
  @override
  String? get vocals; // e.g. "Emotional", "Energetic", or null for instrumental
  @override
  String get mood; // e.g. "Happy", "Sad", "Calm"
  // YAMNet analysis results
  @override
  List<String> get yamnetInstruments; // YAMNet detected instruments
  @override
  bool get hasVocals; // YAMNet vocal detection
  @override
  String get estimatedGenre; // YAMNet genre classification
  @override
  double get yamnetEnergy; // YAMNet energy score (0.0-1.0)
  @override
  List<String> get moodTags; // YAMNet mood tags
  // Signal processing features
  @override
  double get tempoBpm; // Actual BPM value
  @override
  double get beatStrength; // Beat strength (0.0-1.0)
  @override
  double get signalEnergy; // Signal energy (0.0-1.0)
  @override
  double get brightness; // Spectral brightness
  @override
  double get danceability; // Danceability score (0.0-1.0)
  // Combined metrics
  @override
  double get overallEnergy; // Combined energy score
  @override
  double get intensity; // Overall intensity
  @override
  double get spectralCentroid; // Spectral centroid
  @override
  double get spectralRolloff; // Spectral rolloff
  @override
  double get zeroCrossingRate; // Zero crossing rate
  @override
  double get spectralFlux; // Spectral flux
  @override
  double get complexity; // Complexity score
  @override
  double get valence; // Valence (emotional positivity)
  @override
  double get arousal; // Arousal (emotional intensity)
  @override
  double get confidence; // Analysis confidence
  // Analysis metadata
  @override
  DateTime get analyzedAt; // When analysis was performed
  @override
  String get analyzerVersion;

  /// Create a copy of SongFeatures
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SongFeaturesImplCopyWith<_$SongFeaturesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

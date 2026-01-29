// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'extracted_song_features.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExtractedSongFeatures {

// Basic categorical features
 String get tempo;// e.g. "Fast", "Medium", "Slow"
 String get beat;// e.g. "Strong", "Soft", "No Beat"
 String get energy;// e.g. "High", "Medium", "Low"
 List<String> get instruments;// e.g. ["Piano", "Guitar"]
 String? get vocals;// e.g. "Emotional", "Energetic", or null for instrumental
 String get mood;// e.g. "Happy", "Sad", "Calm"
// YAMNet analysis results
 List<String> get yamnetInstruments;// YAMNet detected instruments
 bool get hasVocals;// YAMNet vocal detection
 String get estimatedGenre;// YAMNet genre classification
 double get yamnetEnergy;// YAMNet energy score (0.0-1.0)
 List<String> get moodTags;// YAMNet mood tags
// Signal processing features
 double get tempoBpm;// Actual BPM value
 double get beatStrength;// Beat strength (0.0-1.0)
 double get signalEnergy;// Signal energy (0.0-1.0)
 double get brightness;// Spectral brightness
 double get danceability;// Danceability score (0.0-1.0)
 double get loudness;// Perceived loudness (0.0-1.0, normalized)
// Combined metrics
 double get overallEnergy;// Combined energy score
 double get intensity;// Overall intensity
 double get spectralCentroid;// Spectral centroid
 double get spectralRolloff;// Spectral rolloff
 double get zeroCrossingRate;// Zero crossing rate
 double get spectralFlux;// Spectral flux
 double get complexity;// Complexity score
 double get valence;// Valence (emotional positivity)
 double get arousal;// Arousal (emotional intensity)
 double get confidence;// Analysis confidence
// Analysis metadata
 DateTime get analyzedAt;// When analysis was performed
 String get analyzerVersion;
/// Create a copy of ExtractedSongFeatures
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExtractedSongFeaturesCopyWith<ExtractedSongFeatures> get copyWith => _$ExtractedSongFeaturesCopyWithImpl<ExtractedSongFeatures>(this as ExtractedSongFeatures, _$identity);

  /// Serializes this ExtractedSongFeatures to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExtractedSongFeatures&&(identical(other.tempo, tempo) || other.tempo == tempo)&&(identical(other.beat, beat) || other.beat == beat)&&(identical(other.energy, energy) || other.energy == energy)&&const DeepCollectionEquality().equals(other.instruments, instruments)&&(identical(other.vocals, vocals) || other.vocals == vocals)&&(identical(other.mood, mood) || other.mood == mood)&&const DeepCollectionEquality().equals(other.yamnetInstruments, yamnetInstruments)&&(identical(other.hasVocals, hasVocals) || other.hasVocals == hasVocals)&&(identical(other.estimatedGenre, estimatedGenre) || other.estimatedGenre == estimatedGenre)&&(identical(other.yamnetEnergy, yamnetEnergy) || other.yamnetEnergy == yamnetEnergy)&&const DeepCollectionEquality().equals(other.moodTags, moodTags)&&(identical(other.tempoBpm, tempoBpm) || other.tempoBpm == tempoBpm)&&(identical(other.beatStrength, beatStrength) || other.beatStrength == beatStrength)&&(identical(other.signalEnergy, signalEnergy) || other.signalEnergy == signalEnergy)&&(identical(other.brightness, brightness) || other.brightness == brightness)&&(identical(other.danceability, danceability) || other.danceability == danceability)&&(identical(other.loudness, loudness) || other.loudness == loudness)&&(identical(other.overallEnergy, overallEnergy) || other.overallEnergy == overallEnergy)&&(identical(other.intensity, intensity) || other.intensity == intensity)&&(identical(other.spectralCentroid, spectralCentroid) || other.spectralCentroid == spectralCentroid)&&(identical(other.spectralRolloff, spectralRolloff) || other.spectralRolloff == spectralRolloff)&&(identical(other.zeroCrossingRate, zeroCrossingRate) || other.zeroCrossingRate == zeroCrossingRate)&&(identical(other.spectralFlux, spectralFlux) || other.spectralFlux == spectralFlux)&&(identical(other.complexity, complexity) || other.complexity == complexity)&&(identical(other.valence, valence) || other.valence == valence)&&(identical(other.arousal, arousal) || other.arousal == arousal)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.analyzedAt, analyzedAt) || other.analyzedAt == analyzedAt)&&(identical(other.analyzerVersion, analyzerVersion) || other.analyzerVersion == analyzerVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,tempo,beat,energy,const DeepCollectionEquality().hash(instruments),vocals,mood,const DeepCollectionEquality().hash(yamnetInstruments),hasVocals,estimatedGenre,yamnetEnergy,const DeepCollectionEquality().hash(moodTags),tempoBpm,beatStrength,signalEnergy,brightness,danceability,loudness,overallEnergy,intensity,spectralCentroid,spectralRolloff,zeroCrossingRate,spectralFlux,complexity,valence,arousal,confidence,analyzedAt,analyzerVersion]);

@override
String toString() {
  return 'ExtractedSongFeatures(tempo: $tempo, beat: $beat, energy: $energy, instruments: $instruments, vocals: $vocals, mood: $mood, yamnetInstruments: $yamnetInstruments, hasVocals: $hasVocals, estimatedGenre: $estimatedGenre, yamnetEnergy: $yamnetEnergy, moodTags: $moodTags, tempoBpm: $tempoBpm, beatStrength: $beatStrength, signalEnergy: $signalEnergy, brightness: $brightness, danceability: $danceability, loudness: $loudness, overallEnergy: $overallEnergy, intensity: $intensity, spectralCentroid: $spectralCentroid, spectralRolloff: $spectralRolloff, zeroCrossingRate: $zeroCrossingRate, spectralFlux: $spectralFlux, complexity: $complexity, valence: $valence, arousal: $arousal, confidence: $confidence, analyzedAt: $analyzedAt, analyzerVersion: $analyzerVersion)';
}


}

/// @nodoc
abstract mixin class $ExtractedSongFeaturesCopyWith<$Res>  {
  factory $ExtractedSongFeaturesCopyWith(ExtractedSongFeatures value, $Res Function(ExtractedSongFeatures) _then) = _$ExtractedSongFeaturesCopyWithImpl;
@useResult
$Res call({
 String tempo, String beat, String energy, List<String> instruments, String? vocals, String mood, List<String> yamnetInstruments, bool hasVocals, String estimatedGenre, double yamnetEnergy, List<String> moodTags, double tempoBpm, double beatStrength, double signalEnergy, double brightness, double danceability, double loudness, double overallEnergy, double intensity, double spectralCentroid, double spectralRolloff, double zeroCrossingRate, double spectralFlux, double complexity, double valence, double arousal, double confidence, DateTime analyzedAt, String analyzerVersion
});




}
/// @nodoc
class _$ExtractedSongFeaturesCopyWithImpl<$Res>
    implements $ExtractedSongFeaturesCopyWith<$Res> {
  _$ExtractedSongFeaturesCopyWithImpl(this._self, this._then);

  final ExtractedSongFeatures _self;
  final $Res Function(ExtractedSongFeatures) _then;

/// Create a copy of ExtractedSongFeatures
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tempo = null,Object? beat = null,Object? energy = null,Object? instruments = null,Object? vocals = freezed,Object? mood = null,Object? yamnetInstruments = null,Object? hasVocals = null,Object? estimatedGenre = null,Object? yamnetEnergy = null,Object? moodTags = null,Object? tempoBpm = null,Object? beatStrength = null,Object? signalEnergy = null,Object? brightness = null,Object? danceability = null,Object? loudness = null,Object? overallEnergy = null,Object? intensity = null,Object? spectralCentroid = null,Object? spectralRolloff = null,Object? zeroCrossingRate = null,Object? spectralFlux = null,Object? complexity = null,Object? valence = null,Object? arousal = null,Object? confidence = null,Object? analyzedAt = null,Object? analyzerVersion = null,}) {
  return _then(_self.copyWith(
tempo: null == tempo ? _self.tempo : tempo // ignore: cast_nullable_to_non_nullable
as String,beat: null == beat ? _self.beat : beat // ignore: cast_nullable_to_non_nullable
as String,energy: null == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as String,instruments: null == instruments ? _self.instruments : instruments // ignore: cast_nullable_to_non_nullable
as List<String>,vocals: freezed == vocals ? _self.vocals : vocals // ignore: cast_nullable_to_non_nullable
as String?,mood: null == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as String,yamnetInstruments: null == yamnetInstruments ? _self.yamnetInstruments : yamnetInstruments // ignore: cast_nullable_to_non_nullable
as List<String>,hasVocals: null == hasVocals ? _self.hasVocals : hasVocals // ignore: cast_nullable_to_non_nullable
as bool,estimatedGenre: null == estimatedGenre ? _self.estimatedGenre : estimatedGenre // ignore: cast_nullable_to_non_nullable
as String,yamnetEnergy: null == yamnetEnergy ? _self.yamnetEnergy : yamnetEnergy // ignore: cast_nullable_to_non_nullable
as double,moodTags: null == moodTags ? _self.moodTags : moodTags // ignore: cast_nullable_to_non_nullable
as List<String>,tempoBpm: null == tempoBpm ? _self.tempoBpm : tempoBpm // ignore: cast_nullable_to_non_nullable
as double,beatStrength: null == beatStrength ? _self.beatStrength : beatStrength // ignore: cast_nullable_to_non_nullable
as double,signalEnergy: null == signalEnergy ? _self.signalEnergy : signalEnergy // ignore: cast_nullable_to_non_nullable
as double,brightness: null == brightness ? _self.brightness : brightness // ignore: cast_nullable_to_non_nullable
as double,danceability: null == danceability ? _self.danceability : danceability // ignore: cast_nullable_to_non_nullable
as double,loudness: null == loudness ? _self.loudness : loudness // ignore: cast_nullable_to_non_nullable
as double,overallEnergy: null == overallEnergy ? _self.overallEnergy : overallEnergy // ignore: cast_nullable_to_non_nullable
as double,intensity: null == intensity ? _self.intensity : intensity // ignore: cast_nullable_to_non_nullable
as double,spectralCentroid: null == spectralCentroid ? _self.spectralCentroid : spectralCentroid // ignore: cast_nullable_to_non_nullable
as double,spectralRolloff: null == spectralRolloff ? _self.spectralRolloff : spectralRolloff // ignore: cast_nullable_to_non_nullable
as double,zeroCrossingRate: null == zeroCrossingRate ? _self.zeroCrossingRate : zeroCrossingRate // ignore: cast_nullable_to_non_nullable
as double,spectralFlux: null == spectralFlux ? _self.spectralFlux : spectralFlux // ignore: cast_nullable_to_non_nullable
as double,complexity: null == complexity ? _self.complexity : complexity // ignore: cast_nullable_to_non_nullable
as double,valence: null == valence ? _self.valence : valence // ignore: cast_nullable_to_non_nullable
as double,arousal: null == arousal ? _self.arousal : arousal // ignore: cast_nullable_to_non_nullable
as double,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,analyzedAt: null == analyzedAt ? _self.analyzedAt : analyzedAt // ignore: cast_nullable_to_non_nullable
as DateTime,analyzerVersion: null == analyzerVersion ? _self.analyzerVersion : analyzerVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ExtractedSongFeatures].
extension ExtractedSongFeaturesPatterns on ExtractedSongFeatures {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExtractedSongFeatures value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExtractedSongFeatures() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExtractedSongFeatures value)  $default,){
final _that = this;
switch (_that) {
case _ExtractedSongFeatures():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExtractedSongFeatures value)?  $default,){
final _that = this;
switch (_that) {
case _ExtractedSongFeatures() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tempo,  String beat,  String energy,  List<String> instruments,  String? vocals,  String mood,  List<String> yamnetInstruments,  bool hasVocals,  String estimatedGenre,  double yamnetEnergy,  List<String> moodTags,  double tempoBpm,  double beatStrength,  double signalEnergy,  double brightness,  double danceability,  double loudness,  double overallEnergy,  double intensity,  double spectralCentroid,  double spectralRolloff,  double zeroCrossingRate,  double spectralFlux,  double complexity,  double valence,  double arousal,  double confidence,  DateTime analyzedAt,  String analyzerVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExtractedSongFeatures() when $default != null:
return $default(_that.tempo,_that.beat,_that.energy,_that.instruments,_that.vocals,_that.mood,_that.yamnetInstruments,_that.hasVocals,_that.estimatedGenre,_that.yamnetEnergy,_that.moodTags,_that.tempoBpm,_that.beatStrength,_that.signalEnergy,_that.brightness,_that.danceability,_that.loudness,_that.overallEnergy,_that.intensity,_that.spectralCentroid,_that.spectralRolloff,_that.zeroCrossingRate,_that.spectralFlux,_that.complexity,_that.valence,_that.arousal,_that.confidence,_that.analyzedAt,_that.analyzerVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tempo,  String beat,  String energy,  List<String> instruments,  String? vocals,  String mood,  List<String> yamnetInstruments,  bool hasVocals,  String estimatedGenre,  double yamnetEnergy,  List<String> moodTags,  double tempoBpm,  double beatStrength,  double signalEnergy,  double brightness,  double danceability,  double loudness,  double overallEnergy,  double intensity,  double spectralCentroid,  double spectralRolloff,  double zeroCrossingRate,  double spectralFlux,  double complexity,  double valence,  double arousal,  double confidence,  DateTime analyzedAt,  String analyzerVersion)  $default,) {final _that = this;
switch (_that) {
case _ExtractedSongFeatures():
return $default(_that.tempo,_that.beat,_that.energy,_that.instruments,_that.vocals,_that.mood,_that.yamnetInstruments,_that.hasVocals,_that.estimatedGenre,_that.yamnetEnergy,_that.moodTags,_that.tempoBpm,_that.beatStrength,_that.signalEnergy,_that.brightness,_that.danceability,_that.loudness,_that.overallEnergy,_that.intensity,_that.spectralCentroid,_that.spectralRolloff,_that.zeroCrossingRate,_that.spectralFlux,_that.complexity,_that.valence,_that.arousal,_that.confidence,_that.analyzedAt,_that.analyzerVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tempo,  String beat,  String energy,  List<String> instruments,  String? vocals,  String mood,  List<String> yamnetInstruments,  bool hasVocals,  String estimatedGenre,  double yamnetEnergy,  List<String> moodTags,  double tempoBpm,  double beatStrength,  double signalEnergy,  double brightness,  double danceability,  double loudness,  double overallEnergy,  double intensity,  double spectralCentroid,  double spectralRolloff,  double zeroCrossingRate,  double spectralFlux,  double complexity,  double valence,  double arousal,  double confidence,  DateTime analyzedAt,  String analyzerVersion)?  $default,) {final _that = this;
switch (_that) {
case _ExtractedSongFeatures() when $default != null:
return $default(_that.tempo,_that.beat,_that.energy,_that.instruments,_that.vocals,_that.mood,_that.yamnetInstruments,_that.hasVocals,_that.estimatedGenre,_that.yamnetEnergy,_that.moodTags,_that.tempoBpm,_that.beatStrength,_that.signalEnergy,_that.brightness,_that.danceability,_that.loudness,_that.overallEnergy,_that.intensity,_that.spectralCentroid,_that.spectralRolloff,_that.zeroCrossingRate,_that.spectralFlux,_that.complexity,_that.valence,_that.arousal,_that.confidence,_that.analyzedAt,_that.analyzerVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExtractedSongFeatures implements ExtractedSongFeatures {
  const _ExtractedSongFeatures({required this.tempo, required this.beat, required this.energy, required final  List<String> instruments, this.vocals, required this.mood, required final  List<String> yamnetInstruments, required this.hasVocals, required this.estimatedGenre, required this.yamnetEnergy, required final  List<String> moodTags, required this.tempoBpm, required this.beatStrength, required this.signalEnergy, required this.brightness, required this.danceability, required this.loudness, required this.overallEnergy, required this.intensity, required this.spectralCentroid, required this.spectralRolloff, required this.zeroCrossingRate, required this.spectralFlux, required this.complexity, required this.valence, required this.arousal, required this.confidence, required this.analyzedAt, required this.analyzerVersion}): _instruments = instruments,_yamnetInstruments = yamnetInstruments,_moodTags = moodTags;
  factory _ExtractedSongFeatures.fromJson(Map<String, dynamic> json) => _$ExtractedSongFeaturesFromJson(json);

// Basic categorical features
@override final  String tempo;
// e.g. "Fast", "Medium", "Slow"
@override final  String beat;
// e.g. "Strong", "Soft", "No Beat"
@override final  String energy;
// e.g. "High", "Medium", "Low"
 final  List<String> _instruments;
// e.g. "High", "Medium", "Low"
@override List<String> get instruments {
  if (_instruments is EqualUnmodifiableListView) return _instruments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_instruments);
}

// e.g. ["Piano", "Guitar"]
@override final  String? vocals;
// e.g. "Emotional", "Energetic", or null for instrumental
@override final  String mood;
// e.g. "Happy", "Sad", "Calm"
// YAMNet analysis results
 final  List<String> _yamnetInstruments;
// e.g. "Happy", "Sad", "Calm"
// YAMNet analysis results
@override List<String> get yamnetInstruments {
  if (_yamnetInstruments is EqualUnmodifiableListView) return _yamnetInstruments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_yamnetInstruments);
}

// YAMNet detected instruments
@override final  bool hasVocals;
// YAMNet vocal detection
@override final  String estimatedGenre;
// YAMNet genre classification
@override final  double yamnetEnergy;
// YAMNet energy score (0.0-1.0)
 final  List<String> _moodTags;
// YAMNet energy score (0.0-1.0)
@override List<String> get moodTags {
  if (_moodTags is EqualUnmodifiableListView) return _moodTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_moodTags);
}

// YAMNet mood tags
// Signal processing features
@override final  double tempoBpm;
// Actual BPM value
@override final  double beatStrength;
// Beat strength (0.0-1.0)
@override final  double signalEnergy;
// Signal energy (0.0-1.0)
@override final  double brightness;
// Spectral brightness
@override final  double danceability;
// Danceability score (0.0-1.0)
@override final  double loudness;
// Perceived loudness (0.0-1.0, normalized)
// Combined metrics
@override final  double overallEnergy;
// Combined energy score
@override final  double intensity;
// Overall intensity
@override final  double spectralCentroid;
// Spectral centroid
@override final  double spectralRolloff;
// Spectral rolloff
@override final  double zeroCrossingRate;
// Zero crossing rate
@override final  double spectralFlux;
// Spectral flux
@override final  double complexity;
// Complexity score
@override final  double valence;
// Valence (emotional positivity)
@override final  double arousal;
// Arousal (emotional intensity)
@override final  double confidence;
// Analysis confidence
// Analysis metadata
@override final  DateTime analyzedAt;
// When analysis was performed
@override final  String analyzerVersion;

/// Create a copy of ExtractedSongFeatures
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExtractedSongFeaturesCopyWith<_ExtractedSongFeatures> get copyWith => __$ExtractedSongFeaturesCopyWithImpl<_ExtractedSongFeatures>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExtractedSongFeaturesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExtractedSongFeatures&&(identical(other.tempo, tempo) || other.tempo == tempo)&&(identical(other.beat, beat) || other.beat == beat)&&(identical(other.energy, energy) || other.energy == energy)&&const DeepCollectionEquality().equals(other._instruments, _instruments)&&(identical(other.vocals, vocals) || other.vocals == vocals)&&(identical(other.mood, mood) || other.mood == mood)&&const DeepCollectionEquality().equals(other._yamnetInstruments, _yamnetInstruments)&&(identical(other.hasVocals, hasVocals) || other.hasVocals == hasVocals)&&(identical(other.estimatedGenre, estimatedGenre) || other.estimatedGenre == estimatedGenre)&&(identical(other.yamnetEnergy, yamnetEnergy) || other.yamnetEnergy == yamnetEnergy)&&const DeepCollectionEquality().equals(other._moodTags, _moodTags)&&(identical(other.tempoBpm, tempoBpm) || other.tempoBpm == tempoBpm)&&(identical(other.beatStrength, beatStrength) || other.beatStrength == beatStrength)&&(identical(other.signalEnergy, signalEnergy) || other.signalEnergy == signalEnergy)&&(identical(other.brightness, brightness) || other.brightness == brightness)&&(identical(other.danceability, danceability) || other.danceability == danceability)&&(identical(other.loudness, loudness) || other.loudness == loudness)&&(identical(other.overallEnergy, overallEnergy) || other.overallEnergy == overallEnergy)&&(identical(other.intensity, intensity) || other.intensity == intensity)&&(identical(other.spectralCentroid, spectralCentroid) || other.spectralCentroid == spectralCentroid)&&(identical(other.spectralRolloff, spectralRolloff) || other.spectralRolloff == spectralRolloff)&&(identical(other.zeroCrossingRate, zeroCrossingRate) || other.zeroCrossingRate == zeroCrossingRate)&&(identical(other.spectralFlux, spectralFlux) || other.spectralFlux == spectralFlux)&&(identical(other.complexity, complexity) || other.complexity == complexity)&&(identical(other.valence, valence) || other.valence == valence)&&(identical(other.arousal, arousal) || other.arousal == arousal)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.analyzedAt, analyzedAt) || other.analyzedAt == analyzedAt)&&(identical(other.analyzerVersion, analyzerVersion) || other.analyzerVersion == analyzerVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,tempo,beat,energy,const DeepCollectionEquality().hash(_instruments),vocals,mood,const DeepCollectionEquality().hash(_yamnetInstruments),hasVocals,estimatedGenre,yamnetEnergy,const DeepCollectionEquality().hash(_moodTags),tempoBpm,beatStrength,signalEnergy,brightness,danceability,loudness,overallEnergy,intensity,spectralCentroid,spectralRolloff,zeroCrossingRate,spectralFlux,complexity,valence,arousal,confidence,analyzedAt,analyzerVersion]);

@override
String toString() {
  return 'ExtractedSongFeatures(tempo: $tempo, beat: $beat, energy: $energy, instruments: $instruments, vocals: $vocals, mood: $mood, yamnetInstruments: $yamnetInstruments, hasVocals: $hasVocals, estimatedGenre: $estimatedGenre, yamnetEnergy: $yamnetEnergy, moodTags: $moodTags, tempoBpm: $tempoBpm, beatStrength: $beatStrength, signalEnergy: $signalEnergy, brightness: $brightness, danceability: $danceability, loudness: $loudness, overallEnergy: $overallEnergy, intensity: $intensity, spectralCentroid: $spectralCentroid, spectralRolloff: $spectralRolloff, zeroCrossingRate: $zeroCrossingRate, spectralFlux: $spectralFlux, complexity: $complexity, valence: $valence, arousal: $arousal, confidence: $confidence, analyzedAt: $analyzedAt, analyzerVersion: $analyzerVersion)';
}


}

/// @nodoc
abstract mixin class _$ExtractedSongFeaturesCopyWith<$Res> implements $ExtractedSongFeaturesCopyWith<$Res> {
  factory _$ExtractedSongFeaturesCopyWith(_ExtractedSongFeatures value, $Res Function(_ExtractedSongFeatures) _then) = __$ExtractedSongFeaturesCopyWithImpl;
@override @useResult
$Res call({
 String tempo, String beat, String energy, List<String> instruments, String? vocals, String mood, List<String> yamnetInstruments, bool hasVocals, String estimatedGenre, double yamnetEnergy, List<String> moodTags, double tempoBpm, double beatStrength, double signalEnergy, double brightness, double danceability, double loudness, double overallEnergy, double intensity, double spectralCentroid, double spectralRolloff, double zeroCrossingRate, double spectralFlux, double complexity, double valence, double arousal, double confidence, DateTime analyzedAt, String analyzerVersion
});




}
/// @nodoc
class __$ExtractedSongFeaturesCopyWithImpl<$Res>
    implements _$ExtractedSongFeaturesCopyWith<$Res> {
  __$ExtractedSongFeaturesCopyWithImpl(this._self, this._then);

  final _ExtractedSongFeatures _self;
  final $Res Function(_ExtractedSongFeatures) _then;

/// Create a copy of ExtractedSongFeatures
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tempo = null,Object? beat = null,Object? energy = null,Object? instruments = null,Object? vocals = freezed,Object? mood = null,Object? yamnetInstruments = null,Object? hasVocals = null,Object? estimatedGenre = null,Object? yamnetEnergy = null,Object? moodTags = null,Object? tempoBpm = null,Object? beatStrength = null,Object? signalEnergy = null,Object? brightness = null,Object? danceability = null,Object? loudness = null,Object? overallEnergy = null,Object? intensity = null,Object? spectralCentroid = null,Object? spectralRolloff = null,Object? zeroCrossingRate = null,Object? spectralFlux = null,Object? complexity = null,Object? valence = null,Object? arousal = null,Object? confidence = null,Object? analyzedAt = null,Object? analyzerVersion = null,}) {
  return _then(_ExtractedSongFeatures(
tempo: null == tempo ? _self.tempo : tempo // ignore: cast_nullable_to_non_nullable
as String,beat: null == beat ? _self.beat : beat // ignore: cast_nullable_to_non_nullable
as String,energy: null == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as String,instruments: null == instruments ? _self._instruments : instruments // ignore: cast_nullable_to_non_nullable
as List<String>,vocals: freezed == vocals ? _self.vocals : vocals // ignore: cast_nullable_to_non_nullable
as String?,mood: null == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as String,yamnetInstruments: null == yamnetInstruments ? _self._yamnetInstruments : yamnetInstruments // ignore: cast_nullable_to_non_nullable
as List<String>,hasVocals: null == hasVocals ? _self.hasVocals : hasVocals // ignore: cast_nullable_to_non_nullable
as bool,estimatedGenre: null == estimatedGenre ? _self.estimatedGenre : estimatedGenre // ignore: cast_nullable_to_non_nullable
as String,yamnetEnergy: null == yamnetEnergy ? _self.yamnetEnergy : yamnetEnergy // ignore: cast_nullable_to_non_nullable
as double,moodTags: null == moodTags ? _self._moodTags : moodTags // ignore: cast_nullable_to_non_nullable
as List<String>,tempoBpm: null == tempoBpm ? _self.tempoBpm : tempoBpm // ignore: cast_nullable_to_non_nullable
as double,beatStrength: null == beatStrength ? _self.beatStrength : beatStrength // ignore: cast_nullable_to_non_nullable
as double,signalEnergy: null == signalEnergy ? _self.signalEnergy : signalEnergy // ignore: cast_nullable_to_non_nullable
as double,brightness: null == brightness ? _self.brightness : brightness // ignore: cast_nullable_to_non_nullable
as double,danceability: null == danceability ? _self.danceability : danceability // ignore: cast_nullable_to_non_nullable
as double,loudness: null == loudness ? _self.loudness : loudness // ignore: cast_nullable_to_non_nullable
as double,overallEnergy: null == overallEnergy ? _self.overallEnergy : overallEnergy // ignore: cast_nullable_to_non_nullable
as double,intensity: null == intensity ? _self.intensity : intensity // ignore: cast_nullable_to_non_nullable
as double,spectralCentroid: null == spectralCentroid ? _self.spectralCentroid : spectralCentroid // ignore: cast_nullable_to_non_nullable
as double,spectralRolloff: null == spectralRolloff ? _self.spectralRolloff : spectralRolloff // ignore: cast_nullable_to_non_nullable
as double,zeroCrossingRate: null == zeroCrossingRate ? _self.zeroCrossingRate : zeroCrossingRate // ignore: cast_nullable_to_non_nullable
as double,spectralFlux: null == spectralFlux ? _self.spectralFlux : spectralFlux // ignore: cast_nullable_to_non_nullable
as double,complexity: null == complexity ? _self.complexity : complexity // ignore: cast_nullable_to_non_nullable
as double,valence: null == valence ? _self.valence : valence // ignore: cast_nullable_to_non_nullable
as double,arousal: null == arousal ? _self.arousal : arousal // ignore: cast_nullable_to_non_nullable
as double,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,analyzedAt: null == analyzedAt ? _self.analyzedAt : analyzedAt // ignore: cast_nullable_to_non_nullable
as DateTime,analyzerVersion: null == analyzerVersion ? _self.analyzerVersion : analyzerVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

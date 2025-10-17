// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_features.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SongFeaturesModelImpl _$$SongFeaturesModelImplFromJson(
  Map<String, dynamic> json,
) => _$SongFeaturesModelImpl(
  tempo: json['tempo'] as String,
  beat: json['beat'] as String,
  energy: json['energy'] as String,
  instruments: (json['instruments'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  vocals: json['vocals'] as String?,
  mood: json['mood'] as String,
  yamnetInstruments: (json['yamnetInstruments'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  hasVocals: json['hasVocals'] as bool,
  estimatedGenre: json['estimatedGenre'] as String,
  yamnetEnergy: (json['yamnetEnergy'] as num).toDouble(),
  moodTags: (json['moodTags'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  tempoBpm: (json['tempoBpm'] as num).toDouble(),
  beatStrength: (json['beatStrength'] as num).toDouble(),
  signalEnergy: (json['signalEnergy'] as num).toDouble(),
  brightness: (json['brightness'] as num).toDouble(),
  danceability: (json['danceability'] as num).toDouble(),
  overallEnergy: (json['overallEnergy'] as num).toDouble(),
  intensity: (json['intensity'] as num).toDouble(),
  spectralCentroid: (json['spectralCentroid'] as num).toDouble(),
  spectralRolloff: (json['spectralRolloff'] as num).toDouble(),
  zeroCrossingRate: (json['zeroCrossingRate'] as num).toDouble(),
  spectralFlux: (json['spectralFlux'] as num).toDouble(),
  complexity: (json['complexity'] as num).toDouble(),
  valence: (json['valence'] as num).toDouble(),
  arousal: (json['arousal'] as num).toDouble(),
  confidence: (json['confidence'] as num).toDouble(),
  analyzedAt: DateTime.parse(json['analyzedAt'] as String),
  analyzerVersion: json['analyzerVersion'] as String,
);

Map<String, dynamic> _$$SongFeaturesModelImplToJson(
  _$SongFeaturesModelImpl instance,
) => <String, dynamic>{
  'tempo': instance.tempo,
  'beat': instance.beat,
  'energy': instance.energy,
  'instruments': instance.instruments,
  'vocals': instance.vocals,
  'mood': instance.mood,
  'yamnetInstruments': instance.yamnetInstruments,
  'hasVocals': instance.hasVocals,
  'estimatedGenre': instance.estimatedGenre,
  'yamnetEnergy': instance.yamnetEnergy,
  'moodTags': instance.moodTags,
  'tempoBpm': instance.tempoBpm,
  'beatStrength': instance.beatStrength,
  'signalEnergy': instance.signalEnergy,
  'brightness': instance.brightness,
  'danceability': instance.danceability,
  'overallEnergy': instance.overallEnergy,
  'intensity': instance.intensity,
  'spectralCentroid': instance.spectralCentroid,
  'spectralRolloff': instance.spectralRolloff,
  'zeroCrossingRate': instance.zeroCrossingRate,
  'spectralFlux': instance.spectralFlux,
  'complexity': instance.complexity,
  'valence': instance.valence,
  'arousal': instance.arousal,
  'confidence': instance.confidence,
  'analyzedAt': instance.analyzedAt.toIso8601String(),
  'analyzerVersion': instance.analyzerVersion,
};

import 'package:logger/logger.dart';

/// YAMNet label data class
class YAMNetLabel {
  final int index;
  final String mid;
  final String displayName;

  const YAMNetLabel({
    required this.index,
    required this.mid,
    required this.displayName,
  });

  /// Check if label represents an instrument
  bool get isInstrument {
    const instruments = [
      // String instruments
      'piano', 'guitar', 'electric guitar', 'acoustic guitar', 'bass guitar', 
      'steel guitar', 'slide guitar', 'banjo', 'mandolin', 'ukulele', 'sitar',
      'violin', 'viola', 'cello', 'double bass', 'contrabass', 'bass',
      'harp', 'zither', 'harpsichord', 'lute', 'sitar', 'bouzouki',
      
      // Wind instruments
      'saxophone', 'trumpet', 'trombone', 'tuba', 'french horn', 'flute',
      'clarinet', 'oboe', 'bassoon', 'recorder', 'piccolo', 'harmonica',
      'accordion', 'concertina', 'melodica', 'mouth organ', 'bagpipe',
      
      // Keyboard instruments
      'keyboard', 'organ', 'electronic organ', 'hammond organ', 'synthesizer',
      'sampler', 'electric piano', 'harpsichord', 'celesta', 'clavichord',
      
      // Percussion instruments
      'drum', 'drum kit', 'drum machine', 'snare drum', 'bass drum', 'timpani',
      'tabla', 'cymbal', 'hi-hat', 'crash', 'ride', 'tom', 'wood block',
      'tambourine', 'rattle', 'maraca', 'gong', 'tubular bells', 'mallet',
      'marimba', 'xylophone', 'glockenspiel', 'vibraphone', 'steelpan',
      'xylophone', 'vibraphone', 'glockenspiel', 'chimes', 'bells',
      
      // Electronic instruments
      'synthesizer', 'sampler', 'drum machine', 'electronic organ',
      'theremin', 'singing bowl', 'scratching',
      
      // Brass instruments
      'trumpet', 'trombone', 'tuba', 'french horn', 'cornet', 'flugelhorn',
      'baritone horn', 'euphonium', 'sousaphone',
      
      // Woodwind instruments
      'flute', 'clarinet', 'oboe', 'bassoon', 'saxophone', 'recorder',
      'piccolo', 'english horn', 'bass clarinet', 'contrabassoon',
      
      // Other instruments
      'harmonica', 'accordion', 'concertina', 'melodica', 'mouth organ',
      'bagpipe', 'didgeridoo', 'kalimba', 'thumb piano'
    ];
    final lower = displayName.toLowerCase();
    
    // Check for exact instrument matches
    final hasExactInstrument = instruments.any((inst) => lower == inst);
    
    // Check for instrument names (partial matches)
    final hasInstrument = instruments.any((inst) => lower.contains(inst));
    
    // Check for instrument-related terms
    const instrumentTerms = [
      'instrument', 'playing', 'strumming', 'plucking', 'bowing',
      'blowing', 'striking', 'hitting', 'tapping', 'fingering',
      'percussion', 'brass', 'woodwind', 'string', 'keyboard',
      'electronic', 'acoustic', 'electric', 'amplified'
    ];
    final hasInstrumentTerm = instrumentTerms.any((term) => lower.contains(term));
    
    // Check for specific YAMNet instrument patterns
    const yamnetPatterns = [
      'guitar', 'piano', 'drum', 'bass', 'violin', 'saxophone', 'trumpet',
      'flute', 'clarinet', 'organ', 'synthesizer', 'keyboard', 'banjo',
      'mandolin', 'ukulele', 'harp', 'accordion', 'harmonica', 'trombone',
      'tuba', 'oboe', 'bassoon', 'french horn', 'xylophone', 'marimba',
      'vibraphone', 'glockenspiel', 'timpani', 'cymbal', 'snare', 'kick',
      'hi-hat', 'crash', 'ride', 'tom', 'wood block', 'tambourine', 'rattle',
      'maraca', 'gong', 'tubular bells', 'mallet', 'steelpan'
    ];
    final hasYamnetPattern = yamnetPatterns.any((pattern) => lower.contains(pattern));
    
    return hasExactInstrument || hasInstrument || hasInstrumentTerm || hasYamnetPattern;
  }
  
  /// Check if label represents vocals
  bool get isVocal {
    const vocals = [
      // Direct vocal terms
      'singing', 'speech', 'vocal', 'voice', 'choir', 'chorus', 'chant',
      'vocalization', 'vocal call', 'vocal song', 'vocal music',
      
      // Speech-related
      'conversation', 'talking', 'speaking', 'whispering', 'shouting',
      'yelling', 'screaming', 'laughing', 'crying', 'sobbing', 'whimpering',
      'wailing', 'moaning', 'sighing', 'yodeling', 'mantra', 'narration',
      'monologue', 'babbling', 'speech synthesizer', 'shout', 'bellow',
      'whoop', 'yell', 'whispering', 'laughter', 'giggle', 'snicker',
      'belly laugh', 'chuckle', 'chortle', 'crying', 'sobbing', 'whimper',
      'wail', 'moan', 'sigh', 'rap', 'rap', 'rapping', 'humming', 'groan',
      'grunt', 'whistling', 'breathing', 'wheeze', 'snoring', 'gasp',
      'pant', 'snort', 'cough', 'throat clearing', 'sneeze', 'sniff',
      
      // Child vocals
      'child speech', 'kid speaking', 'child singing', 'baby laughter',
      'baby cry', 'infant cry', 'children shouting', 'children playing',
      
      // Synthetic vocals
      'synthetic singing', 'speech synthesizer', 'synthetic voice',
      
      // Animal vocals (sometimes relevant for music)
      'bird vocalization', 'bird call', 'bird song', 'whale vocalization',
      
      // Music-specific vocals
      'vocal music', 'a capella', 'background vocals', 'lead vocals',
      'harmony vocals', 'backing vocals', 'vocal harmony'
    ];
    final lower = displayName.toLowerCase();
    
    // Check for exact vocal matches
    final hasExactVocal = vocals.any((vocal) => lower == vocal);
    
    // Check for vocal keywords (partial matches)
    final hasVocal = vocals.any((vocal) => lower.contains(vocal));
    
    // Check for vocal-related patterns
    const vocalPatterns = [
      'sing', 'speak', 'talk', 'voice', 'vocal', 'choir', 'chorus',
      'chant', 'rap', 'hum', 'whistle', 'laugh', 'cry', 'scream',
      'shout', 'whisper', 'yell', 'moan', 'wail', 'sigh', 'gasp',
      'pant', 'cough', 'sneeze', 'sniff', 'breath', 'vocalization'
    ];
    final hasVocalPattern = vocalPatterns.any((pattern) => lower.contains(pattern));
    
    return hasExactVocal || hasVocal || hasVocalPattern;
  }
  
  /// Check if label represents a genre
  bool get isGenre {
    const genres = [
      'rock', 'pop', 'jazz', 'classical', 'electronic', 'blues', 'country',
      'hip hop', 'reggae', 'metal', 'folk', 'r&b', 'soul', 'funk', 'disco',
      'techno', 'house', 'trance', 'dubstep', 'ambient', 'indie', 'gospel',
      'latin', 'world', 'new age', 'alternative', 'punk', 'grunge', 'emo',
      'hardcore', 'progressive', 'experimental', 'avant-garde', 'minimalist',
      'heavy metal', 'punk rock', 'progressive rock', 'psychedelic rock',
      'rock and roll', 'rhythm and blues', 'soul music', 'swing music',
      'bluegrass', 'folk music', 'middle eastern music', 'opera',
      'drum and bass', 'electronica', 'electronic dance music',
      'ambient music', 'trance music', 'music of latin america',
      'salsa music', 'flamenco', 'music for children', 'new-age music',
      'vocal music', 'a capella', 'music of africa', 'afrobeat',
      'christian music', 'gospel music', 'music of asia', 'carnatic music',
      'music of bollywood', 'ska', 'traditional music', 'independent music',
      'background music', 'theme music', 'jingle', 'soundtrack music',
      'lullaby', 'video game music', 'christmas music', 'dance music',
      'wedding music', 'happy music', 'sad music', 'tender music',
      'exciting music', 'angry music', 'scary music'
    ];
    final lower = displayName.toLowerCase();
    
    // Check for exact genre matches
    final hasExactGenre = genres.any((genre) => lower == genre);
    
    // Check for genre keywords with or without 'music' suffix
    final hasGenre = genres.any((genre) => lower.contains(genre));
    
    // Check for music-related terms
    final hasMusic = lower.contains('music') || lower.contains('song') || lower.contains('tune');
    
    // Check for specific genre patterns
    final genrePatterns = [
      'music', 'song', 'tune', 'melody', 'rhythm', 'beat', 'sound',
      'acoustic', 'electric', 'vocal', 'instrumental', 'orchestral'
    ];
    final hasPattern = genrePatterns.any((pattern) => lower.contains(pattern));
    
    // IMPROVED: More comprehensive genre detection
    return hasExactGenre || hasGenre || hasMusic || hasPattern;
  }
  
  /// Check if label represents mood
  bool get isMood {
    const moods = [
      // YAMNet specific mood labels
      'happy music', 'sad music', 'tender music', 'exciting music', 
      'angry music', 'scary music',
      
      // General mood terms
      'happy', 'sad', 'energetic', 'calm', 'melancholy', 'upbeat', 'cheerful',
      'gloomy', 'peaceful', 'relaxing', 'intense', 'aggressive', 'gentle',
      'joyful', 'somber', 'dark', 'bright', 'serene', 'tranquil',
      'tender', 'exciting', 'angry', 'scary', 'frightening', 'terrifying',
      'uplifting', 'inspiring', 'motivational', 'romantic', 'passionate',
      'melancholic', 'nostalgic', 'dreamy', 'ethereal', 'mysterious',
      'dramatic', 'epic', 'heroic', 'triumphant', 'celebratory',
      'contemplative', 'meditative', 'zen', 'spiritual', 'sacred',
      'playful', 'fun', 'lighthearted', 'whimsical', 'quirky',
      'moody', 'brooding', 'introspective', 'reflective', 'thoughtful',
      'energetic', 'dynamic', 'vibrant', 'lively', 'animated',
      'relaxed', 'chill', 'laid-back', 'mellow', 'smooth',
      'intense', 'powerful', 'strong', 'forceful', 'driving',
      'soft', 'gentle', 'delicate', 'subtle', 'understated'
    ];
    final lower = displayName.toLowerCase();
    
    // Check for exact mood matches
    final hasExactMood = moods.any((mood) => lower == mood);
    
    // Check for mood keywords (partial matches)
    final hasMood = moods.any((mood) => lower.contains(mood));
    
    // Check for mood-related patterns
    const moodPatterns = [
      'happy', 'sad', 'energetic', 'calm', 'melancholy', 'upbeat', 'cheerful',
      'gloomy', 'peaceful', 'relaxing', 'intense', 'aggressive', 'gentle',
      'joyful', 'somber', 'dark', 'bright', 'serene', 'tranquil', 'tender',
      'exciting', 'angry', 'scary', 'uplifting', 'romantic', 'dramatic',
      'playful', 'moody', 'energetic', 'relaxed', 'intense', 'soft'
    ];
    final hasMoodPattern = moodPatterns.any((pattern) => lower.contains(pattern));
    
    // Check for music mood indicators
    const musicMoodIndicators = [
      'music', 'song', 'tune', 'melody', 'harmony', 'rhythm', 'beat',
      'acoustic', 'electric', 'vocal', 'instrumental', 'orchestral',
      'ambient', 'atmospheric', 'cinematic', 'soundtrack', 'theme'
    ];
    final hasMusicMood = musicMoodIndicators.any((indicator) => lower.contains(indicator));
    
    return hasExactMood || hasMood || hasMoodPattern || hasMusicMood;
  }
  
  /// Check if label is energy-related
  bool get isEnergyRelated {
    const energyTerms = [
      // Volume and intensity
      'loud', 'quiet', 'silent', 'mute', 'soft', 'strong', 'powerful',
      'intense', 'gentle', 'heavy', 'light', 'dynamic', 'aggressive',
      'calm', 'peaceful', 'energetic', 'lively', 'vibrant', 'animated',
      
      // Musical energy indicators
      'driving', 'pulsing', 'rhythmic', 'beat', 'tempo', 'fast', 'slow',
      'upbeat', 'downbeat', 'syncopated', 'steady', 'irregular',
      
      // Emotional energy
      'exciting', 'thrilling', 'exhilarating', 'stimulating', 'arousing',
      'relaxing', 'soothing', 'calming', 'tranquil', 'serene', 'meditative',
      'uplifting', 'inspiring', 'motivating', 'energizing', 'invigorating',
      
      // Sound characteristics
      'bright', 'dark', 'warm', 'cold', 'harsh', 'smooth', 'rough',
      'crisp', 'muffled', 'clear', 'distorted', 'clean', 'dirty',
      'sharp', 'dull', 'piercing', 'mellow', 'harsh', 'gentle',
      
      // Performance energy
      'passionate', 'emotional', 'dramatic', 'theatrical', 'expressive',
      'restrained', 'controlled', 'wild', 'uncontrolled', 'chaotic',
      'organized', 'structured', 'free', 'improvised', 'spontaneous',
      
      // Genre energy indicators
      'rock', 'metal', 'punk', 'hardcore', 'grunge', 'alternative',
      'electronic', 'techno', 'house', 'trance', 'dubstep', 'drum and bass',
      'ambient', 'new age', 'classical', 'orchestral', 'chamber',
      'acoustic', 'folk', 'country', 'blues', 'jazz', 'funk', 'soul',
      'reggae', 'ska', 'latin', 'world', 'ethnic', 'traditional'
    ];
    final lower = displayName.toLowerCase();
    
    // Check for exact energy matches
    final hasExactEnergy = energyTerms.any((term) => lower == term);
    
    // Check for energy keywords (partial matches)
    final hasEnergy = energyTerms.any((term) => lower.contains(term));
    
    // Check for energy-related patterns
    const energyPatterns = [
      'loud', 'quiet', 'energetic', 'intense', 'powerful', 'soft', 'strong',
      'heavy', 'light', 'dynamic', 'aggressive', 'gentle', 'bright', 'dark',
      'warm', 'cold', 'harsh', 'smooth', 'crisp', 'muffled', 'clear',
      'passionate', 'emotional', 'dramatic', 'wild', 'controlled', 'free'
    ];
    final hasEnergyPattern = energyPatterns.any((pattern) => lower.contains(pattern));
    
    return hasExactEnergy || hasEnergy || hasEnergyPattern;
  }
}

/// YAMNet helper functions for processing model output
class YAMNetHelper {
  static final Logger _logger = Logger();

  /// Process YAMNet model output
  static YAMNetResults processOutput(List<double> output, List<String> labels) {
    try {
      // Find top predictions
      final predictions = <MapEntry<int, double>>[];
      for (int i = 0; i < output.length; i++) {
        predictions.add(MapEntry(i, output[i]));
      }
      
      // Sort by confidence
      predictions.sort((a, b) => b.value.compareTo(a.value));
      
      // Extract features
      final instruments = _extractInstruments(predictions, labels);
      final hasVocals = _detectVocals(predictions, labels);
      final genre = _extractGenre(predictions, labels);
      final energy = _extractEnergy(predictions, labels);
      final moodScore = _extractMoodScore(predictions, labels);
      final moodTags = _extractMoodTags(predictions, labels);
      final vocalIntensity = _extractVocalIntensity(predictions, labels);
      final confidence = _calculateConfidence(predictions);
      
      return YAMNetResults(
        instruments: instruments,
        hasVocals: hasVocals,
        genre: genre,
        energy: energy,
        moodScore: moodScore,
        moodTags: moodTags,
        vocalIntensity: vocalIntensity,
        confidence: confidence,
      );
    } catch (e) {
      _logger.e('❌ Error processing YAMNet output: $e');
      return YAMNetResults.empty();
    }
  }

  /// Extract instruments from predictions
  static List<String> _extractInstruments(List<MapEntry<int, double>> predictions, List<String> labels) {
    final instruments = <String>[];
    final instrumentKeywords = [
      'guitar', 'piano', 'drum', 'bass', 'violin', 'saxophone', 'trumpet',
      'flute', 'clarinet', 'organ', 'synthesizer', 'keyboard', 'banjo',
      'mandolin', 'ukulele', 'harp', 'accordion', 'harmonica', 'trombone',
      'tuba', 'oboe', 'bassoon', 'french horn', 'xylophone', 'marimba',
      'vibraphone', 'glockenspiel', 'timpani', 'cymbal', 'snare', 'kick',
      'hi-hat', 'crash', 'ride', 'tom', 'wood block', 'tambourine', 'rattle',
      'maraca', 'gong', 'tubular bells', 'mallet', 'steelpan'
    ];

    for (final prediction in predictions.take(20)) {
      final label = labels[prediction.key].toLowerCase();
      final confidence = prediction.value;
      
      if (confidence > 0.1) {
        // Check for instrument keywords
        for (final keyword in instrumentKeywords) {
          if (label.contains(keyword)) {
            final instrumentName = _formatInstrumentName(labels[prediction.key]);
            if (!instruments.contains(instrumentName)) {
              instruments.add(instrumentName);
            }
            break;
          }
        }
      }
    }

    return instruments.take(10).toList();
  }

  /// Detect vocals
  static bool _detectVocals(List<MapEntry<int, double>> predictions, List<String> labels) {
    final vocalKeywords = [
      'singing', 'speech', 'vocal', 'voice', 'choir', 'chorus', 'chant',
      'conversation', 'talking', 'speaking', 'whispering', 'shouting',
      'yelling', 'screaming', 'laughing', 'crying', 'sobbing', 'whimpering',
      'wailing', 'moaning', 'sighing', 'yodeling', 'mantra', 'narration',
      'monologue', 'babbling', 'speech synthesizer', 'shout', 'bellow',
      'whoop', 'yell', 'whispering', 'laughter', 'giggle', 'snicker',
      'belly laugh', 'chuckle', 'chortle', 'crying', 'sobbing', 'whimper',
      'wail', 'moan', 'sigh', 'rap', 'rap', 'rapping', 'humming', 'groan',
      'grunt', 'whistling', 'breathing', 'wheeze', 'snoring', 'gasp',
      'pant', 'snort', 'cough', 'throat clearing', 'sneeze', 'sniff',
      'child speech', 'kid speaking', 'child singing', 'baby laughter',
      'baby cry', 'infant cry', 'children shouting', 'children playing',
      'synthetic singing', 'speech synthesizer', 'synthetic voice',
      'bird vocalization', 'bird call', 'bird song', 'whale vocalization',
      'vocal music', 'a capella', 'background vocals', 'lead vocals',
      'harmony vocals', 'backing vocals', 'vocal harmony'
    ];

    for (final prediction in predictions.take(20)) {
      final label = labels[prediction.key].toLowerCase();
      final confidence = prediction.value;
      
      if (confidence > 0.1) {
        for (final keyword in vocalKeywords) {
          if (label.contains(keyword)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  /// Extract genre
  static String _extractGenre(List<MapEntry<int, double>> predictions, List<String> labels) {
    final genreKeywords = [
      'rock', 'pop', 'jazz', 'classical', 'electronic', 'blues', 'country',
      'hip hop', 'reggae', 'metal', 'folk', 'r&b', 'soul', 'funk', 'disco',
      'techno', 'house', 'trance', 'dubstep', 'ambient', 'indie', 'gospel',
      'latin', 'world', 'new age', 'alternative', 'punk', 'grunge', 'emo',
      'hardcore', 'progressive', 'experimental', 'avant-garde', 'minimalist',
      'heavy metal', 'punk rock', 'progressive rock', 'psychedelic rock',
      'rock and roll', 'rhythm and blues', 'soul music', 'swing music',
      'bluegrass', 'folk music', 'middle eastern music', 'opera',
      'drum and bass', 'electronica', 'electronic dance music',
      'ambient music', 'trance music', 'music of latin america',
      'salsa music', 'flamenco', 'music for children', 'new-age music',
      'vocal music', 'a capella', 'music of africa', 'afrobeat',
      'christian music', 'gospel music', 'music of asia', 'carnatic music',
      'music of bollywood', 'ska', 'traditional music', 'independent music',
      'background music', 'theme music', 'jingle', 'soundtrack music',
      'lullaby', 'video game music', 'christmas music', 'dance music',
      'wedding music', 'happy music', 'sad music', 'tender music',
      'exciting music', 'angry music', 'scary music'
    ];

    String bestGenre = 'Unknown';
    double bestConfidence = 0.0;

    for (final prediction in predictions.take(20)) {
      final label = labels[prediction.key].toLowerCase();
      final confidence = prediction.value;
      
      if (confidence > 0.05) {
        for (final keyword in genreKeywords) {
          if (label.contains(keyword)) {
            if (confidence > bestConfidence) {
              bestConfidence = confidence;
              bestGenre = _formatGenreName(labels[prediction.key]);
            }
            break;
          }
        }
      }
    }

    return bestGenre;
  }

  /// Extract energy
  static double _extractEnergy(List<MapEntry<int, double>> predictions, List<String> labels) {
    final energyKeywords = [
      'loud', 'quiet', 'silent', 'mute', 'soft', 'strong', 'powerful',
      'intense', 'gentle', 'heavy', 'light', 'dynamic', 'aggressive',
      'calm', 'peaceful', 'energetic', 'lively', 'vibrant', 'animated',
      'driving', 'pulsing', 'rhythmic', 'beat', 'tempo', 'fast', 'slow',
      'upbeat', 'downbeat', 'syncopated', 'steady', 'irregular',
      'exciting', 'thrilling', 'exhilarating', 'stimulating', 'arousing',
      'relaxing', 'soothing', 'calming', 'tranquil', 'serene', 'meditative',
      'uplifting', 'inspiring', 'motivating', 'energizing', 'invigorating',
      'bright', 'dark', 'warm', 'cold', 'harsh', 'smooth', 'rough',
      'crisp', 'muffled', 'clear', 'distorted', 'clean', 'dirty',
      'sharp', 'dull', 'piercing', 'mellow', 'harsh', 'gentle',
      'passionate', 'emotional', 'dramatic', 'theatrical', 'expressive',
      'restrained', 'controlled', 'wild', 'uncontrolled', 'chaotic',
      'organized', 'structured', 'free', 'improvised', 'spontaneous'
    ];

    double totalEnergy = 0.0;
    int energyCount = 0;

    for (final prediction in predictions.take(20)) {
      final label = labels[prediction.key].toLowerCase();
      final confidence = prediction.value;
      
      if (confidence > 0.1) {
        for (final keyword in energyKeywords) {
          if (label.contains(keyword)) {
            totalEnergy += confidence;
            energyCount++;
            break;
          }
        }
      }
    }

    return energyCount > 0 ? totalEnergy / energyCount : 0.5;
  }

  /// Extract mood score
  static double _extractMoodScore(List<MapEntry<int, double>> predictions, List<String> labels) {
    final moodKeywords = [
      'happy', 'sad', 'energetic', 'calm', 'melancholy', 'upbeat', 'cheerful',
      'gloomy', 'peaceful', 'relaxing', 'intense', 'aggressive', 'gentle',
      'joyful', 'somber', 'dark', 'bright', 'serene', 'tranquil',
      'tender', 'exciting', 'angry', 'scary', 'frightening', 'terrifying',
      'uplifting', 'inspiring', 'motivational', 'romantic', 'passionate',
      'melancholic', 'nostalgic', 'dreamy', 'ethereal', 'mysterious',
      'dramatic', 'epic', 'heroic', 'triumphant', 'celebratory',
      'contemplative', 'meditative', 'zen', 'spiritual', 'sacred',
      'playful', 'fun', 'lighthearted', 'whimsical', 'quirky',
      'moody', 'brooding', 'introspective', 'reflective', 'thoughtful',
      'energetic', 'dynamic', 'vibrant', 'lively', 'animated',
      'relaxed', 'chill', 'laid-back', 'mellow', 'smooth',
      'intense', 'powerful', 'strong', 'forceful', 'driving',
      'soft', 'gentle', 'delicate', 'subtle', 'understated'
    ];

    double totalMood = 0.0;
    int moodCount = 0;

    for (final prediction in predictions.take(20)) {
      final label = labels[prediction.key].toLowerCase();
      final confidence = prediction.value;
      
      if (confidence > 0.1) {
        for (final keyword in moodKeywords) {
          if (label.contains(keyword)) {
            // Map mood keywords to scores
            double moodScore = _getMoodScore(keyword);
            totalMood += moodScore * confidence;
            moodCount++;
            break;
          }
        }
      }
    }

    return moodCount > 0 ? totalMood / moodCount : 0.5;
  }

  /// Extract mood tags
  static List<String> _extractMoodTags(List<MapEntry<int, double>> predictions, List<String> labels) {
    final moodTags = <String>[];
    final moodKeywords = [
      'happy', 'sad', 'energetic', 'calm', 'melancholy', 'upbeat', 'cheerful',
      'gloomy', 'peaceful', 'relaxing', 'intense', 'aggressive', 'gentle',
      'joyful', 'somber', 'dark', 'bright', 'serene', 'tranquil',
      'tender', 'exciting', 'angry', 'scary', 'uplifting', 'romantic',
      'dramatic', 'playful', 'moody', 'energetic', 'relaxed', 'intense'
    ];

    for (final prediction in predictions.take(20)) {
      final label = labels[prediction.key].toLowerCase();
      final confidence = prediction.value;
      
      if (confidence > 0.1) {
        for (final keyword in moodKeywords) {
          if (label.contains(keyword)) {
            final moodTag = _formatMoodTag(labels[prediction.key]);
            if (!moodTags.contains(moodTag)) {
              moodTags.add(moodTag);
            }
            break;
          }
        }
      }
    }

    return moodTags.take(5).toList();
  }

  /// Extract vocal intensity
  static double _extractVocalIntensity(List<MapEntry<int, double>> predictions, List<String> labels) {
    final vocalKeywords = [
      'singing', 'speech', 'vocal', 'voice', 'choir', 'chorus', 'chant',
      'conversation', 'talking', 'speaking', 'whispering', 'shouting',
      'yelling', 'screaming', 'laughing', 'crying', 'sobbing', 'whimpering',
      'wailing', 'moaning', 'sighing', 'yodeling', 'mantra', 'narration',
      'monologue', 'babbling', 'speech synthesizer', 'shout', 'bellow',
      'whoop', 'yell', 'whispering', 'laughter', 'giggle', 'snicker',
      'belly laugh', 'chuckle', 'chortle', 'crying', 'sobbing', 'whimper',
      'wail', 'moan', 'sigh', 'rap', 'rap', 'rapping', 'humming', 'groan',
      'grunt', 'whistling', 'breathing', 'wheeze', 'snoring', 'gasp',
      'pant', 'snort', 'cough', 'throat clearing', 'sneeze', 'sniff'
    ];

    double totalIntensity = 0.0;
    int vocalCount = 0;

    for (final prediction in predictions.take(20)) {
      final label = labels[prediction.key].toLowerCase();
      final confidence = prediction.value;
      
      if (confidence > 0.1) {
        for (final keyword in vocalKeywords) {
          if (label.contains(keyword)) {
            totalIntensity += confidence;
            vocalCount++;
            break;
          }
        }
      }
    }

    return vocalCount > 0 ? totalIntensity / vocalCount : 0.0;
  }

  /// Calculate overall confidence
  static double _calculateConfidence(List<MapEntry<int, double>> predictions) {
    if (predictions.isEmpty) return 0.0;
    
    // Use top 5 predictions for confidence calculation
    final topPredictions = predictions.take(5);
    double totalConfidence = 0.0;
    
    for (final prediction in topPredictions) {
      totalConfidence += prediction.value;
    }
    
    return totalConfidence / topPredictions.length;
  }

  /// Get mood score for keyword
  static double _getMoodScore(String keyword) {
    switch (keyword) {
      case 'happy':
      case 'cheerful':
      case 'joyful':
      case 'upbeat':
      case 'playful':
      case 'fun':
      case 'lighthearted':
        return 0.8;
      case 'sad':
      case 'gloomy':
      case 'somber':
      case 'melancholy':
      case 'melancholic':
        return 0.2;
      case 'energetic':
      case 'intense':
      case 'powerful':
      case 'dynamic':
      case 'vibrant':
      case 'lively':
        return 0.7;
      case 'calm':
      case 'peaceful':
      case 'serene':
      case 'tranquil':
      case 'relaxed':
      case 'chill':
        return 0.6;
      case 'angry':
      case 'aggressive':
        return 0.3;
      case 'romantic':
      case 'tender':
      case 'passionate':
        return 0.7;
      case 'mysterious':
      case 'dark':
        return 0.4;
      case 'dramatic':
      case 'epic':
      case 'heroic':
        return 0.6;
      default:
        return 0.5;
    }
  }

  /// Format instrument name
  static String _formatInstrumentName(String name) {
    return name.split(',').first.trim();
  }

  /// Format genre name
  static String _formatGenreName(String name) {
    return name.split(',').first.trim();
  }

  /// Format mood tag
  static String _formatMoodTag(String name) {
    return name.split(',').first.trim();
  }
}

/// YAMNet results class
class YAMNetResults {
  final List<String> instruments;
  final bool hasVocals;
  final String genre;
  final double energy;
  final double moodScore;
  final List<String> moodTags;
  final double vocalIntensity;
  final double confidence;

  const YAMNetResults({
    required this.instruments,
    required this.hasVocals,
    required this.genre,
    required this.energy,
    required this.moodScore,
    required this.moodTags,
    required this.vocalIntensity,
    required this.confidence,
  });

  factory YAMNetResults.empty() {
    return const YAMNetResults(
      instruments: [],
      hasVocals: false,
      genre: 'Unknown',
      energy: 0.0,
      moodScore: 0.5,
      moodTags: [],
      vocalIntensity: 0.0,
      confidence: 0.0,
    );
  }
}

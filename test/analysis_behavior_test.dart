import 'package:flutter_test/flutter_test.dart';
import 'package:music_feature_analyzer/src/services/feature_extractor.dart';

/// Tests for analysis behavior: 4-part segment positions and middle-segment start time.
///
/// Covers:
/// - [FeatureExtractor.getFourPartStartTimesSeconds] (4 equal parts: D/8, 3D/8, 5D/8, 7D/8)
/// - [FeatureExtractor.calculateMiddleStartTimeSeconds] (single middle-segment position)
/// - Edge cases: zero/negative duration, very short songs
void main() {
  group('FeatureExtractor - 4-part start times', () {
    test('returns 4 start times for duration >= 4 seconds', () {
      // 4 minutes = 240000 ms
      final startTimes = FeatureExtractor.getFourPartStartTimesSeconds(240000);
      expect(startTimes.length, 4);
      final totalSec = 240.0;
      expect(startTimes[0], closeTo(totalSec / 8, 0.01));   // 30 s
      expect(startTimes[1], closeTo(totalSec * 3 / 8, 0.01)); // 90 s
      expect(startTimes[2], closeTo(totalSec * 5 / 8, 0.01)); // 150 s
      expect(startTimes[3], closeTo(totalSec * 7 / 8, 0.01)); // 210 s
    });

    test('returns 4 start times for 30-second song (4-part threshold)', () {
      final startTimes = FeatureExtractor.getFourPartStartTimesSeconds(30000);
      expect(startTimes.length, 4);
      expect(startTimes[0], closeTo(30 / 8, 0.01));
      expect(startTimes[1], closeTo(30 * 3 / 8, 0.01));
      expect(startTimes[2], closeTo(30 * 5 / 8, 0.01));
      expect(startTimes[3], closeTo(30 * 7 / 8, 0.01));
    });

    test('returns 1 start time for very short song (< 4 s)', () {
      final startTimes = FeatureExtractor.getFourPartStartTimesSeconds(2000); // 2 s
      expect(startTimes.length, 1);
      expect(startTimes[0], closeTo(1.0, 0.01)); // middle: 2 * 0.5
    });

    test('returns empty list for zero or negative duration', () {
      expect(FeatureExtractor.getFourPartStartTimesSeconds(0), isEmpty);
      expect(FeatureExtractor.getFourPartStartTimesSeconds(-100), isEmpty);
    });

    test('start times are strictly increasing and within [0, duration]', () {
      const durationMs = 180000; // 3 min
      final startTimes = FeatureExtractor.getFourPartStartTimesSeconds(durationMs);
      final totalSec = durationMs / 1000.0;
      expect(startTimes.length, 4);
      for (var i = 0; i < startTimes.length; i++) {
        expect(startTimes[i], greaterThanOrEqualTo(0));
        expect(startTimes[i], lessThanOrEqualTo(totalSec));
        if (i > 0) expect(startTimes[i], greaterThan(startTimes[i - 1]));
      }
    });
  });

  group('FeatureExtractor - middle start time (single segment)', () {
    test('uses default for zero duration (3 min assumption)', () {
      final start = FeatureExtractor.calculateMiddleStartTimeSeconds(0);
      // Default 3 min: 180s * 0.25 = 45 (for 1800 > x >= 600 rule? 600*0.35=210, 1800*0.25=450)
      // Actually for 180s: totalSeconds 180 < 600 so 0.35 * 180 = 63
      expect(start, greaterThanOrEqualTo(0));
      expect(start, lessThanOrEqualTo(180));
    });

    test('3-minute song: middle start is positive and reasonable', () {
      const threeMinMs = 180000;
      final start = FeatureExtractor.calculateMiddleStartTimeSeconds(threeMinMs);
      expect(start, greaterThan(0));
      expect(start, lessThan(180)); // within 3 min
    });

    test('4-minute song: middle start is positive and reasonable', () {
      const fourMinMs = 240000;
      final start = FeatureExtractor.calculateMiddleStartTimeSeconds(fourMinMs);
      expect(start, greaterThan(0));
      expect(start, lessThan(240));
    });

    test('short song (< 6 s): start is 0', () {
      final start = FeatureExtractor.calculateMiddleStartTimeSeconds(5000); // 5 s
      expect(start, 0);
    });

    test('10-second song: start is 25% (2.5 s)', () {
      final start = FeatureExtractor.calculateMiddleStartTimeSeconds(10000);
      expect(start, closeTo(10 * 0.25, 0.01));
    });
  });
}

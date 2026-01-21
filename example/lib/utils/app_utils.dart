import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shared utility functions used across the app
class AppUtils {
  /// Format duration in milliseconds to MM:SS format
  static String formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Build album art placeholder widget
  static Widget buildAlbumArtPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Icon(
        Icons.music_note_rounded,
        size: 32.sp,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
      ),
    );
  }

  /// Build large album art placeholder widget (for detail sheet)
  static Widget buildLargeAlbumArtPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Icon(
        Icons.music_note_rounded,
        size: 50.sp,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
      ),
    );
  }

  /// Format file size in bytes to human-readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// Format date to readable string
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Get validated value or return default
  static String getValidatedValue(String? value, String defaultValue) {
    if (value == null || value.trim().isEmpty) {
      return defaultValue;
    }
    return value;
  }

  /// Check if value is not null and not empty
  static bool hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Validate and format BPM value
  static String validateAndFormatBpm(double bpm) {
    if (bpm.isNaN || bpm.isInfinite || bpm < 0 || bpm > 300) {
      return '0';
    }
    return bpm.toStringAsFixed(0);
  }

  /// Validate and format double value within range
  static String validateAndFormatDouble(double value, double min, double max) {
    if (value.isNaN || value.isInfinite) {
      return '0.00';
    }
    if (value < min) {
      return min.toStringAsFixed(2);
    }
    if (value > max && max != double.infinity) {
      return max.toStringAsFixed(2);
    }
    return value.toStringAsFixed(2);
  }
}

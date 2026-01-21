import '../../utils/app_logger.dart';
import 'shared_validation.dart';

/// Filename parsing utilities and helpers
class FilenameParser {
  static final _logger = AppLogger('FilenameParser');

  /// Extract title from filename with comprehensive pattern matching
  /// Uses the intelligent parsing from SharedValidation
  static String extractTitleFromFilename(String filePath) {
    try {
      final fileName = filePath.split('/').last.split('.').first;
      final cleanFileName = SharedValidation.cleanFilename(fileName);
      
      // Use the comprehensive intelligent parsing
      final parsed = SharedValidation.parseFilenameIntelligently(cleanFileName);
      
      // Return the parsed title, or fallback to cleaned filename
      if (parsed.title.isNotEmpty && parsed.title != 'Unknown Title') {
        return parsed.title;
      }
      
      // Fallback: use the entire filename as title (cleaned)
      return SharedValidation.cleanTitle(cleanFileName);
    } catch (e) {
      _logger.w('Error extracting title from filename: $filePath - $e');
      return 'Unknown Title';
    }
  }

  /// Clean and format song title
  /// Delegates to SharedValidation for consistency
  static String cleanTitle(String title) {
    return SharedValidation.cleanTitle(title);
  }

  /// Check if a string is likely non-Latin (contains Unicode characters)
  static bool isLikelyNonLatin(String text) {
    if (text.isEmpty) return false;
    for (final codeUnit in text.codeUnits) {
      final c = codeUnit;
      final isLatin = (c >= 0x0000 && c <= 0x024F);
      if (!isLatin) return true;
    }
    return false;
  }
}

class UrlUtils {
  /// Validates if a string is a valid URL with scheme and host.
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    
    try {
      final uri = Uri.tryParse(url);
      return uri != null && uri.hasScheme && uri.host.isNotEmpty && url.contains('//');
    } catch (e) {
      return false;
    }
  }

  /// Attempts to fix common URL malformations.
  /// Currently handles:
  /// - Missing slashes after scheme (e.g., "https:w..." -> "https://w...")
  static String? fixUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    String fixedUrl = url.trim();

    // Fix missing slashes after scheme
    // Check for https: without //
    if (fixedUrl.startsWith('https:') && !fixedUrl.startsWith('https://')) {
       fixedUrl = fixedUrl.replaceFirst('https:', 'https://');
    } else if (fixedUrl.startsWith('http:') && !fixedUrl.startsWith('http://')) {
       fixedUrl = fixedUrl.replaceFirst('http:', 'http://');
    }

    // Attempt to validate after fix
    if (isValidUrl(fixedUrl)) {
      return fixedUrl;
    }
    
    // If still invalid, check if we can salvage it by re-parsing strict
    // but specific patterns like "https:plusunsplashcom..." are hard to fix without context
    // So we return null if valid URL cannot be constructed
    return null; 
  }
}

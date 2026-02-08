import 'package:flutter/material.dart';

/// Centralized asset paths for Effulgence'26 branding
class AppAssets {
  AppAssets._();

  // ═══════════════════════════════════════════════════════════════
  // LOGO ASSETS
  // ═══════════════════════════════════════════════════════════════

  /// Effulgence logo - dark variant (for light backgrounds)
  static const String logoDark = 'text_and_logo/Effulgence_logo_dark_svg.svg';

  /// Effulgence logo - light variant (for dark backgrounds)
  static const String logoLight = 'text_and_logo/Effulgence_logo_light_svg.svg';

  static const String lightningLeftSvg =
      'background_elements/lightning-left.svg';
  static const String lightningRightSvg =
      'background_elements/lightning-right.svg';

  /// Effulgence logo - PNG variant (for native-like rendering)
  static const String logoPng = 'text_and_logo/effulgence_logo_540.png';

  // ═══════════════════════════════════════════════════════════════
  // TEXT ASSETS
  // ═══════════════════════════════════════════════════════════════

  /// Effulgence text - black variant (for light backgrounds)
  static const String textBlack =
      'text_and_logo/text/Effulgence_text_black.png';

  /// Effulgence text - black SVG variant
  static const String textBlackSvg =
      'text_and_logo/text/Effulgence_text_black.svg';

  /// Effulgence text - light variant (for dark backgrounds)
  static const String textLight =
      'text_and_logo/text/Effulgence_text_light.png';

  /// Effulgence text - light SVG variant
  static const String textLightSvg =
      'text_and_logo/text/Effulgence_text_light.svg';

  // ═══════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════

  /// Get appropriate logo based on theme brightness
  static String getLogo(Brightness brightness) {
    return brightness == Brightness.dark ? logoLight : logoDark;
  }

  /// Get appropriate text image based on theme brightness
  static String getText(Brightness brightness) {
    return brightness == Brightness.dark ? textLight : textBlack;
  }

  /// Get appropriate text SVG based on theme brightness
  static String getTextSvg(Brightness brightness) {
    return brightness == Brightness.dark ? textLightSvg : textBlackSvg;
  }

  /// Get logo for dark theme (default for the app)
  static String get logo => logoLight;

  /// Get text for dark theme (default for the app)
  static String get text => textLight;

  /// Get text SVG for dark theme (default for the app)
  static String get textSvg => textLightSvg;
}

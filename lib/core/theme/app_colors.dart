import 'package:flutter/material.dart';

/// Effulgence'26 Design System Colors
/// Strategic Theme:  "Innovation and Beyond" - Dark Futuristic Tech Conference Aesthetic
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════
  // CORE BACKGROUNDS (Design Tokens from Requirements)
  // ═══════════════════════════════════════════════════════════════
  static const Color bgPrimary = Color(0xFF0B0E11); // Main scaffold
  static const Color bgSecondary = Color(0xFF12161C); // Cards, sheets
  static const Color bgOverlay = Color(0xFF1C1F26); // Dialogs, modals

  // Legacy aliases for compatibility
  static const Color background = bgPrimary;
  static const Color backgroundSecondary = bgSecondary;
  static const Color backgroundTertiary = bgOverlay;
  static const Color surface = bgSecondary;
  static const Color surfaceVariant = Color(0xFF23272F);

  // ═══════════════════════════════════════��═══════════════════════
  // ACCENT PALETTE (Brush-Stroke Identity from Brochure)
  // ═══════════════════════════════════════════════════════════════
  static const Color innovationGreen = Color(0xFF2ECC71); // Vision, Success
  static const Color electricBlue = Color(0xFF3A6DFF); // Coding, Software
  static const Color crimsonRed = Color(0xFFE74C3C); // Robotics, E-sports
  static const Color royalPurple = Color(0xFF9B59B6); // Core Engineering
  static const Color amberGold = Color(0xFFF1C40F); // Timeline, Highlights
  static const Color cyanTeal = Color(0xFF1ABC9C); // Overview, Stats

  // Primary accent (default action color)
  static const Color primary = amberGold; // Changed from orange
  static const Color primaryLight = Color(0xFFF4D03F);
  static const Color primaryDark = Color(0xFFD4AC0D);

  // Secondary accent
  static const Color secondary = cyanTeal;
  static const Color secondaryLight = Color(0xFF48C9B0);
  static const Color secondaryDark = Color(0xFF17A589);

  // Tertiary accent
  static const Color accent = electricBlue;
  static const Color accentLight = Color(0xFF5B8AFF);
  static const Color accentDark = Color(0xFF2952CC);

  // ═══════════════════════════════════════════════════════════════
  // TEXT COLORS (High Contrast for Dark UI)
  // ═══════════════════════════════════════════════════════════════
  static const Color textPrimary = Color(0xFFFFFFFF); // Headlines
  static const Color textSecondary = Color(0xFFD0D3D8); // Body
  static const Color textMuted = Color(0xFF8A8F98); // Metadata
  static const Color textDisabled = Color(0xFF4B5563);
  static const Color textTertiary = textMuted;

  // ═══════════════════════════════════════════════════════════════
  // STATUS COLORS (Semantic States)
  // ═══════════════════════════════════════════════════════════════
  static const Color success = innovationGreen;
  static const Color successLight = Color(0xFF58D68D);
  static const Color successDark = Color(0xFF27AE60);

  static const Color warning = amberGold;
  static const Color warningLight = Color(0xFFF4D03F);
  static const Color warningDark = Color(0xFFD4AC0D);

  static const Color error = crimsonRed;
  static const Color errorLight = Color(0xFFEC7063);
  static const Color errorDark = Color(0xFFC0392B);

  static const Color info = electricBlue;
  static const Color infoLight = Color(0xFF5B8AFF);
  static const Color infoDark = Color(0xFF2952CC);

  // ═══════════════════════════════════════════════════════════════
  // EVENT STATUS COLORS (from original - kept for compatibility)
  // ═══════════════════════════════════════════════════════════════
  static const Color eventLive = innovationGreen;
  static const Color eventUpcoming = electricBlue;
  static const Color eventCompleted = Color(0xFF6B7280);

  // ═══════════════════════════════════════════════════════════════
  // BORDERS & DIVIDERS
  // ═══════════════════════════════════════════════════════════════
  static const Color border = Color(0xFF2A2E36);
  static const Color borderLight = Color(0xFF3F444D);
  static const Color borderFocused = amberGold;
  static const Color divider = Color(0xFF2A2E36);

  // ═══════════════════════════════════════════════════════════════
  // OVERLAY & EFFECTS
  // ═══════════════════════════════════════════════════════════════
  static const Color overlay = Color(0xCC000000); // 80% opacity
  static const Color shimmerBase = bgSecondary;
  static const Color shimmerHighlight = surfaceVariant;

  // ═══════════════════════════════════════════════════════════════
  // GRADIENTS (Brush-Stroke Headers)
  // ═══════════════════════════════════════════════════════════════

  /// Amber Gold Gradient (Timeline, Highlights)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF39C12), Color(0xFFF1C40F), Color(0xFFFDED72)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Cyan Teal Gradient (Overview, Stats)
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF16A085), Color(0xFF1ABC9C), Color(0xFF48C9B0)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Crimson Red Gradient (Robotics, Alerts)
  static const LinearGradient crimsonGradient = LinearGradient(
    colors: [Color(0xFFC0392B), Color(0xFFE74C3C), Color(0xFFEC7063)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Electric Blue Gradient (Coding, Software)
  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF2952CC), Color(0xFF3A6DFF), Color(0xFF5B8AFF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Royal Purple Gradient (Core Engineering)
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF7D3C98), Color(0xFF9B59B6), Color(0xFFBB8FCE)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Innovation Green Gradient (Vision, Success)
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF27AE60), Color(0xFF2ECC71), Color(0xFF58D68D)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Background gradient for screens
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [bgPrimary, bgSecondary, bgOverlay],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Card depth gradient
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1E26), Color(0xFF12161C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════════════════════════
  // GLOW EFFECTS (Futuristic Depth)
  // ═══════════════════════════════════════════════════════════════

  static List<BoxShadow> primaryGlow({double opacity = 0.3, double blur = 12}) {
    return [
      BoxShadow(
        color: primary.withValues(alpha: opacity),
        blurRadius: blur,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static List<BoxShadow> accentGlow(
    Color color, {
    double opacity = 0.4,
    double blur = 16,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: blur,
        spreadRadius: -2,
        offset: const Offset(0, 6),
      ),
    ];
  }

  static List<BoxShadow> cardElevation({double opacity = 0.2}) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: opacity),
        blurRadius: 16,
        spreadRadius: -4,
        offset: const Offset(0, 8),
      ),
    ];
  }
}

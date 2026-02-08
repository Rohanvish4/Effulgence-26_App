import 'package:flutter/material.dart';

/// Effulgence'26 Design System - Titanium & Emerald Edition
/// A premium, non-blue aesthetic focusing on slate-metal and precision greens.
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════
  // CORE BACKGROUNDS (Deep Charcoal & Gunmetal)
  // ═══════════════════════════════════════════════════════════════
  static const Color bgPrimary = Color(0xFF0C0D0F); // Near-black matte
  static const Color bgSecondary = Color(0xFF16181D); // Gunmetal surface
  static const Color bgOverlay = Color(0xFF1F2229); // Elevated slate

  static const Color background = bgPrimary;
  static const Color backgroundSecondary = bgSecondary;
  static const Color backgroundTertiary = bgOverlay;
  static const Color surface = bgSecondary;
  static const Color surfaceVariant = Color(0xFF282C34);

  // ═══════════════════════════════════════════════════════════════
  // ACCENT PALETTE (Emerald & Industrial Tones)
  // ═══════════════════════════════════════════════════════════════
  static const Color innovationGreen = Color.fromRGBO(
    45,
    212,
    191,
    1,
  ); // Primary Brand
  static const Color electricBlue = Color(0xFF34D399); // Swapped to Mint-Green
  static const Color crimsonRed = Color(0xFFFB7185); // Soft Rose-Red
  static const Color royalPurple = Color(0xFFA78BFA); // Soft Lavender
  static const Color cyanTeal = Color(0xFF06B6D4); // Cyber Cyan

  // Primary accent (Now a High-Precision Green/Teal)
  static const Color primary = innovationGreen;
  static const Color primaryLight = Color(0xFF99F6E4);
  static const Color primaryDark = Color(0xFF0D9488);

  // Secondary accent (Deep Mint)
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFF6EE7B7);
  static const Color secondaryDark = Color(0xFF064E3B);

  // Tertiary accent
  static const Color accent = royalPurple;
  static const Color accentLight = Color(0xFFC4B5FD);
  static const Color accentDark = Color(0xFF6D28D9);

  // ═══════════════════════════════════════════════════════════════
  // TEXT COLORS (Calibrated for Dark UI)
  // ═══════════════════════════════════════════════════════════════
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8); // Slate
  static const Color textMuted = Color(0xFF64748B); // Muted Slate
  static const Color textDisabled = Color(0xFF334155);
  static const Color textTertiary = textMuted;

  // ═══════════════════════════════════════════════════════════════
  // STATUS COLORS (Semantic States)
  // ═══════════════════════════════════════════════════════════════
  static const Color success = innovationGreen;
  static const Color successLight = Color(0xFF5EEAD4);
  static const Color successDark = Color(0xFF134E4A);

  static const Color warning = Color(0xFFFBBF24);
  static const Color warningLight = Color(0xFFFDE68A);
  static const Color warningDark = Color(0xFF92400E);

  static const Color error = crimsonRed;
  static const Color errorLight = Color(0xFFFDA4AF);
  static const Color errorDark = Color(0xFF9F1239);

  static const Color info = Color(0xFF38BDF8); // Soft Sky (Secondary Info)
  static const Color infoLight = Color(0xFF7DD3FC);
  static const Color infoDark = Color(0xFF0369A1);

  // ═══════════════════════════════════════════════════════════════
  // EVENT STATUS COLORS
  // ═══════════════════════════════════════════════════════════════
  static const Color eventLive = innovationGreen;
  static const Color eventUpcoming = Color(0xFF818CF8); // Indigo-slate
  static const Color eventCompleted = Color(0xFF475569);

  // ═══════════════════════════════════════════════════════════════
  // BORDERS & DIVIDERS
  // ═══════════════════════════════════════════════════════════════
  static const Color border = Color(0xFF2D323A);
  static const Color borderLight = Color(0xFF3E444E);
  static const Color borderFocused = primary;
  static const Color divider = Color(0xFF1E2127);

  // ═══════════════════════════════════════════════════════════════
  // OVERLAY & EFFECTS
  // ═══════════════════════════════════════════════════════════════
  static const Color overlay = Color(0xCC050506);
  static const Color shimmerBase = Color(0xFF1A1D23);
  static const Color shimmerHighlight = Color(0xFF2D323A);

  // ═══════════════════════════════════════════════════════════════
  // GRADIENTS (Titanium & Emerald Finishes)
  // ═══════════════════════════════════════════════════════════════

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F766E), Color(0xFF2DD4BF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF065F46), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient crimsonGradient = LinearGradient(
    colors: [Color(0xFF9F1239), Color(0xFFFB7185)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF64748B)], // Titanium Metallic
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF5B21B6), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = primaryGradient;

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [bgPrimary, Color(0xFF111827)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E232B), Color(0xFF12151A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════════════════════════
  // GLOW EFFECTS (Soft Mint Diffusion)
  // ═══════════════════════════════════════════════════════════════

  static List<BoxShadow> primaryGlow({
    double opacity = 0.12,
    double blur = 24,
  }) {
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
    double opacity = 0.15,
    double blur = 18,
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

  static List<BoxShadow> cardElevation({double opacity = 0.5}) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: opacity),
        blurRadius: 25,
        spreadRadius: -8,
        offset: const Offset(0, 12),
      ),
    ];
  }
}

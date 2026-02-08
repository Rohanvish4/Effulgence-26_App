import 'package:flutter/material.dart';
import '../../domain/entities/sponsor_entity.dart';

/// Widget for displaying sponsor tier badge
class SponsorTierBadge extends StatelessWidget {
  final SponsorTier tier;
  final double size;

  const SponsorTierBadge({super.key, required this.tier, this.size = 24});

  @override
  Widget build(BuildContext context) {
    final tierInfo = _getTierInfo(tier);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.5,
        vertical: size * 0.25,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: tierInfo.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: tierInfo.colors.first.withValues(alpha: 0.3),
            blurRadius: size * 0.4,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tierInfo.icon, color: Colors.white, size: size * 0.7),
          SizedBox(width: size * 0.2),
          Text(
            tierInfo.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.6,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  _TierInfo _getTierInfo(SponsorTier tier) {
    switch (tier) {
      case SponsorTier.platinum:
        return _TierInfo(
          name: 'PLATINUM',
          icon: Icons.diamond,
          colors: [const Color(0xFFE5E4E2), const Color(0xFFA8A8A8)],
        );
      case SponsorTier.gold:
        return _TierInfo(
          name: 'GOLD',
          icon: Icons.stars,
          colors: [const Color(0xFFFFD700), const Color(0xFFFFB800)],
        );
      case SponsorTier.silver:
        return _TierInfo(
          name: 'SILVER',
          icon: Icons.star,
          colors: [const Color(0xFFC0C0C0), const Color(0xFF808080)],
        );
      case SponsorTier.bronze:
        return _TierInfo(
          name: 'BRONZE',
          icon: Icons.star_half,
          colors: [const Color(0xFFCD7F32), const Color(0xFF8B5A2B)],
        );
    }
  }
}

class _TierInfo {
  final String name;
  final IconData icon;
  final List<Color> colors;

  _TierInfo({required this.name, required this.icon, required this.colors});
}

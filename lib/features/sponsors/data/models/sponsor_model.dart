import '../../domain/entities/sponsor_entity.dart';

/// Data model for Sponsor that extends the domain entity
class SponsorModel extends SponsorEntity {
  const SponsorModel({
    required super.id,
    required super.name,
    required super.logoUrl,
    required super.description,
    required super.tier,
    super.websiteUrl,
    super.tagline,
    super.imageGallery,
    super.videoUrl,
    super.products,
    super.socialLinks,
    super.contactEmail,
    super.contactPhone,
    super.displayOrder,
  });

  /// Create SponsorModel from JSON
  factory SponsorModel.fromJson(Map<String, dynamic> json) {
    return SponsorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String,
      description: json['description'] as String,
      tier: _parseTier(json['tier'] as String),
      websiteUrl: json['websiteUrl'] as String?,
      tagline: json['tagline'] as String?,
      imageGallery:
          (json['imageGallery'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      videoUrl: json['videoUrl'] as String?,
      products:
          (json['products'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      socialLinks:
          (json['socialLinks'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as String),
          ) ??
          {},
      contactEmail: json['contactEmail'] as String?,
      contactPhone: json['contactPhone'] as String?,
      displayOrder: json['displayOrder'] as int? ?? 0,
    );
  }

  /// Convert SponsorModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'description': description,
      'tier': _tierToString(tier),
      'websiteUrl': websiteUrl,
      'tagline': tagline,
      'imageGallery': imageGallery,
      'videoUrl': videoUrl,
      'products': products,
      'socialLinks': socialLinks,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'displayOrder': displayOrder,
    };
  }

  /// Parse tier from string
  static SponsorTier _parseTier(String tier) {
    switch (tier.toLowerCase()) {
      case 'platinum':
        return SponsorTier.platinum;
      case 'gold':
        return SponsorTier.gold;
      case 'silver':
        return SponsorTier.silver;
      case 'bronze':
        return SponsorTier.bronze;
      default:
        return SponsorTier.bronze;
    }
  }

  /// Convert tier to string
  static String _tierToString(SponsorTier tier) {
    switch (tier) {
      case SponsorTier.platinum:
        return 'platinum';
      case SponsorTier.gold:
        return 'gold';
      case SponsorTier.silver:
        return 'silver';
      case SponsorTier.bronze:
        return 'bronze';
    }
  }
}

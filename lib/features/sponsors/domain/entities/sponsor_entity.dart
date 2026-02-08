import 'package:equatable/equatable.dart';

/// Sponsor tier levels
enum SponsorTier { platinum, gold, silver, bronze }

/// Domain entity representing a sponsor
class SponsorEntity extends Equatable {
  final String id;
  final String name;
  final String logoUrl;
  final String description;
  final SponsorTier tier;
  final String? websiteUrl;
  final String? tagline;
  final List<String> imageGallery;
  final String? videoUrl;
  final List<String> products;
  final Map<String, String>
  socialLinks; // e.g., {'facebook': 'url', 'twitter': 'url'}
  final String? contactEmail;
  final String? contactPhone;
  final int displayOrder;

  const SponsorEntity({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.description,
    required this.tier,
    this.websiteUrl,
    this.tagline,
    this.imageGallery = const [],
    this.videoUrl,
    this.products = const [],
    this.socialLinks = const {},
    this.contactEmail,
    this.contactPhone,
    this.displayOrder = 0,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    logoUrl,
    description,
    tier,
    websiteUrl,
    tagline,
    imageGallery,
    videoUrl,
    products,
    socialLinks,
    contactEmail,
    contactPhone,
    displayOrder,
  ];
}

import 'package:effulgence26_mobile_app/features/sponsors/domain/entities/sponsor_entity.dart';

import '../models/sponsor_model.dart';


class SponsorLocalDataSource {
  Future<List<SponsorModel>> getSponsors() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return _mockSponsors;
  }

  /// Get sponsor by ID from local mock data
  Future<SponsorModel> getSponsorById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final sponsor = _mockSponsors.firstWhere(
      (s) => s.id == id,
      orElse: () => throw Exception('Sponsor not found'),
    );

    return sponsor;
  }

  /// Mock sponsors data
  static final List<SponsorModel> _mockSponsors = [

    const SponsorModel(
      id: 'sponsor_bob',
      name: 'Bank of Baroda',
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/d/df/Bank_of_Baroda_Logo_since_Dec_19.png/1280px-Bank_of_Baroda_Logo_since_Dec_19.png?20201003102031',
      description:
          "India's International Bank. A leading state-owned banking and financial services organization, serving customers globally with distinctiveness, hope, and energy.",
      tier: SponsorTier.platinum, // Defaulting to platinum as tier is still required by model but won't be shown
      tagline: "India's International Bank",  
      websiteUrl: 'https://www.bankofbaroda.in/',
      imageGallery: [],
      products: [
        'Personal Banking',
        'Corporate Banking',
        'International Banking',
        'Digital Products',
      ],
      socialLinks: {
        'linkedin': 'https://www.linkedin.com/company/bankofbaroda/',
        'twitter': 'https://twitter.com/bankofbaroda',
        'facebook': 'https://www.facebook.com/bankofbaroda/',
        'instagram': 'https://www.instagram.com/bankofbaroda/',
      },
      contactEmail: 'cs.ho@bankofbaroda.com',
      displayOrder: 1,
    ),
    // const SponsorModel(
    //   id: 'sponsor_pnb',
    //   name: 'Punjab National Bank',
    //   logoUrl:
    //       'https://pngcut.com/wp-content/uploads/2025/01/Punjab-National-Bank-png-download-1.png',
    //   description:
    //       "One of India's oldest and largest public sector banks, honoring heritage while projecting a modern, professional image. Trusted by millions for stability and security.",
    //   tier: SponsorTier.platinum,
    //   tagline: 'The Name You Can Bank Upon',
    //   websiteUrl: 'https://www.pnbindia.in/',
    //   imageGallery: [],
    //   products: [
    //     'Retail Banking',
    //     'Corporate Loans',
    //     'Agricultural Banking',
    //     'Online Services',
    //   ],
    //   socialLinks: {
    //     'linkedin': 'https://www.linkedin.com/company/punjab-national-bank/',
    //     'twitter': 'https://twitter.com/pnbindia',
    //     'facebook': 'https://www.facebook.com/pnbindia/',
    //   },
    //   contactEmail: 'care@pnb.co.in',
    //   displayOrder: 2,
    // ),
    const SponsorModel(
      id: 'sponsor_unstop',
      name: 'Unstop',
      logoUrl:
          'https://d8it4huxumps7.cloudfront.net/uploads/images/unstop/branding-guidelines/logos/blue/Unstop-Logo-Blue-Medium.png',
      description:
          'Where talent meets opportunities. A platform for students and freshers to learn, upskill, and get hired. Democratizing learning, mentorships, competitions, and jobs.',
      tier: SponsorTier.platinum,
      tagline: '#BeUnstoppable',
      websiteUrl: 'https://unstop.com/',
      imageGallery: [],
      products: [
        'Hackathons',
        'Quizzes',
        'Hiring Challenges',
        'Mentorships',
      ],
      socialLinks: {
        'linkedin': 'https://www.linkedin.com/company/unstop/',
        'twitter': 'https://twitter.com/unstop_mc',
        'instagram': 'https://www.instagram.com/unstop/',
      },
      contactEmail: 'support@unstop.com',
      displayOrder: 3,
    ),
  ];
}

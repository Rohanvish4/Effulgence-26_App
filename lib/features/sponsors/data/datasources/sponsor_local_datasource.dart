import 'package:effulgence26_mobile_app/features/sponsors/domain/entities/sponsor_entity.dart';

import '../models/sponsor_model.dart';
import '../sponsor_logo_data.dart';


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
      logoUrl: SponsorLogoData.bankOfBarodaLogo,
      description:
          "India's International Bank. A leading state-owned banking and financial services organization, serving customers globally with distinctiveness, hope, and energy.",
      tier: SponsorTier.platinum, // Defaulting to platinum as tier is still required by model but won't be shown
        tagline: 'Banking Partner',
        websiteUrl:
          'https://www.google.com/maps/place/Bank+of+Baroda/@26.2883108,82.063024,3534m/data=!3m1!1e3!4m10!1m2!2m1!1sBank+of+Baroda+near+KNIT+Administrative+Building,+Ratan+Pur,+Uttar+Pradesh!3m6!1s0x3be7b738124cec6b:0xae818da2319c70c4!8m2!3d26.2883108!4d82.0820784!15sCkpCYW5rIG9mIEJhcm9kYSBuZWFyIEtOSVQgQWRtaW5pc3RyYXRpdmUgQnVpbGRpbmcsIFJhdGFuIFB1ciwgVXR0YXIgUHJhZGVzaCIDiAEBkgEEYmFua-ABAA!16s%2Fg%2F1ptwt1yd9?hl=en&entry=ttu&g_ep=EgoyMDI2MDQwMS4wIKXMDSoASAFQAw%3D%3D',
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
      logoUrl: SponsorLogoData.unstopLogo,
      description:
          'Where talent meets opportunities. A platform for students and freshers to learn, upskill, and get hired. Democratizing learning, mentorships, competitions, and jobs.',
      tier: SponsorTier.platinum,
        tagline: 'Platform Partner',
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
    const SponsorModel(
      id: 'sponsor_shemford',
      name: 'Shemford Futuristic School',
      logoUrl: SponsorLogoData.shemfordLogo,
      description:
          'A future-ready learning environment focused on holistic growth, modern education practices, and strong academic foundations.',
      tier: SponsorTier.gold,
        tagline: 'Education Partner',
        websiteUrl: 'https://shemfordsultanpur.co.in/',
      imageGallery: [],
      products: [
        'Schooling',
        'Holistic Development',
        'Academic Excellence',
      ],
      socialLinks: {},
      displayOrder: 4,
    ),
    const SponsorModel(
      id: 'sponsor_moti_mahal',
      name: 'Moti Mahal',
      logoUrl: SponsorLogoData.motiMahalLogo,
      description:
          'A popular dining brand known for rich flavors, hearty meals, and a memorable food experience.',
      tier: SponsorTier.gold,
        tagline: 'Food Partner',
        websiteUrl:
          'https://www.google.com/maps/place/Moti+Mahal+Delux/@26.2650759,82.0771814,884m/data=!3m3!1e3!4b1!5s0x399a7cf6a49ecd11:0x9f6edebcab6212af!4m6!3m5!1s0x399a7cf41c4f3347:0xb5275aad3115a97e!8m2!3d26.2650759!4d82.0797563!16s%2Fg%2F11c52tfmdh?hl=en&entry=ttu&g_ep=EgoyMDI2MDQwMS4wIKXMDSoASAFQAw%3D%3D',
      imageGallery: [],
      products: [
        'Dining',
        'Catering',
        'North Indian Cuisine',
      ],
      socialLinks: {},
      displayOrder: 5,
    ),
    const SponsorModel(
      id: 'sponsor_nandini_eye_care',
      name: 'Nandini Eye Care',
      logoUrl: SponsorLogoData.nandiniEyeCareLogo,
      description:
          'Committed to accessible eye health services, accurate diagnosis, and compassionate patient care.',
      tier: SponsorTier.gold,
        tagline: 'Healthcare Partner',
        websiteUrl:
          'https://www.google.com/maps/place/Nandini+Eye+Care/@26.2545037,82.0564999,884m/data=!3m2!1e3!4b1!4m6!3m5!1s0x399a7d44854b6687:0xbdd3042cf0817f88!8m2!3d26.2545037!4d82.0590748!16s%2Fg%2F11sfhzh7jr?hl=en&entry=ttu&g_ep=EgoyMDI2MDQwMS4wIKXMDSoASAFQAw%3D%3D',
      imageGallery: [],
      products: [
        'Eye Checkups',
        'Vision Care',
        'Consultations',
      ],
      socialLinks: {},
      displayOrder: 6,
    ),
    const SponsorModel(
      id: 'sponsor_skylark',
      name: 'Skylark',
      logoUrl: SponsorLogoData.skylarkLogo,
      description:
          'A forward-looking brand supporting innovation, quality, and dependable service experiences.',
      tier: SponsorTier.gold,
        tagline: 'Associate Sponsor',
        websiteUrl: 'https://www.skylarksalon.com/',
      imageGallery: [],
      products: [
        'Business Services',
        'Operations',
        'Support Solutions',
      ],
      socialLinks: {},
      displayOrder: 7,
    ),
    const SponsorModel(
      id: 'sponsor_mba_kapde_wala',
      name: 'MBA KAPDE WALA',
      logoUrl: SponsorLogoData.mbaKapdeWalaLogo,
      description:
          'A fashion and apparel brand bringing style, practicality, and everyday wear together for modern customers.',
      tier: SponsorTier.gold,
        tagline: 'Associate Sponsor',
      websiteUrl: 'https://mbakapdewala.com/',
      imageGallery: [],
      products: [
        'Apparel',
        'Fashion Retail',
        'Lifestyle Wear',
      ],
      socialLinks: {},
      displayOrder: 8,
    ),
  ];
}

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
    // Platinum Sponsors
    // const SponsorModel(
    //   id: 'sponsor_1',
    //   name: 'TechCorp Global',
    //   logoUrl:
    //       'https://via.placeholder.com/300x150/6366f1/ffffff?text=TechCorp+Global',
    //   description:
    //       'TechCorp Global is a leading technology company specializing in AI, cloud computing, and enterprise solutions. With over 20 years of experience, we deliver innovative products that transform businesses worldwide.',
    //   tier: SponsorTier.platinum,
    //   tagline: 'Innovating Tomorrow, Today',
    //   websiteUrl: 'https://techcorp.example.com',
    //   imageGallery: [
    //     'https://via.placeholder.com/800x600/6366f1/ffffff?text=Product+1',
    //     'https://via.placeholder.com/800x600/8b5cf6/ffffff?text=Product+2',
    //     'https://via.placeholder.com/800x600/a78bfa/ffffff?text=Office',
    //   ],
    //   products: [
    //     'AI-Powered Analytics Platform',
    //     'Cloud Infrastructure Solutions',
    //     'Enterprise Resource Planning',
    //     'Cybersecurity Suite',
    //   ],
    //   socialLinks: {
    //     'linkedin': 'https://linkedin.com/company/techcorp',
    //     'twitter': 'https://twitter.com/techcorp',
    //     'facebook': 'https://facebook.com/techcorp',
    //   },
    //   contactEmail: 'contact@techcorp.example.com',
    //   contactPhone: '+1-555-0100',
    //   displayOrder: 1,
    // ),
    // const SponsorModel(
    //   id: 'sponsor_2',
    //   name: 'Digital Innovations Inc',
    //   logoUrl:
    //       'https://via.placeholder.com/300x150/8b5cf6/ffffff?text=Digital+Innovations',
    //   description:
    //       'Digital Innovations Inc is at the forefront of digital transformation, offering cutting-edge solutions in mobile app development, web technologies, and IoT. We partner with organizations to drive digital excellence.',
    //   tier: SponsorTier.platinum,
    //   tagline: 'Transform Your Digital Future',
    //   websiteUrl: 'https://digitalinnovations.example.com',
    //   imageGallery: [
    //     'https://via.placeholder.com/800x600/8b5cf6/ffffff?text=Mobile+Apps',
    //     'https://via.placeholder.com/800x600/a78bfa/ffffff?text=Web+Platform',
    //   ],
    //   products: [
    //     'Mobile App Development',
    //     'Web Application Framework',
    //     'IoT Solutions',
    //     'Digital Marketing Tools',
    //   ],
    //   socialLinks: {
    //     'linkedin': 'https://linkedin.com/company/digitalinnovations',
    //     'twitter': 'https://twitter.com/digitalinno',
    //     'instagram': 'https://instagram.com/digitalinnovations',
    //   },
    //   contactEmail: 'hello@digitalinnovations.example.com',
    //   contactPhone: '+1-555-0200',
    //   displayOrder: 2,
    // ),

    // // Gold Sponsors
    // const SponsorModel(
    //   id: 'sponsor_3',
    //   name: 'CloudMasters',
    //   logoUrl:
    //       'https://via.placeholder.com/300x150/f59e0b/ffffff?text=CloudMasters',
    //   description:
    //       'CloudMasters provides comprehensive cloud solutions, from infrastructure to platform services. Our expertise helps businesses scale efficiently and securely in the cloud.',
    //   tier: SponsorTier.gold,
    //   tagline: 'Your Cloud, Simplified',
    //   websiteUrl: 'https://cloudmasters.example.com',
    //   imageGallery: [
    //     'https://via.placeholder.com/800x600/f59e0b/ffffff?text=Cloud+Infrastructure',
    //   ],
    //   products: [
    //     'Cloud Hosting Services',
    //     'DevOps Solutions',
    //     'Container Orchestration',
    //     'Serverless Computing',
    //   ],
    //   socialLinks: {
    //     'linkedin': 'https://linkedin.com/company/cloudmasters',
    //     'twitter': 'https://twitter.com/cloudmasters',
    //   },
    //   contactEmail: 'support@cloudmasters.example.com',
    //   contactPhone: '+1-555-0300',
    //   displayOrder: 3,
    // ),
    // const SponsorModel(
    //   id: 'sponsor_4',
    //   name: 'DataSync Solutions',
    //   logoUrl:
    //       'https://via.placeholder.com/300x150/eab308/ffffff?text=DataSync',
    //   description:
    //       'DataSync Solutions specializes in data integration, analytics, and business intelligence. We help organizations unlock the power of their data through intelligent solutions.',
    //   tier: SponsorTier.gold,
    //   tagline: 'Data-Driven Excellence',
    //   websiteUrl: 'https://datasync.example.com',
    //   products: [
    //     'Data Integration Platform',
    //     'Business Intelligence Tools',
    //     'Real-time Analytics',
    //     'Data Warehouse Solutions',
    //   ],
    //   socialLinks: {'linkedin': 'https://linkedin.com/company/datasync'},
    //   contactEmail: 'info@datasync.example.com',
    //   displayOrder: 4,
    // ),

    // // Silver Sponsors
    // const SponsorModel(
    //   id: 'sponsor_5',
    //   name: 'WebWizards',
    //   logoUrl:
    //       'https://via.placeholder.com/300x150/94a3b8/ffffff?text=WebWizards',
    //   description:
    //       'WebWizards is a creative web development agency that builds stunning, high-performance websites and web applications for businesses of all sizes.',
    //   tier: SponsorTier.silver,
    //   tagline: 'Crafting Digital Experiences',
    //   websiteUrl: 'https://webwizards.example.com',
    //   products: [
    //     'Custom Web Development',
    //     'E-commerce Solutions',
    //     'CMS Development',
    //     'UI/UX Design',
    //   ],
    //   socialLinks: {
    //     'twitter': 'https://twitter.com/webwizards',
    //     'instagram': 'https://instagram.com/webwizards',
    //   },
    //   contactEmail: 'hello@webwizards.example.com',
    //   displayOrder: 5,
    // ),
    // const SponsorModel(
    //   id: 'sponsor_6',
    //   name: 'CodeCrafters',
    //   logoUrl:
    //       'https://via.placeholder.com/300x150/64748b/ffffff?text=CodeCrafters',
    //   description:
    //       'CodeCrafters is a software development company focused on creating robust, scalable applications using modern technologies and best practices.',
    //   tier: SponsorTier.silver,
    //   tagline: 'Code with Precision',
    //   products: [
    //     'Custom Software Development',
    //     'API Development',
    //     'Code Review Services',
    //     'Technical Consulting',
    //   ],
    //   socialLinks: {
    //     'linkedin': 'https://linkedin.com/company/codecrafters',
    //     'github': 'https://github.com/codecrafters',
    //   },
    //   contactEmail: 'contact@codecrafters.example.com',
    //   displayOrder: 6,
    // ),

    // // Bronze Sponsors
    // const SponsorModel(
    //   id: 'sponsor_7',
    //   name: 'StartupHub',
    //   logoUrl:
    //       'https://via.placeholder.com/300x150/cd7f32/ffffff?text=StartupHub',
    //   description:
    //       'StartupHub is a co-working space and incubator supporting early-stage startups with mentorship, resources, and networking opportunities.',
    //   tier: SponsorTier.bronze,
    //   tagline: 'Where Ideas Take Flight',
    //   websiteUrl: 'https://startuphub.example.com',
    //   products: [
    //     'Co-working Space',
    //     'Startup Incubation',
    //     'Mentorship Programs',
    //     'Networking Events',
    //   ],
    //   socialLinks: {
    //     'facebook': 'https://facebook.com/startuphub',
    //     'instagram': 'https://instagram.com/startuphub',
    //   },
    //   contactEmail: 'info@startuphub.example.com',
    //   displayOrder: 7,
    // ),
    // const SponsorModel(
    //   id: 'sponsor_8',
    //   name: 'TechPrint Media',
    //   logoUrl:
    //       'https://via.placeholder.com/300x150/b8860b/ffffff?text=TechPrint',
    //   description:
    //       'TechPrint Media is a technology-focused publishing company providing news, insights, and educational content for tech professionals.',
    //   tier: SponsorTier.bronze,
    //   tagline: 'Stay Informed, Stay Ahead',
    //   products: [
    //     'Tech News Platform',
    //     'Online Courses',
    //     'Industry Reports',
    //     'Podcasts',
    //   ],
    //   socialLinks: {'twitter': 'https://twitter.com/techprint'},
    //   contactEmail: 'contact@techprint.example.com',
    //   displayOrder: 8,
    // ),
  ];
}

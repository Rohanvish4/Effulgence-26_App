import 'package:effulgence26_mobile_app/features/auth/data/models/auth_response_model.dart';
import 'package:effulgence26_mobile_app/features/auth/data/models/user_model.dart';
import 'package:effulgence26_mobile_app/features/event/data/models/event_model.dart';
import 'package:effulgence26_mobile_app/features/event/data/models/participation_model.dart';
import 'package:effulgence26_mobile_app/features/event/domain/entities/event_entity.dart';
import 'package:effulgence26_mobile_app/features/event/domain/entities/participation_entity.dart';
import 'package:effulgence26_mobile_app/features/profile/data/models/edit_response_model.dart';
import 'package:effulgence26_mobile_app/features/profile/data/models/user_profile_model.dart';
import 'package:effulgence26_mobile_app/features/qrcode/data/models/qrcode_model.dart';

/// All static mock data used in demo mode.
class DemoData {
  // ---------------------------------------------------------------------------
  // Demo user
  // ---------------------------------------------------------------------------

  static const UserModel demoUser = UserModel(
    id: 'demo-user-001',
    name: 'Demo User',
    email: 'demo@effulgence26.in',
    mobile: 9999999999,
    rollNo: 1001,
    role: 'ADMIN',
    isEmailVerified: true,
    isVerified: true,
    approvalStatus: 'APPROVED',
    collegeName: 'Thakur College of Engineering & Technology',
    effulgenceId: 'EFF26-DEMO',
    registrationId: 'REG-DEMO-001',
    managedDomains: [],
  );

  static AuthResponseModel get demoAuthResponse => const AuthResponseModel(
        user: demoUser,
        message: 'Welcome to Effulgence 26 Demo!',
      );

  // ---------------------------------------------------------------------------
  // Demo profile
  // ---------------------------------------------------------------------------

  static const UserProfileModel demoProfile = UserProfileModel(
    id: 'demo-user-001',
    name: 'Demo User',
    email: 'demo@effulgence26.in',
    mobile: 9999999999,
    rollNo: 1001,
    role: 'ADMIN',
    isEmailVerified: true,
    approvalStatus: 'APPROVED',
    isInternalUser: false,
    isBlocked: false,
    qrcode: 'EFF26:REG-DEMO-001:demo-user-001',
    collegeName: 'Thakur College of Engineering & Technology',
    registrationId: 'REG-DEMO-001',
  );

  static EditResponseModel get demoEditResponse => const EditResponseModel(
        user: demoProfile,
        message: 'Profile updated successfully',
      );

  // ---------------------------------------------------------------------------
  // Demo QR code
  // ---------------------------------------------------------------------------

  static const QrCodeModel demoQrCode = QrCodeModel(
    qrCodeData: 'EFF26:REG-DEMO-001:demo-user-001',
    registrationId: 'REG-DEMO-001',
    name: 'Demo User',
  );

  // ---------------------------------------------------------------------------
  // Mock users for admin dashboard
  // ---------------------------------------------------------------------------

  static List<UserModel> get mockUsers => [
        demoUser,
        const UserModel(
          id: 'demo-user-002',
          name: 'Priya Sharma',
          email: 'priya.sharma@effulgence26.in',
          mobile: 9876543210,
          rollNo: 1002,
          role: 'ADMIN',
          isEmailVerified: true,
          isVerified: true,
          isInternalUser: true,
          approvalStatus: 'APPROVED',
          collegeName: 'Thakur College of Engineering & Technology',
          effulgenceId: 'EFF26-A002',
          registrationId: 'REG-DEMO-002',
          managedDomains: ['TECHNICAL', 'LITERARY'],
        ),
        const UserModel(
          id: 'demo-user-003',
          name: 'Rahul Mehta',
          email: 'rahul.mehta@effulgence26.in',
          mobile: 9123456780,
          rollNo: 1003,
          role: 'ADMIN',
          isEmailVerified: true,
          isVerified: true,
          isInternalUser: true,
          approvalStatus: 'APPROVED',
          collegeName: 'Thakur College of Engineering & Technology',
          effulgenceId: 'EFF26-A003',
          registrationId: 'REG-DEMO-003',
          managedDomains: ['CULTURAL', 'GAMING'],
        ),
        const UserModel(
          id: 'demo-user-004',
          name: 'Anjali Patel',
          email: 'anjali.patel@gmail.com',
          mobile: 9001234567,
          rollNo: 2001,
          role: 'USER',
          isEmailVerified: true,
          isVerified: true,
          isInternalUser: false,
          approvalStatus: 'APPROVED',
          collegeName: 'K.J. Somaiya College of Engineering',
          effulgenceId: 'EFF26-U001',
          registrationId: 'REG-DEMO-004',
          managedDomains: [],
        ),
        const UserModel(
          id: 'demo-user-005',
          name: 'Arjun Nair',
          email: 'arjun.nair@gmail.com',
          mobile: 9234567801,
          rollNo: 2002,
          role: 'USER',
          isEmailVerified: true,
          isVerified: true,
          isInternalUser: false,
          approvalStatus: 'APPROVED',
          collegeName: 'VJTI Mumbai',
          effulgenceId: 'EFF26-U002',
          registrationId: 'REG-DEMO-005',
          managedDomains: [],
        ),
        const UserModel(
          id: 'demo-user-006',
          name: 'Sneha Joshi',
          email: 'sneha.joshi@gmail.com',
          mobile: 9345678012,
          rollNo: 2003,
          role: 'USER',
          isEmailVerified: true,
          isVerified: true,
          isInternalUser: false,
          approvalStatus: 'APPROVED',
          collegeName: 'Fr. Conceicao Rodrigues College of Engineering',
          effulgenceId: 'EFF26-U003',
          registrationId: 'REG-DEMO-006',
          managedDomains: [],
        ),
        const UserModel(
          id: 'demo-user-007',
          name: 'Vikram Singh',
          email: 'vikram.singh@gmail.com',
          mobile: 9456789012,
          rollNo: 2004,
          role: 'USER',
          isEmailVerified: false,
          isVerified: false,
          isInternalUser: false,
          approvalStatus: 'PENDING',
          collegeName: 'Sardar Patel Institute of Technology',
          effulgenceId: null,
          registrationId: null,
          managedDomains: [],
        ),
        const UserModel(
          id: 'demo-user-008',
          name: 'Meera Kapoor',
          email: 'meera.kapoor@gmail.com',
          mobile: 9567890123,
          rollNo: 2005,
          role: 'USER',
          isEmailVerified: true,
          isVerified: true,
          isInternalUser: false,
          approvalStatus: 'APPROVED',
          collegeName: 'Don Bosco Institute of Technology',
          effulgenceId: 'EFF26-U004',
          registrationId: 'REG-DEMO-008',
          managedDomains: [],
        ),
      ];

  // ---------------------------------------------------------------------------
  // Demo events – 15 realistic fest events across multiple domains
  // ---------------------------------------------------------------------------

  static List<EventModel> get mockEvents {
    // Fest dates: Feb 14–16 2026
    final d1 = DateTime(2026, 2, 14);
    final d2 = DateTime(2026, 2, 15);
    final d3 = DateTime(2026, 2, 16);
    final regDeadline = DateTime(2026, 2, 10);

    return [
      // ── TECHNICAL ────────────────────────────────────────────────────────────
      EventModel(
        id: 'event-tech-001',
        title: 'Hackathon 26',
        domain: 'TECHNICAL',
        eventType: 'TEAM',
        eventVenue: 'Innovation Hub, Block A',
        eventTime: d1.add(const Duration(hours: 9)),
        endTime: d2.add(const Duration(hours: 18)),
        registrationDeadline: regDeadline,
        status: 'COMPLETED',
        isDeleted: false,
        eventRound: 1,
        teamConfig: const TeamConfig(minSize: 2, maxSize: 4),
        description:
            'A 24-hour hackathon where teams build innovative solutions to real-world problems. '
            'Solve pressing challenges using any technology stack. '
            'Prizes worth ₹1,00,000 up for grabs!',
        rules:
            '1. Teams of 2–4 members only.\n'
            '2. All code must be written during the event — no pre-built projects.\n'
            '3. Open-source libraries are allowed.\n'
            '4. Projects judged on innovation, implementation quality, and presentation.\n'
            '5. Incomplete submissions will not be evaluated.',
        contacts: [
          const EventContact(
              name: 'Rahul Sharma', number: '9876543210', post: 'Coordinator'),
          const EventContact(
              name: 'Ananya Mehta',
              number: '9123456780',
              post: 'Co-Coordinator'),
        ],
      ),
      EventModel(
        id: 'event-tech-002',
        title: 'Code Quest',
        domain: 'TECHNICAL',
        eventType: 'INDIVIDUAL',
        eventVenue: 'Computer Lab, Block C',
        eventTime: d1.add(const Duration(hours: 10)),
        endTime: d1.add(const Duration(hours: 13)),
        registrationDeadline: regDeadline,
        status: 'COMPLETED',
        isDeleted: false,
        eventRound: 2,
        description:
            'A multi-round competitive programming contest with algorithmic challenges '
            'ranging from easy to expert level. Solve the most problems in the least time!',
        rules:
            '1. Individual participation only.\n'
            '2. An online judge will be used for evaluation.\n'
            '3. Any programming language is permitted.\n'
            '4. Plagiarism results in immediate disqualification.\n'
            '5. Internet access is restricted to the judge platform only.',
        contacts: [
          const EventContact(
              name: 'Priya Patel', number: '9234567801', post: 'Event Head'),
        ],
      ),
      EventModel(
        id: 'event-tech-003',
        title: 'Robo Wars',
        domain: 'TECHNICAL',
        eventType: 'TEAM',
        eventVenue: 'Ground Floor Arena, Block D',
        eventTime: d2.add(const Duration(hours: 11)),
        endTime: d2.add(const Duration(hours: 17)),
        registrationDeadline: regDeadline,
        status: 'COMPLETED',
        isDeleted: false,
        eventRound: 1,
        teamConfig: const TeamConfig(minSize: 2, maxSize: 5),
        description:
            'Build and battle! Design remote-controlled combat robots and fight to be '
            'the last bot standing in our 4×4 m arena. Weight category: up to 15 kg.',
        rules:
            '1. Teams of 2–5 members.\n'
            '2. Robot weight must not exceed 15 kg.\n'
            '3. Robots must be RC-controlled (autonomous bots not allowed).\n'
            '4. No sharp projectiles or explosive/flammable materials.\n'
            '5. Organiser\'s decision is final in case of any dispute.',
        contacts: [
          const EventContact(
              name: 'Vikram Singh', number: '9876501234', post: 'Coordinator'),
        ],
      ),
      EventModel(
        id: 'event-tech-004',
        title: 'Tech Quiz',
        domain: 'TECHNICAL',
        eventType: 'TEAM',
        eventVenue: 'Seminar Hall, Block B',
        eventTime: d1.add(const Duration(hours: 14)),
        endTime: d1.add(const Duration(hours: 16)),
        registrationDeadline: regDeadline,
        status: 'COMPLETED',
        isDeleted: false,
        eventRound: 2,
        teamConfig: const TeamConfig(minSize: 2, maxSize: 3),
        description:
            'A fast-paced general technology quiz covering AI, cybersecurity, networking, '
            'hardware, and current tech trends across multiple exciting rounds.',
        rules:
            '1. Teams of 2–3 members.\n'
            '2. No electronic devices during the quiz rounds.\n'
            '3. Buzzer-round rules will be explained before the event begins.\n'
            '4. The quizmaster\'s decision is final.',
        contacts: [
          const EventContact(
              name: 'Sonal Joshi', number: '9001234567', post: 'Quiz Master'),
        ],
      ),
      EventModel(
        id: 'event-tech-005',
        title: 'Project Expo',
        domain: 'TECHNICAL',
        eventType: 'TEAM',
        eventVenue: 'Exhibition Hall, Block A',
        eventTime: d3.add(const Duration(hours: 10)),
        endTime: d3.add(const Duration(hours: 16)),
        registrationDeadline: regDeadline,
        status: 'COMPLETED',
        isDeleted: false,
        eventRound: 1,
        teamConfig: const TeamConfig(minSize: 2, maxSize: 6),
        description:
            'Showcase your projects to industry experts and judges. '
            'Best projects win internship opportunities, mentorship, and cash prizes!',
        rules:
            '1. Teams of 2–6 members.\n'
            '2. Projects must be original work by the registered team.\n'
            '3. 10 minutes for presentation + 5 minutes for Q&A.\n'
            '4. Working prototypes or live demos are strongly preferred.\n'
            '5. No plagiarised work will be considered.',
        contacts: [
          const EventContact(
              name: 'Dr. Anil Gupta',
              number: '9876543299',
              post: 'Faculty Coordinator'),
        ],
      ),

      // ── CULTURAL ─────────────────────────────────────────────────────────────
      EventModel(
        id: 'event-cult-001',
        title: 'Dance Battle',
        domain: 'CULTURAL',
        eventType: 'TEAM',
        eventVenue: 'Open Air Stage',
        eventTime: d2.add(const Duration(hours: 16)),
        endTime: d2.add(const Duration(hours: 20)),
        registrationDeadline: regDeadline,
        status: 'COMPLETED',
        isDeleted: false,
        eventRound: 2,
        teamConfig: const TeamConfig(minSize: 4, maxSize: 12),
        description:
            'An electrifying dance competition spanning all styles — hip-hop, contemporary, '
            'folk, and freestyle. Battle it out on the main stage in front of thousands!',
        rules:
            '1. Teams of 4–12 members.\n'
            '2. Performance duration: 5–8 minutes.\n'
            '3. Music tracks must be submitted 48 hours before the event.\n'
            '4. No offensive or adult content.\n'
            '5. Props are allowed but must be cleared by organizers beforehand.',
        contacts: [
          const EventContact(
              name: 'Neha Kulkarni',
              number: '9345678012',
              post: 'Cultural Head'),
        ],
      ),
      EventModel(
        id: 'event-cult-002',
        title: 'Melodia – Solo Singing',
        domain: 'CULTURAL',
        eventType: 'INDIVIDUAL',
        eventVenue: 'Indoor Auditorium',
        eventTime: d1.add(const Duration(hours: 15)),
        endTime: d1.add(const Duration(hours: 19)),
        registrationDeadline: regDeadline,
        status: 'COMPLETED',
        isDeleted: false,
        eventRound: 2,
        description:
            'Pour your heart out in this solo singing competition! '
            'Any language, any genre — Bollywood, classical, Western, or folk. '
            'Impress the judges with your voice.',
        rules:
            '1. Individual participation only.\n'
            '2. Song duration: 3–5 minutes.\n'
            '3. Karaoke tracks are allowed; live instrumentalists are welcome.\n'
            '4. Vulgar or offensive lyrics are strictly prohibited.\n'
            '5. Backing tracks must be submitted 24 hours prior to the event.',
        contacts: [
          const EventContact(
              name: 'Rohan Desai', number: '9456789012', post: 'Stage Manager'),
        ],
      ),
      EventModel(
        id: 'event-cult-003',
        title: 'Nukkad Natak',
        domain: 'CULTURAL',
        eventType: 'TEAM',
        eventVenue: 'College Courtyard',
        eventTime: d3.add(const Duration(hours: 14)),
        endTime: d3.add(const Duration(hours: 18)),
        registrationDeadline: regDeadline,
        status: 'COMPLETED',
        isDeleted: false,
        eventRound: 1,
        teamConfig: const TeamConfig(minSize: 6, maxSize: 15),
        description:
            'Street theatre on a social theme of your choice. '
            'No mics, no stage, no sets — just raw energy, conviction, and storytelling power!',
        rules:
            '1. Teams of 6–15 members.\n'
            '2. Performance duration: 15–20 minutes.\n'
            '3. Must be performed in Hindi or a regional language.\n'
            '4. No props requiring electrical setup.\n'
            '5. Theme must carry a socially relevant message.',
        contacts: [
          const EventContact(
              name: 'Aditi Sharma',
              number: '9567890123',
              post: 'Theatre Coordinator'),
        ],
      ),

      // ── GAMING ───────────────────────────────────────────────────────────────
      EventModel(
        id: 'event-game-001',
        title: 'BGMI Championship',
        domain: 'GAMING',
        eventType: 'TEAM',
        eventVenue: 'Gaming Arena, Block E',
        eventTime: d2.add(const Duration(hours: 9)),
        endTime: d2.add(const Duration(hours: 20)),
        registrationDeadline: regDeadline,
        status: 'COMPLETED',
        isDeleted: false,
        eventRound: 3,
        teamConfig: const TeamConfig(minSize: 4, maxSize: 4),
        description:
            'Compete in the most popular mobile battle royale! Squad up and fight for '
            'the top spot across 3 rounds of intense squad matches.',
        rules:
            '1. Squads of exactly 4 members.\n'
            '2. Participants must bring their own mobile devices.\n'
            '3. Emulators are strictly prohibited.\n'
            '4. Game sensitivity settings cannot be changed after lobby creation.\n'
            '5. Tournament format: 3 rounds, points-based final ranking.',
        contacts: [
          const EventContact(
              name: 'Arjun Nair', number: '9678901234', post: 'Gaming Head'),
        ],
      ),
      EventModel(
        id: 'event-game-002',
        title: 'Chess Grandmaster',
        domain: 'GAMING',
        eventType: 'INDIVIDUAL',
        eventVenue: 'Chess Room, Block B',
        eventTime: d1.add(const Duration(hours: 10)),
        endTime: d1.add(const Duration(hours: 18)),
        registrationDeadline: regDeadline,
        status: 'COMPLETED',
        isDeleted: false,
        eventRound: 4,
        description:
            'Classical chess tournament using the Swiss-system format. '
            'Prove your strategic prowess and become Effulgence 26\'s Chess Grandmaster!',
        rules:
            '1. Individual participation only.\n'
            '2. Swiss format — 5 rounds of play.\n'
            '3. Time control: 15 minutes per player per game.\n'
            '4. FIDE standard rules apply.\n'
            '5. Mobile phones must be switched off during play.',
        contacts: [
          const EventContact(
              name: 'Shreya Mehta',
              number: '9789012345',
              post: 'Chess Coordinator'),
        ],
      ),
      EventModel(
        id: 'event-game-003',
        title: 'FIFA Showdown',
        domain: 'GAMING',
        eventType: 'INDIVIDUAL',
        eventVenue: 'Gaming Arena, Block E',
        eventTime: d3.add(const Duration(hours: 10)),
        endTime: d3.add(const Duration(hours: 18)),
        registrationDeadline: regDeadline,
        status: 'COMPLETED',
        isDeleted: false,
        eventRound: 2,
        description:
            'Individual FIFA 25 tournament on PlayStation 5. '
            'Pick your club and dribble your way to the championship!',
        rules:
            '1. Individual participation.\n'
            '2. PlayStation 5 consoles will be provided by the organisers.\n'
            '3. Default game settings — no custom sliders allowed.\n'
            '4. Each match: 6 minutes each half.\n'
            '5. Knockout format from the quarter-finals onwards.',
        contacts: [
          const EventContact(
              name: 'Kunal Bose',
              number: '9890123456',
              post: 'Gaming Coordinator'),
        ],
      ),

      // ── LITERARY ─────────────────────────────────────────────────────────────
      EventModel(
        id: 'event-lit-001',
        title: 'Battle of Words – Debate',
        domain: 'LITERARY',
        eventType: 'TEAM',
        eventVenue: 'Seminar Hall 2, Block B',
        eventTime: d2.add(const Duration(hours: 10)),
        endTime: d2.add(const Duration(hours: 14)),
        registrationDeadline: regDeadline,
        status: 'COMPLETED',
        isDeleted: false,
        eventRound: 2,
        teamConfig: const TeamConfig(minSize: 2, maxSize: 2),
        description:
            'A formal parliamentary-style debate where pairs argue for or against '
            'thought-provoking motions. Topics are announced 30 minutes before each round.',
        rules:
            '1. Pairs of exactly 2 members.\n'
            '2. Topics announced 30 minutes prior to each round.\n'
            '3. Each speaker gets 4 minutes to present their argument.\n'
            '4. Points of information allowed in the final 2 minutes.\n'
            '5. Judged on content, delivery, structure, and rebuttals.',
        contacts: [
          const EventContact(
              name: 'Aishwarya Jain',
              number: '9901234567',
              post: 'Literary Head'),
        ],
      ),
      EventModel(
        id: 'event-lit-002',
        title: 'Techspeak – Technical Presentation',
        domain: 'LITERARY',
        eventType: 'INDIVIDUAL',
        eventVenue: 'Seminar Hall 1, Block B',
        eventTime: d1.add(const Duration(hours: 11)),
        endTime: d1.add(const Duration(hours: 14)),
        registrationDeadline: regDeadline,
        status: 'COMPLETED',
        isDeleted: false,
        eventRound: 1,
        description:
            'Present a technical topic of your choice to a panel of judges. '
            'Clarity, depth, and the ability to make complex ideas accessible are key.',
        rules:
            '1. Individual participation only.\n'
            '2. Presentation duration: 8–10 minutes.\n'
            '3. Q&A session: 5 minutes.\n'
            '4. Topic must be approved by coordinators in advance.\n'
            '5. Any presentation tool (PowerPoint, Keynote, etc.) is allowed.',
        contacts: [
          const EventContact(
              name: 'Prof. Smita Rao',
              number: '9012345678',
              post: 'Faculty In-Charge'),
        ],
      ),

      // ── MANAGEMENT ───────────────────────────────────────────────────────────
      EventModel(
        id: 'event-mgmt-001',
        title: 'Case Cracker',
        domain: 'MANAGEMENT',
        eventType: 'TEAM',
        eventVenue: 'Conference Room, Block A',
        eventTime: d3.add(const Duration(hours: 9)),
        endTime: d3.add(const Duration(hours: 14)),
        registrationDeadline: regDeadline,
        status: 'COMPLETED',
        isDeleted: false,
        eventRound: 2,
        teamConfig: const TeamConfig(minSize: 2, maxSize: 4),
        description:
            'Industry-inspired case study competition where teams analyse business problems '
            'and pitch solutions to a panel of corporate mentors and judges.',
        rules:
            '1. Teams of 2–4 members.\n'
            '2. Case will be provided on the day of the event.\n'
            '3. Analysis time: 60 minutes.\n'
            '4. Presentation: 10 minutes + 5 minutes Q&A.\n'
            '5. Judged on analysis quality, creativity, and feasibility.',
        contacts: [
          const EventContact(
              name: 'Meera Kapoor',
              number: '9123450678',
              post: 'Management Head'),
        ],
      ),
      EventModel(
        id: 'event-mgmt-002',
        title: 'Business Pitch',
        domain: 'MANAGEMENT',
        eventType: 'TEAM',
        eventVenue: 'Innovation Hub, Block A',
        eventTime: d2.add(const Duration(hours: 14)),
        endTime: d2.add(const Duration(hours: 18)),
        registrationDeadline: regDeadline,
        status: 'COMPLETED',
        isDeleted: false,
        eventRound: 1,
        teamConfig: const TeamConfig(minSize: 2, maxSize: 5),
        description:
            'Have a startup idea? Pitch it to our panel of angel investors and entrepreneurs! '
            'Best pitch wins mentorship sessions and exclusive funding guidance.',
        rules:
            '1. Teams of 2–5 members.\n'
            '2. Pitch duration: 7 minutes + 5 minutes Q&A.\n'
            '3. A 2-page business plan PDF must be submitted before the event.\n'
            '4. A working product is not required — idea + plan is sufficient.\n'
            '5. Judged on innovation, market potential, and presentation quality.',
        contacts: [
          const EventContact(
              name: 'Siddharth Nambiar',
              number: '9234501678',
              post: 'B-Plan Coordinator'),
        ],
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Pre-registered events for "My Events" page
  // ---------------------------------------------------------------------------

  static List<EventModel> get myRegisteredEvents {
    final all = mockEvents;
    // Demo user is "registered" for Code Quest and Chess Grandmaster
    return all.where((e) =>
        e.id == 'event-tech-002' || e.id == 'event-game-002').toList();
  }

  static List<ParticipationModel> get myMockParticipations => [
        ParticipationModel(
          id: 'part-001',
          eventId: 'event-tech-002',
          user: const ParticipationUser(
            id: 'demo-user-001',
            name: 'Demo User',
            email: 'demo@effulgence26.in',
            mobile: '9999999999',
          ),
          teamMembers: const [],
          participationType: 'INDIVIDUAL',
          registeredAt: DateTime(2026, 2, 8),
          isPresent: true,
          score: 0,
          isQualified: true,
        ),
        ParticipationModel(
          id: 'part-002',
          eventId: 'event-game-002',
          user: const ParticipationUser(
            id: 'demo-user-001',
            name: 'Demo User',
            email: 'demo@effulgence26.in',
            mobile: '9999999999',
          ),
          teamMembers: const [],
          participationType: 'INDIVIDUAL',
          registeredAt: DateTime(2026, 2, 9),
          isPresent: false,
          score: 0,
          isQualified: false,
        ),
      ];
}

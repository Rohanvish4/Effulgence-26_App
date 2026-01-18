# Effulgence'26 Mobile App

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-blue.svg)](https://dart.dev/)

Official mobile application for Effulgence'26 - The Annual Technical Festival.

##  About

Effulgence'26 is a comprehensive mobile application built with Flutter that allows users to:
- **Browse Events**: Explore all technical events with detailed information
- **Register**: Create an account and register for events
- **Track Participation**: View your registered events and participation status
- **Stay Updated**: Get real-time updates on event schedules and venues

##  Architecture

The app follows **Clean Architecture** principles with a feature-based modular structure:

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # API, App constants
│   ├── errors/             # Error handling
│   ├── network/            # API client, network info
│   ├── theme/              # Theme configuration
│   └── utils/              # Utilities and extensions
├── features/               # Feature modules
│   ├── auth/              # Authentication (Login, Register, OTP)
│   ├── event/             # Events management
│   └── home/              # Home screen
└── components/            # Reusable UI components
```

### Architecture Layers:
1. **Presentation Layer**: UI, State Management (used only Cubit)
2. **Domain Layer**: Business logic, Entities, without  Use Cases for simplicity
3. **Data Layer**: Repositories, Data Sources (Remote/Local)

**📖 Want to add a new feature?** Check out: [FEATURE_DEVELOPMENT_GUIDE.md](FEATURE_DEVELOPMENT_GUIDE.md)


##  Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart 3.9.2 or higher
- Android Studio / VS Code with Flutter extensions
- iOS: Xcode 14+ (for iOS development)

### Installation

1. **Clone the repository**
   ```bash
   you know better than us
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # Development mode
   flutter run

   # Release mode
   flutter run --release
   ```

### Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

##  Dependencies

### Main Dependencies:
- **flutter_bloc** (^9.1.1): State management
- **go_router** (^17.0.1): Navigation and routing
- **dio** (^5.9.0): HTTP client for API calls
- **flutter_secure_storage** (^10.0.0): Secure local storage
- **cached_network_image** (^3.4.1): Image caching
- **google_fonts** (^7.0.0): Custom fonts
- **shared_preferences** (^2.5.4): Local key-value storage
- **dartz** (^0.10.1): Functional programming utilities

### Dev Dependencies:
- **flutter_lints** (^5.0.0): Recommended lints for Flutter

##  Features

### Authentication
-  Email-based OTP authentication
-  User registration with college verification
-  Secure token-based session management
-  Auto-login on app restart

### Events
-  Browse all events with filters
-  View detailed event information
-  Register for individual/team events
-  Track your registered events
-  Real-time event status updates

### User Profile (Future feat)
-  View and edit profile information
-  Manage registrations
-  Logout functionality

### More Coming soon

##  API Integration

The app connects to the Effulgence'26 backend API:
- **Base URL**: `https://api.effulgence26.live/`
- **Documentation**: See `API_DOCUMENTATION.md` for detailed API specs

##  UI/UX

- **Material Design 3**: Modern Material Design components
- **Google Fonts**: Custom typography for better readability
- **Shimmer Loading**: Smooth loading states
- **Cached Images**: Optimized image loading


##  Project Structure

```
effulgence26_mobile_app/
├── android/               # Android native code
├── ios/                   # iOS native code
├── lib/                   # Flutter application code
├── test/                  # Unit and widget tests
├── pubspec.yaml          # Package dependencies
├── analysis_options.yaml # Linter configuration
└── README.md             # This file
```

##  Contributing

This is a private project for Effulgence'26. For contributions:

1. Create a feature branch
2. Make your changes following the existing code style
3. Run `flutter analyze` and `flutter test`
4. Submit a pull request

##  Development Team

- **Developer**: Team PTSC KNIT
- **Organization**: KNIT (Kamla Nehru Institute of Technology), Sultanpur
- **Event**: Effulgence'26

##  License

This project is proprietary software for Effulgence'26.

##  Support

For issues or questions:
- Create an issue in the repository
- Contact: programming.club@knit.ac.in or rohannic111@gmail.com

---


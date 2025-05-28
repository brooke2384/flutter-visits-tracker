# Visits Tracker - Flutter Mobile App

A comprehensive Route-to-Market (RTM) Sales Force Automation app built with Flutter that allows sales representatives to track customer visits, manage activities, and view analytics.

## 🚀 Features

- **Visit Management**: Create, edit, and delete customer visits
- **Activity Tracking**: Track activities completed during visits
- **Search & Filter**: Search visits by location or notes
- **Statistics Dashboard**: View visit completion rates and analytics
- **Offline Support**: Create and edit visits offline with automatic sync
- **Real-time Sync**: Automatic synchronization when back online

## 📱 Screenshots

### Visits List
![Visits List](screenshots/visits_list.png)

### Visit Form
![Visit Form](screenshots/visit_form.png)

### Visit Details
![Visit Details](screenshots/visit_details.png)

### Statistics
![Statistics](screenshots/statistics.png)

## Screenshots

### Visit List
![Visit List](assets/images/Screenshot%20(53).png)

### Visit Form
![Visit Form](assets/images/Screenshot%20(54).png)

### Activities Selection
![Activities Selection](assets/images/Screenshot%20(55).png)

### Visit Details
![Visit Details](assets/images/Screenshot%20(57).png)

### Statistics
![Statistics](assets/images/Screenshot%20(58).png)

### Sync/Offline Indicator
![Sync/Offline Indicator](assets/images/Screenshot%20(59).png)

### Modern UI Example
![Modern UI Example](assets/images/Screenshot%20(60).png)

### Responsive Layout
![Responsive Layout](assets/images/Screenshot%20(61).png)

## 🏗️ Architecture

This app follows **Clean Architecture** principles with clear separation of concerns:

\`\`\`
lib/
├── core/                    # Core functionality
│   ├── database/           # Local database setup
│   ├── di/                 # Dependency injection
│   ├── network/            # API client and network setup
│   ├── router/             # Navigation configuration
│   └── theme/              # App theming
├── features/               # Feature modules
│   ├── visits/             # Visit management feature
│   │   ├── data/           # Data layer (repositories, datasources, models)
│   │   ├── domain/         # Domain layer (entities, usecases, repositories)
│   │   └── presentation/   # Presentation layer (pages, widgets, bloc)
│   ├── customers/          # Customer management feature
│   └── activities/         # Activities management feature
└── main.dart              # App entry point
\`\`\`

### Key Architectural Decisions

1. **Clean Architecture**: Ensures separation of concerns and testability
2. **BLoC Pattern**: For predictable state management
3. **Repository Pattern**: Abstracts data sources and enables offline-first approach
4. **Dependency Injection**: Using GetIt for loose coupling
5. **Offline-First**: Local SQLite database with automatic sync

## 🛠️ Tech Stack

- **Framework**: Flutter 3.16+
- **State Management**: BLoC (flutter_bloc)
- **Navigation**: GoRouter
- **Local Database**: SQLite (sqflite)
- **Network**: Dio + Retrofit
- **Dependency Injection**: GetIt + Injectable
- **Forms**: Flutter Form Builder
- **Testing**: flutter_test, bloc_test, mocktail

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.16.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   \`\`\`bash
   git clone https://github.com/yourusername/visits-tracker.git
   cd visits-tracker
   \`\`\`

2. **Install dependencies**
   \`\`\`bash
   flutter pub get
   \`\`\`

3. **Generate code**
   \`\`\`bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   \`\`\`

4. **Run the app**
   \`\`\`bash
   flutter run
   \`\`\`

### Running Tests

\`\`\`bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/visits/domain/usecases/get_visits_test.dart
\`\`\`

### Building for Release

\`\`\`bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
\`\`\`

## 🌐 API Integration

The app integrates with a Supabase-powered REST API:

- **Base URL**: `https://kqgbftwsodpttpqgqnbh.supabase.co/rest/v1`
- **Authentication**: API Key in headers
- **Endpoints**:
  - `/customers` - Customer data
  - `/activities` - Activity types
  - `/visits` - Visit records

### API Models

\`\`\`dart
// Visit Model
{
  "id": 1,
  "customer_id": 1,
  "visit_date": "2023-10-01T10:00:00+00:00",
  "status": "Completed",
  "location": "123 Main St, Springfield",
  "notes": "Discussed new product features.",
  "activities_done": ["1", "2"],
  "created_at": "2025-04-30T05:23:03.034139+00:00"
}
\`\`\`

## 🚦 Offline Support

- All visit actions (add, edit, delete) work offline on mobile/desktop.
- Unsynced visits are marked in the UI.
- Sync happens automatically on app start and when connectivity is restored, or manually via the Sync button.
- Web uses online-only mode.

## 🧪 Testing

- Unit and widget tests for repository, BLoC, and UI screens.
- Run all tests:
  ```bash
  flutter test
  ```
- Run with coverage:
  ```bash
  flutter test --coverage
  ```
- See `test/` directory for details.

## ⚙️ CI/CD

- Automated with GitHub Actions (`.github/workflows/flutter.yml`).
- Runs on every push and pull request:
  - `flutter pub get`
  - `flutter analyze`
  - `flutter test --coverage`
  - `flutter build apk --release`
  - `flutter build web`
- Uploads coverage to Codecov (if configured).
- Add a status badge to your README if desired.

## 📊 Performance Considerations

1. **Lazy Loading**: BLoCs are created on-demand
2. **Efficient Queries**: Optimized SQLite queries with indexes
3. **Image Optimization**: Placeholder images for better performance
4. **Memory Management**: Proper disposal of controllers and streams

## 🔒 Security

- API keys are properly configured
- Local database encryption (can be added)
- Input validation and sanitization
- Secure network communication

## 🚧 Future Enhancements

- [ ] Push notifications for visit reminders
- [ ] GPS location tracking
- [ ] Photo attachments for visits
- [ ] Export functionality (PDF/Excel)
- [ ] Multi-language support
- [ ] Dark mode theme
- [ ] Biometric authentication

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Developer**: [Your Name]
- **Email**: [your.email@example.com]
- **GitHub**: [@yourusername]

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for the backend infrastructure
- BLoC library maintainers
- Open source community

---

**Note**: This app was built as part of a technical challenge for a Flutter engineering role, demonstrating production-ready code with proper architecture, testing, and CI/CD practices.

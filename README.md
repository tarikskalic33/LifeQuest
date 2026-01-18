# LifeQuest - Gamified Life Coach App

<div align="center">
  <h3>Transform your daily habits into an epic RPG adventure</h3>
  <p>An AI-powered gamified life coach that turns self-improvement into an engaging quest system</p>
</div>

## 🎮 Features

### Core Gameplay
- **Dynamic Quest System**: Daily quests across 6 categories (Health, Productivity, Learning, Mindfulness, Creativity, Social)
- **RPG Progression**: Level up by completing quests and earning XP
- **Character Stats**: Track your growth in different life areas
- **Streak System**: Maintain daily consistency for bonus rewards

### AI Mentor System
- **5 Mentor Archetypes**: Choose from The Mentor, Warrior, Scholar, Healer, or Explorer
- **Contextual Guidance**: AI provides personalized advice based on your progress
- **Celebration Messages**: Get recognized for achievements and milestones
- **Daily Interactions**: Receive motivational messages and challenges

### Achievement System
- **17+ Achievements**: Unlock badges across different categories and rarities
- **Title System**: Earn and display prestigious titles based on your accomplishments
- **Progress Tracking**: Visual progress indicators for all achievements
- **Rarity Levels**: Common, Rare, Epic, and Legendary achievements

### Gamification Elements
- **XP and Leveling**: Exponential progression system with meaningful rewards
- **Stat Tracking**: Monitor growth in 6 key life areas
- **Visual Feedback**: Animated progress bars, completion effects, and celebrations
- **Streak Rewards**: Bonus XP and achievements for consistency

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.35.5 or later
- Dart SDK (included with Flutter)
- Android Studio or VS Code
- Git

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/lifequest_app.git
cd lifequest_app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

### Development Setup

1. **Install Flutter**
   - Follow the [official Flutter installation guide](https://flutter.dev/docs/get-started/install)
   - Verify installation: `flutter doctor`

2. **IDE Setup**
   - **VS Code**: Install Flutter and Dart extensions
   - **Android Studio**: Install Flutter plugin

3. **Device Setup**
   - **Android**: Enable developer options and USB debugging
   - **iOS**: Set up Xcode and iOS simulator (macOS only)

## 📱 App Structure

### Screens
- **Home**: Dashboard with daily overview and quick actions
- **Quests**: Daily quest management and completion tracking
- **Achievements**: View unlocked achievements and available titles
- **Mentor**: Chat interface with your AI mentor
- **Profile**: User statistics and progress overview

### Architecture
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user.dart
│   ├── quest.dart
│   ├── achievement.dart
│   └── mentor.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── quest_provider.dart
│   ├── achievement_provider.dart
│   └── mentor_provider.dart
├── services/                 # Business logic
│   ├── auth_service.dart
│   ├── quest_service.dart
│   ├── achievement_service.dart
│   └── mentor_service.dart
├── screens/                  # UI screens
│   ├── onboarding.dart
│   ├── auth_screen.dart
│   ├── home.dart
│   ├── quests.dart
│   ├── achievements_screen.dart
│   ├── mentor_screen.dart
│   └── profile.dart
└── widgets/                  # Reusable components
    ├── animated_progress_bar.dart
    ├── quest_completion_animation.dart
    └── bottom_nav_bar.dart
```

## 🎯 Usage Guide

### Getting Started
1. **Onboarding**: Complete the welcome flow and create your account
2. **Choose Mentor**: Select your preferred AI mentor archetype
3. **First Quests**: Complete your first daily quests to start earning XP
4. **Track Progress**: Monitor your stats and achievements in the profile section

### Daily Workflow
1. **Morning Check-in**: Review today's quests and mentor messages
2. **Complete Quests**: Work through your daily challenges
3. **Track Progress**: Mark quests as complete to earn XP and stat boosts
4. **Evening Review**: Check achievements and prepare for tomorrow

### Advanced Features
- **Custom Quests**: Create personalized challenges (coming soon)
- **Social Features**: Connect with friends and compete (coming soon)
- **Analytics**: Detailed progress tracking and insights (coming soon)

## 🛠 Development

### Code Style
- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent formatting

### State Management
The app uses the Provider pattern for state management:
- **AuthProvider**: User authentication and profile data
- **QuestProvider**: Quest generation and completion tracking
- **AchievementProvider**: Achievement progress and unlocking
- **MentorProvider**: AI mentor interactions and messages

### Data Persistence
- **SharedPreferences**: Local storage for user data and app state
- **JSON Serialization**: All models support JSON conversion
- **Offline Support**: App works without internet connection

### Testing
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code quality
flutter analyze
```

## 🎨 Design System

### Color Palette
- **Primary**: `#7C5CFF` (Purple)
- **Secondary**: `#00E0A4` (Green)
- **Accent**: `#FFB800` (Gold)
- **Background**: `#0B1021` (Dark Blue)
- **Surface**: `#151B36` (Dark Gray)
- **Text**: `#E6E9FF` (Light Blue)

### Typography
- **Headlines**: Bold, 24-36px
- **Body**: Regular, 16-20px
- **Captions**: Light, 12-14px

### Animations
- **Duration**: 300-1000ms for most animations
- **Easing**: `Curves.easeInOut` for smooth transitions
- **Effects**: Glow, sparkle, and scale animations for feedback

## 📦 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter: sdk: flutter
  provider: ^6.0.5
  shared_preferences: ^2.2.2
  http: ^1.1.0
```

### Development Dependencies
```yaml
dev_dependencies:
  flutter_test: sdk: flutter
  flutter_lints: ^3.0.0
```

## 🚀 Deployment

### Android
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# App bundle for Play Store
flutter build appbundle --release
```

### iOS
```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

For detailed deployment instructions, see [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md).

## 🧪 Testing

### Test Coverage
- Unit tests for models and services
- Widget tests for UI components
- Integration tests for complete workflows
- Static analysis with zero issues

### Quality Assurance
- Code review process
- Automated testing pipeline
- Performance monitoring
- User acceptance testing

## 🤝 Contributing

### Development Process
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Guidelines
- Follow the existing code style
- Add tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Provider package for state management
- SharedPreferences for local storage
- The open-source community for inspiration and support

## 📞 Support

### Getting Help
- Check the [FAQ](docs/FAQ.md) for common questions
- Search existing [Issues](https://github.com/yourusername/lifequest_app/issues)
- Create a new issue for bugs or feature requests

### Contact
- **Email**: support@lifequest.app
- **Discord**: [LifeQuest Community](https://discord.gg/lifequest)
- **Twitter**: [@LifeQuestApp](https://twitter.com/lifequestapp)

---

<div align="center">
  <p>Made with ❤️ by the LifeQuest team</p>
  <p>Transform your life, one quest at a time! 🎮✨</p>
</div>


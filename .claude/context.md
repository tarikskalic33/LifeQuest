# LifeQuest Project Context for Claude Code

## Project Overview
- **Name:** LifeQuest Platinum v2.0
- **Type:** Gamified life coach mobile application
- **Framework:** Flutter (Android, iOS, Web)
- **Backend:** Firebase (Auth, Firestore, Storage, Analytics)
- **Deployment:** Manus.space

## Current Status
- Phase: Core infrastructure complete, moving to deployment & AI integration
- Last Updated: 2024-12-22
- Deployment URL: https://lifequest-dduv2x5v.manus.space (currently 404)

## Architecture
```
/lib
  /core          - Configuration, constants, DI container
  /features      - Auth, home, quests, achievements, profile, social
  /shared        - Models, widgets, providers, services, utilities
```

## Key Features
1. **Gamification System**
   - XP & leveling (base 100 XP/level, 1.5x multiplier)
   - Achievement system with rarities
   - Streak tracking
   - Quest difficulty tiers

2. **Firebase Integration**
   - Cloud sync for user data
   - Real-time leaderboards
   - Team collaboration
   - Secure authentication

3. **Quest Categories**
   - Health, Productivity, Learning, Mindfulness, Relationships, Creativity

4. **Monetization**
   - Freemium model
   - Premium tiers: Monthly ($4.99), Yearly ($39.99)

## Tech Stack
- **Frontend:** Flutter 3.x, Provider, GetIt
- **Backend:** Firebase (Firestore, Auth, Analytics, Messaging)
- **Storage:** Hive (local), SharedPreferences
- **UI:** Flutter Animate, Lottie, Google Fonts
- **AI:** OpenAI API (dart_openai)

## Known Issues
- [ ] Bash script has smart quote syntax errors
- [ ] Missing AndroidManifest.xml generation
- [ ] Heredoc terminators need fixing
- [ ] 404 on Manus deployment
- [ ] Need to configure Manus deployment method

## Priority Tasks
1. Fix deployment to Manus
2. Implement AI quest generation system
3. Build analytics dashboard
4. Add comprehensive error handling
5. Create onboarding flow
6. Implement subscription management

## Deployment Workflow
```bash
# Build for web
flutter build web --release

# Deploy to Manus
pwsh scripts/deploy-to-manus.ps1

# Verify deployment
curl https://lifequest-dduv2x5v.manus.space
```

## Development Commands
```bash
# Run locally
flutter run -d chrome

# Run tests
flutter test

# Clean build
flutter clean && flutter pub get

# Build Android
flutter build apk --release

# Build iOS
flutter build ios --release
```

## Firebase Collections
- `users` - User profiles, stats, preferences
- `quests` - Available and completed quests
- `achievements` - Unlockable achievements
- `teams` - Team information and members
- `leaderboards` - Rankings

## Environment Variables Needed
```
ANTHROPIC_API_KEY=your-claude-key
OPENAI_API_KEY=your-openai-key
MANUS_API_KEY=your-manus-key (or other deployment method)
```

## When Working on This Project
1. Always use proper Dart/Flutter conventions
2. Maintain clean architecture patterns
3. Follow dependency injection via GetIt
4. Include proper error handling
5. Keep UI animations smooth
6. Write tests for critical logic
7. Update documentation when adding features

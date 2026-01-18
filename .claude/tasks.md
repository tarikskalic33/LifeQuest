# Claude Code Tasks for LifeQuest

## Quick Tasks

### deploy
**Description:** Build and deploy LifeQuest to Manus
**Commands:**
```bash
pwsh scripts/deploy-to-manus.ps1
```

### build-web
**Description:** Build Flutter web release
**Commands:**
```bash
flutter clean
flutter pub get
flutter build web --release
```

### build-android
**Description:** Build Android APK
**Commands:**
```bash
flutter build apk --release
```

### test
**Description:** Run all tests
**Commands:**
```bash
flutter test
```

### run-local
**Description:** Run app locally in Chrome
**Commands:**
```bash
flutter run -d chrome
```

### check-deployment
**Description:** Verify Manus deployment status
**Commands:**
```bash
curl -I https://lifequest-dduv2x5v.manus.space
```

## Multi-Step Tasks

### setup-manus-deployment
**Description:** Configure Manus deployment method
**Steps:**
1. Check if Manus CLI is installed
2. If not, check for API key in environment
3. If neither, provide manual setup instructions
4. Test deployment configuration

### fix-deployment-404
**Description:** Debug and fix the 404 error on Manus
**Steps:**
1. Verify build output exists in build/web
2. Check Manus dashboard for deployment logs
3. Verify domain configuration
4. Test deployment script
5. Redeploy if needed

### add-ai-quest-generation
**Description:** Implement AI-powered quest generation
**Steps:**
1. Create AIService in lib/services/ai_service.dart
2. Integrate OpenAI API or Anthropic API
3. Design quest generation prompt
4. Add Firebase Function as API proxy
5. Update UI to use AI-generated quests
6. Test quest quality

### implement-analytics-dashboard
**Description:** Build analytics insights dashboard
**Steps:**
1. Choose charting library (fl_chart or syncfusion)
2. Design dashboard layout
3. Create analytics provider
4. Fetch user stats from Firebase
5. Implement visualizations
6. Add filtering and date ranges

## Context for AI Tasks

When working on tasks:
- Check .claude/context.md for project details
- Follow existing architecture patterns
- Use Provider for state management
- Include proper error handling
- Write tests for new features
- Update documentation

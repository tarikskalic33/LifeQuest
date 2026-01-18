import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/quest_provider.dart';
import 'providers/mentor_provider.dart';
import 'providers/achievement_provider.dart';
import 'screens/onboarding.dart';
import 'screens/auth_screen.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Temporarily disable Firebase for testing
  // try {
  //   await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );
  //   print('Firebase initialized successfully');
  // } catch (e) {
  //   print('Error initializing Firebase: $e');
  // }
  
  runApp(const LifeQuestApp());
}

class LifeQuestApp extends StatelessWidget {
  const LifeQuestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QuestProvider()),
        ChangeNotifierProvider(create: (_) => MentorProvider()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
      ],
      child: MaterialApp(
        title: 'LifeQuest',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: const Color(0xFF0B1021),
          textTheme: const TextTheme(bodyMedium: TextStyle(color: Color(0xFFE6E9FF))),
        ),
        home: const AuthWrapper(),
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/auth': (context) => const AuthScreen(),
          '/main': (context) => const MainNavigation(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {

  @override
  Widget build(BuildContext context) {
    return Consumer4<AuthProvider, QuestProvider, MentorProvider, AchievementProvider>(
      builder: (context, authProvider, questProvider, mentorProvider, achievementProvider, child) {
        // Initialize auth state on first load
        if (!authProvider.isLoading && authProvider.user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            try {
              await authProvider.initAuth();
              if (!authProvider.isAuthenticated) {
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/onboarding');
                }
              } else {
                // Initialize all providers when user is authenticated
                await Future.wait([
                  questProvider.initQuests(),
                  mentorProvider.initMentor(),
                  achievementProvider.initAchievements(),
                ]);
                
                // Send daily interaction after mentor is initialized
                if (authProvider.user != null) {
                  await mentorProvider.sendDailyInteraction(authProvider.user!);
                }
              }
            } catch (e) {
              print('Error during app initialization: $e');
            }
          });
        }

        // Initialize providers if user is authenticated but they aren't loaded
        if (authProvider.isAuthenticated) {
          if (!questProvider.isLoading && questProvider.todaysQuests.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              questProvider.initQuests();
            });
          }

          if (!mentorProvider.isLoading && mentorProvider.messages.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              mentorProvider.initMentor().then((_) {
                mentorProvider.sendDailyInteraction(authProvider.user!);
              });
            });
          }

          if (!achievementProvider.isLoading && achievementProvider.achievements.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              achievementProvider.initAchievements();
            });
          }
        }

        if (authProvider.isLoading || 
            (authProvider.isAuthenticated && 
             (questProvider.isLoading || mentorProvider.isLoading || achievementProvider.isLoading))) {
          return const Scaffold(
            backgroundColor: Color(0xFF0B1021),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF7C5CFF)),
            ),
          );
        }

        if (authProvider.isAuthenticated) {
          return const MainNavigation();
        }

        return const OnboardingScreen();
      },
    );
  }
}


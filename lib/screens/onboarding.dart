import 'package:flutter/material.dart';
import 'auth_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1021),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, size: 96, color: Color(0xFF7C5CFF)),
              const SizedBox(height: 12),
              const Text('LifeQuest', style: TextStyle(color: Color(0xFFE6E9FF), fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Turn habits into an adventure', style: TextStyle(color: Color(0xFF9AA3C7))),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C5CFF)),
                onPressed: () {
                  print('🔥 BEGIN button clicked!');
                  try {
                    Navigator.pushReplacementNamed(context, '/auth');
                    print('✅ Navigation to /auth successful');
                  } catch (e) {
                    print('❌ Navigation error: $e');
                    // Fallback: Direct navigation
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthScreen()),
                    );
                  }
                },
                child: const Padding(padding: EdgeInsets.symmetric(horizontal:24, vertical:12), child: Text('Begin')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  // Initialize auth state
  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();

    _user = await _authService.getCurrentUser();
    
    _isLoading = false;
    notifyListeners();
  }

  // Register new user
  Future<bool> register(String email, String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.register(email, username, password);
      if (user != null) {
        _user = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Registration failed: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Login user
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        _user = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Login failed: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Update user
  Future<bool> updateUser(User updatedUser) async {
    final success = await _authService.updateUser(updatedUser);
    if (success) {
      _user = updatedUser;
      notifyListeners();
    }
    return success;
  }

  // Add XP and handle level ups
  Future<bool> addXP(int xp) async {
    if (_user == null) return false;

    final newXP = _user!.xp + xp;
    final newLevel = _calculateLevel(newXP);
    
    final updatedUser = _user!.copyWith(
      xp: newXP,
      level: newLevel,
    );

    return await updateUser(updatedUser);
  }

  // Update streak
  Future<bool> updateStreak(int streak) async {
    if (_user == null) return false;

    final updatedUser = _user!.copyWith(streak: streak);
    return await updateUser(updatedUser);
  }

  // Update stats
  Future<bool> updateStats(Map<String, int> newStats) async {
    if (_user == null) return false;

    final updatedUser = _user!.copyWith(stats: newStats);
    return await updateUser(updatedUser);
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  // Calculate level based on XP (made public for testing)
  int _calculateLevel(int xp) {
    // Simple level calculation: every 100 XP = 1 level
    return (xp / 100).floor() + 1;
  }
  
  // Public method for testing
  @visibleForTesting
  int calculateLevel(int xp) => _calculateLevel(xp);

  // Get XP needed for next level
  int getXPForNextLevel() {
    if (_user == null) return 100;
    final currentLevel = _user!.level;
    return (currentLevel * 100) - _user!.xp;
  }

  // Get progress to next level (0.0 to 1.0)
  double getLevelProgress() {
    if (_user == null) return 0.0;
    final currentLevelXP = (_user!.level - 1) * 100;
    final nextLevelXP = _user!.level * 100;
    final progress = (_user!.xp - currentLevelXP) / (nextLevelXP - currentLevelXP);
    return progress.clamp(0.0, 1.0);
  }
}


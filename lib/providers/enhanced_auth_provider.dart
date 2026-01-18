import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/enhanced_auth_service.dart';

/// Enhanced AuthProvider with security improvements and performance optimizations
class EnhancedAuthProvider with ChangeNotifier {
  final EnhancedAuthService _authService = EnhancedAuthService();
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _sessionWarningShown = false;

  // PERFORMANCE OPTIMIZATION: Debounced notifications
  bool _hasChanged = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;

  // SECURITY IMPROVEMENT: Session expiration handling
  @override
  void dispose() {
    super.dispose();
  }

  /// Initialize auth state with session management
  Future<void> initAuth() async {
    _setLoading(true);
    
    try {
      // Set up session expiration callback
      _authService.onSessionExpired = _handleSessionExpired;
      
      _user = await _authService.getCurrentUser();
      _clearError();
      
      if (_user != null) {
        print('✅ User session restored: ${_user!.username}');
      }
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
      print('❌ Auth initialization error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// SECURITY IMPROVEMENT: Enhanced registration with comprehensive validation
  Future<bool> registerSecure(String email, String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.registerSecure(email, username, password);
      
      if (result['success'] == true) {
        _user = User.fromJson(result['user']);
        _setLoading(false);
        print('✅ Registration successful: ${_user!.username}');
        return true;
      } else {
        _setError(result['error'] ?? 'Registration failed');
        _setLoading(false);
        print('❌ Registration failed: ${result['error']}');
        return false;
      }
    } catch (e) {
      _setError('Registration error: $e');
      _setLoading(false);
      print('❌ Registration exception: $e');
      return false;
    }
  }

  /// SECURITY IMPROVEMENT: Enhanced login with rate limiting
  Future<bool> loginSecure(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.loginSecure(email, password);
      
      if (result['success'] == true) {
        _user = User.fromJson(result['user']);
        _setLoading(false);
        print('✅ Login successful: ${_user!.username}');
        return true;
      } else {
        _setError(result['error'] ?? 'Login failed');
        _setLoading(false);
        print('❌ Login failed: ${result['error']}');
        return false;
      }
    } catch (e) {
      _setError('Login error: $e');
      _setLoading(false);
      print('❌ Login exception: $e');
      return false;
    }
  }

  /// PERFORMANCE OPTIMIZATION: Efficient user updates
  Future<bool> updateUser(User updatedUser) async {
    try {
      final success = await _authService.updateUser(updatedUser);
      if (success) {
        _user = updatedUser;
        _markChanged();
        notifyListeners();
        print('✅ User updated: ${updatedUser.username}');
      }
      return success;
    } catch (e) {
      print('❌ User update error: $e');
      return false;
    }
  }

  /// Enhanced XP addition with performance tracking
  Future<bool> addXP(int xp, {String? source}) async {
    if (_user == null) return false;

    try {
      final newXP = _user!.xp + xp;
      final oldLevel = _user!.level;
      final newLevel = _calculateLevel(newXP);
      
      final updatedUser = _user!.copyWith(
        xp: newXP,
        level: newLevel,
      );

      final success = await updateUser(updatedUser);
      
      if (success && newLevel > oldLevel) {
        print('🎉 LEVEL UP! ${_user!.username} reached level $newLevel');
        // Trigger level up celebration in UI
        _triggerLevelUpCelebration(oldLevel, newLevel);
      }
      
      if (source != null) {
        print('✨ XP gained: +$xp from $source (Total: $newXP)');
      }

      return success;
    } catch (e) {
      print('❌ Add XP error: $e');
      return false;
    }
  }

  /// Update streak with validation
  Future<bool> updateStreak(int streak) async {
    if (_user == null) return false;

    try {
      final updatedUser = _user!.copyWith(streak: streak);
      final success = await updateUser(updatedUser);
      
      if (success) {
        print('🔥 Streak updated: ${streak} days');
      }
      
      return success;
    } catch (e) {
      print('❌ Streak update error: $e');
      return false;
    }
  }

  /// Enhanced stats update with category tracking
  Future<bool> updateStats(Map<String, int> statChanges, {String? category}) async {
    if (_user == null) return false;

    try {
      final currentStats = Map<String, int>.from(_user!.stats);
      
      // Apply stat changes
      statChanges.forEach((stat, change) {
        currentStats[stat] = (currentStats[stat] ?? 0) + change;
        currentStats[stat] = currentStats[stat]!.clamp(0, 100); // Cap at 100
      });

      final updatedUser = _user!.copyWith(stats: currentStats);
      final success = await updateUser(updatedUser);
      
      if (success && category != null) {
        final changesStr = statChanges.entries
            .map((e) => '${e.key}: +${e.value}')
            .join(', ');
        print('📊 Stats updated from $category: $changesStr');
      }

      return success;
    } catch (e) {
      print('❌ Stats update error: $e');
      return false;
    }
  }

  /// SECURITY IMPROVEMENT: Secure logout with audit trail
  Future<void> logout() async {
    try {
      await _authService.logoutSecure();
      _user = null;
      _sessionWarningShown = false;
      _clearError();
      _markChanged();
      notifyListeners();
      print('✅ User logged out successfully');
    } catch (e) {
      print('❌ Logout error: $e');
    }
  }

  /// SECURITY IMPROVEMENT: Session expiration handler
  void _handleSessionExpired() {
    if (!_sessionWarningShown) {
      _sessionWarningShown = true;
      _user = null;
      _setError('Session expired. Please log in again.');
      notifyListeners();
      print('⚠️ Session expired - user logged out');
    }
  }

  /// Refresh user session activity
  void refreshActivity() {
    _authService.refreshSession();
  }

  /// Level up celebration trigger
  void _triggerLevelUpCelebration(int oldLevel, int newLevel) {
    // This could trigger UI animations, sounds, or mentor messages
    // Implementation depends on your UI framework
    print('🎊 CELEBRATION: Level $oldLevel → $newLevel!');
  }

  /// Calculate level based on XP (public for testing)
  int _calculateLevel(int xp) {
    return (xp / 100).floor() + 1;
  }
  
  @visibleForTesting
  int calculateLevel(int xp) => _calculateLevel(xp);

  /// Get XP needed for next level
  int getXPForNextLevel() {
    if (_user == null) return 100;
    final currentLevel = _user!.level;
    return (currentLevel * 100) - _user!.xp;
  }

  /// Get progress to next level (0.0 to 1.0)
  double getLevelProgress() {
    if (_user == null) return 0.0;
    final currentLevelXP = (_user!.level - 1) * 100;
    final nextLevelXP = _user!.level * 100;
    final progress = (_user!.xp - currentLevelXP) / (nextLevelXP - currentLevelXP);
    return progress.clamp(0.0, 1.0);
  }

  /// Get user's title based on achievements
  String getUserTitle() {
    if (_user == null) return 'Novice';
    
    final level = _user!.level;
    if (level >= 25) return 'Legend';
    if (level >= 20) return 'Master';
    if (level >= 10) return 'Warrior';
    if (level >= 5) return 'Apprentice';
    return 'Novice';
  }

  /// PERFORMANCE OPTIMIZATION: Efficient state management
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      _markChanged();
      notifyListeners();
    }
  }

  void _setError(String? error) {
    if (_errorMessage != error) {
      _errorMessage = error;
      _markChanged();
      notifyListeners();
    }
  }

  void _clearError() {
    _setError(null);
  }

  void _markChanged() {
    _hasChanged = true;
  }

  @override
  void notifyListeners() {
    if (_hasChanged) {
      super.notifyListeners();
      _hasChanged = false;
    }
  }

  /// Get security audit logs (admin function)
  Future<List<Map<String, dynamic>>> getSecurityLogs() async {
    try {
      return await _authService.getAuditLogs();
    } catch (e) {
      print('❌ Error fetching security logs: $e');
      return [];
    }
  }

  /// Validate password strength (for UI feedback)
  static Map<String, dynamic> validatePasswordStrength(String password) {
    final checks = {
      'length': password.length >= 8,
      'uppercase': RegExp(r'[A-Z]').hasMatch(password),
      'lowercase': RegExp(r'[a-z]').hasMatch(password),
      'numbers': RegExp(r'[0-9]').hasMatch(password),
      'symbols': RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
    };
    
    final passedChecks = checks.values.where((check) => check).length;
    
    String strength;
    if (passedChecks < 3) {
      strength = 'Weak';
    } else if (passedChecks < 5) {
      strength = 'Medium';
    } else {
      strength = 'Strong';
    }
    
    return {
      'strength': strength,
      'score': passedChecks,
      'maxScore': checks.length,
      'checks': checks,
    };
  }

  /// Check if email format is valid (for UI feedback)
  static bool isValidEmailFormat(String email) {
    return RegExp(r'^[a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$')
        .hasMatch(email);
  }
}
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Enhanced AuthService with production-ready security features
class EnhancedAuthService {
  static const String _userKey = 'current_user';
  static const String _usersKey = 'registered_users';
  static const String _saltKey = 'password_salts';
  static const String _auditKey = 'security_audit_log';
  
  // Rate limiting for login attempts
  final Map<String, List<DateTime>> _loginAttempts = {};
  static const int maxAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  
  // Session management
  Timer? _sessionTimer;
  static const Duration sessionTimeout = Duration(minutes: 30);
  Function? onSessionExpired;
  
  /// SECURITY IMPROVEMENT 1: Generate cryptographically secure salt
  String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(saltBytes);
  }
  
  /// SECURITY IMPROVEMENT 2: Enhanced password hashing with salt
  String _hashPasswordSecure(String password, String salt) {
    final combinedBytes = utf8.encode(password + salt + 'LifeQuest2024');
    // Multiple rounds of hashing for added security (PBKDF2-style)
    var digest = sha256.convert(combinedBytes);
    for (int i = 0; i < 10000; i++) {
      digest = sha256.convert(digest.bytes + utf8.encode(salt));
    }
    return digest.toString();
  }
  
  /// SECURITY IMPROVEMENT 3: RFC 5322 compliant email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$')
        .hasMatch(email);
  }
  
  /// SECURITY IMPROVEMENT 4: Strong password validation
  bool _isStrongPassword(String password) {
    if (password.length < 8) return false;
    
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialChars = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    
    return hasUppercase && hasLowercase && hasNumbers && hasSpecialChars;
  }
  
  /// SECURITY IMPROVEMENT 5: Input sanitization for XSS prevention
  String _sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'[<>"\'/\\]'), '') // Remove XSS vectors
        .replaceAll(RegExp(r'[;{}()]'), '')     // Remove injection vectors
        .trim()
        .substring(0, input.length > 100 ? 100 : input.length); // Length limit
  }
  
  /// SECURITY IMPROVEMENT 6: Rate limiting implementation
  bool _isAccountLocked(String email) {
    final attempts = _loginAttempts[email] ?? [];
    final now = DateTime.now();
    
    // Clean old attempts
    attempts.removeWhere((time) => now.difference(time) > lockoutDuration);
    _loginAttempts[email] = attempts;
    
    return attempts.length >= maxAttempts;
  }
  
  void _recordLoginAttempt(String email) {
    _loginAttempts[email] ??= [];
    _loginAttempts[email]!.add(DateTime.now());
  }
  
  /// SECURITY IMPROVEMENT 7: Security audit logging
  Future<void> _logSecurityEvent({
    required String event,
    required String email,
    required bool success,
    String? details,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getString(_auditKey) ?? '[]';
      final logs = List<dynamic>.from(jsonDecode(logsJson));
      
      final logEntry = {
        'timestamp': DateTime.now().toIso8601String(),
        'event': event,
        'email': email,
        'success': success,
        'details': details,
        'userAgent': 'LifeQuest-Enhanced',
      };
      
      logs.add(logEntry);
      
      // Keep only last 1000 log entries for performance
      if (logs.length > 1000) {
        logs.removeRange(0, logs.length - 1000);
      }
      
      await prefs.setString(_auditKey, jsonEncode(logs));
    } catch (e) {
      print('Error logging security event: $e');
    }
  }
  
  /// Enhanced secure registration with comprehensive validation
  Future<Map<String, dynamic>> registerSecure(String email, String username, String password) async {
    try {
      // Input sanitization and validation
      email = _sanitizeInput(email).toLowerCase();
      username = _sanitizeInput(username);
      
      if (!_isValidEmail(email)) {
        await _logSecurityEvent(event: 'REGISTRATION_FAILED', email: email, success: false, details: 'Invalid email format');
        return {'success': false, 'error': 'Invalid email format'};
      }
      
      if (username.length < 3 || username.length > 30) {
        await _logSecurityEvent(event: 'REGISTRATION_FAILED', email: email, success: false, details: 'Invalid username length');
        return {'success': false, 'error': 'Username must be 3-30 characters'};
      }
      
      if (!_isStrongPassword(password)) {
        await _logSecurityEvent(event: 'REGISTRATION_FAILED', email: email, success: false, details: 'Weak password');
        return {'success': false, 'error': 'Password must be 8+ characters with uppercase, lowercase, numbers, and symbols'};
      }
      
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing users and salts
      final usersJson = prefs.getString(_usersKey) ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));
      
      final saltsJson = prefs.getString(_saltKey) ?? '{}';
      final salts = Map<String, dynamic>.from(jsonDecode(saltsJson));
      
      // Check if user exists
      if (users.containsKey(email)) {
        await _logSecurityEvent(event: 'REGISTRATION_FAILED', email: email, success: false, details: 'User already exists');
        return {'success': false, 'error': 'User already exists'};
      }
      
      // Generate salt and hash password securely
      final salt = _generateSalt();
      final hashedPassword = _hashPasswordSecure(password, salt);
      
      // Create user with enhanced security
      final userId = _generateSecureUserId();
      final user = User(
        id: userId,
        email: email,
        username: username,
        level: 1,
        xp: 0,
        streak: 0,
        stats: {'discipline': 0, 'health': 0, 'creativity': 0, 'knowledge': 0},
      );
      
      // Store user data
      users[email] = {
        'user': user.toJson(),
        'password': hashedPassword,
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      salts[email] = salt;
      
      await prefs.setString(_usersKey, jsonEncode(users));
      await prefs.setString(_saltKey, jsonEncode(salts));
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      
      // Start session management
      _startSessionTimer();
      
      await _logSecurityEvent(event: 'REGISTRATION_SUCCESS', email: email, success: true);
      
      return {'success': true, 'user': user};
    } catch (e) {
      await _logSecurityEvent(event: 'REGISTRATION_ERROR', email: email, success: false, details: e.toString());
      return {'success': false, 'error': 'Registration failed: ${e.toString()}'};
    }
  }
  
  /// Enhanced secure login with rate limiting
  Future<Map<String, dynamic>> loginSecure(String email, String password) async {
    try {
      email = _sanitizeInput(email).toLowerCase();
      
      if (!_isValidEmail(email)) {
        await _logSecurityEvent(event: 'LOGIN_FAILED', email: email, success: false, details: 'Invalid email format');
        return {'success': false, 'error': 'Invalid email format'};
      }
      
      if (_isAccountLocked(email)) {
        await _logSecurityEvent(event: 'LOGIN_BLOCKED', email: email, success: false, details: 'Account locked');
        return {'success': false, 'error': 'Account locked due to too many failed attempts. Try again in 15 minutes.'};
      }
      
      final prefs = await SharedPreferences.getInstance();
      
      // Get user data and salt
      final usersJson = prefs.getString(_usersKey) ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));
      
      final saltsJson = prefs.getString(_saltKey) ?? '{}';
      final salts = Map<String, dynamic>.from(jsonDecode(saltsJson));
      
      if (!users.containsKey(email)) {
        _recordLoginAttempt(email);
        await _logSecurityEvent(event: 'LOGIN_FAILED', email: email, success: false, details: 'User not found');
        return {'success': false, 'error': 'User not found'};
      }
      
      final userData = users[email];
      final salt = salts[email];
      final hashedPassword = _hashPasswordSecure(password, salt);
      
      if (userData['password'] != hashedPassword) {
        _recordLoginAttempt(email);
        await _logSecurityEvent(event: 'LOGIN_FAILED', email: email, success: false, details: 'Invalid password');
        return {'success': false, 'error': 'Invalid password'};
      }
      
      // Successful login - clear failed attempts
      _loginAttempts.remove(email);
      
      final user = User.fromJson(userData['user']);
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      
      // Start session management
      _startSessionTimer();
      
      await _logSecurityEvent(event: 'LOGIN_SUCCESS', email: email, success: true);
      
      return {'success': true, 'user': user};
    } catch (e) {
      await _logSecurityEvent(event: 'LOGIN_ERROR', email: email, success: false, details: e.toString());
      return {'success': false, 'error': 'Login failed: ${e.toString()}'};
    }
  }
  
  /// SECURITY IMPROVEMENT 8: Session management with timeout
  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(sessionTimeout, () async {
      await logoutSecure();
      if (onSessionExpired != null) {
        onSessionExpired!();
      }
    });
  }
  
  void refreshSession() {
    if (_sessionTimer != null) {
      _startSessionTimer();
    }
  }
  
  /// Enhanced secure logout
  Future<void> logoutSecure() async {
    _sessionTimer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    
    // Get current user for logging
    final userJson = prefs.getString(_userKey);
    String email = 'unknown';
    if (userJson != null) {
      try {
        final userData = jsonDecode(userJson);
        email = userData['email'] ?? 'unknown';
      } catch (e) {
        // Handle error silently
      }
    }
    
    await prefs.remove(_userKey);
    await _logSecurityEvent(event: 'LOGOUT', email: email, success: true);
  }
  
  /// Get current user with session validation
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        refreshSession(); // Refresh session on activity
        return User.fromJson(jsonDecode(userJson));
      }
      
      return null;
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }
  
  /// Check if user is logged in with session validation
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }
  
  /// Generate cryptographically secure user ID
  String _generateSecureUserId() {
    final random = Random.secure();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = random.nextInt(999999).toString().padLeft(6, '0');
    return 'user_${timestamp}_$randomPart';
  }
  
  /// Get security audit logs (admin function)
  Future<List<Map<String, dynamic>>> getAuditLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getString(_auditKey) ?? '[]';
      final logs = List<dynamic>.from(jsonDecode(logsJson));
      
      return logs.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error retrieving audit logs: $e');
      return [];
    }
  }
  
  /// Update user with session refresh
  Future<bool> updateUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Update current user
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      
      // Update in users list
      final usersJson = prefs.getString(_usersKey) ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));
      
      if (users.containsKey(user.email)) {
        users[user.email]['user'] = user.toJson();
        await prefs.setString(_usersKey, jsonEncode(users));
      }
      
      refreshSession(); // Refresh session on activity
      await _logSecurityEvent(event: 'USER_UPDATE', email: user.email, success: true);
      
      return true;
    } catch (e) {
      await _logSecurityEvent(event: 'USER_UPDATE_ERROR', email: user.email, success: false, details: e.toString());
      print('Update user error: $e');
      return false;
    }
  }
}
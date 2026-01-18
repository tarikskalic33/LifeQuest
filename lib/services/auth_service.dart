import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _usersKey = 'registered_users';

  // Simulate user registration
  Future<User?> register(String email, String username, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing users
      final usersJson = prefs.getString(_usersKey) ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));
      
      // Check if user already exists
      if (users.containsKey(email)) {
        throw Exception('User already exists');
      }
      
      // Create new user
      final userId = _generateUserId();
      final hashedPassword = _hashPassword(password);
      
      final user = User(
        id: userId,
        email: email,
        username: username,
      );
      
      // Store user data
      users[email] = {
        'user': user.toJson(),
        'password': hashedPassword,
      };
      
      await prefs.setString(_usersKey, jsonEncode(users));
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      
      return user;
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  // Simulate user login
  Future<User?> login(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing users
      final usersJson = prefs.getString(_usersKey) ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));
      
      // Check if user exists
      if (!users.containsKey(email)) {
        throw Exception('User not found');
      }
      
      final userData = users[email];
      final hashedPassword = _hashPassword(password);
      
      // Verify password
      if (userData['password'] != hashedPassword) {
        throw Exception('Invalid password');
      }
      
      final user = User.fromJson(userData['user']);
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      
      return user;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        return User.fromJson(jsonDecode(userJson));
      }
      
      return null;
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }

  // Update user data
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
      
      return true;
    } catch (e) {
      print('Update user error: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  // Helper methods
  String _generateUserId() {
    final random = Random();
    return 'user_${random.nextInt(999999).toString().padLeft(6, '0')}';
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}


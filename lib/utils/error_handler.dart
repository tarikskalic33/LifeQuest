import 'package:flutter/material.dart';

class ErrorHandler {
  static void showError(BuildContext context, String message, {String? title}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? 'Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static void showSnackbar(BuildContext context, String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static String getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}

// Custom exception classes
class AppException implements Exception {
  final String message;
  final String? code;
  
  AppException(this.message, {this.code});
  
  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message, code: 'network-error');
}

class AuthException extends AppException {
  AuthException(String message, String code) : super(message, code: code);
}

class DataException extends AppException {
  DataException(String message) : super(message, code: 'data-error');
}
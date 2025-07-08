import 'package:firebase_auth/firebase_auth.dart';

class AuthExceptionHandler {
  static String getMessageFromErrorCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'weak-password':
        return 'Password is too weak. Try adding numbers or symbols.';
      case 'operation-not-allowed':
        return 'Operation not allowed. Please contact support.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  static String getErrorMessageFromException(Exception exception) {
    if (exception is FirebaseAuthException) {
      return getMessageFromErrorCode(exception.code);
    }
    return 'An error occurred. Please try again.';
  }
}

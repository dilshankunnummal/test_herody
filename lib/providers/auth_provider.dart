import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_app/common/auth_exception_handler.dart';
import 'package:to_do_app/widgets/logout_confirmation_dialog.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;

  String? get token => _token;
  String? get userId => _userId;
  bool get isAuth => _token != null;

  AuthProvider() {
    _tryAutoLogin();
  }

  Future<String?> signup(String email, String password, BuildContext context) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      _token = await userCredential.user?.getIdToken();
      _userId = userCredential.user?.uid;
      notifyListeners();
      await _saveToPrefs();
      return null;
    } on FirebaseAuthException catch (e) {
      final errorMessage = AuthExceptionHandler.getMessageFromErrorCode(e.code);
      _showError(context, errorMessage);
      return errorMessage;
    } catch (_) {
      _showError(context, 'Something went wrong. Please try again.');
      return 'Something went wrong. Please try again.';
    }
  }

  Future<String?> login(String email, String password, BuildContext context) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      _token = await userCredential.user?.getIdToken();
      _userId = userCredential.user?.uid;
      notifyListeners();
      await _saveToPrefs();
      return null;
    } on FirebaseAuthException catch (e) {
      final errorMessage = AuthExceptionHandler.getMessageFromErrorCode(e.code);
      _showError(context, errorMessage);
      return errorMessage;
    } catch (_) {
      _showError(context, 'Something went wrong. Please try again.');
      return 'Something went wrong. Please try again.';
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _token = null;
    _userId = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token ?? '');
    await prefs.setString('userId', _userId ?? '');
  }

  Future<void> _tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');
    if (token != null && token.isNotEmpty && userId != null && userId.isNotEmpty) {
      _token = token;
      _userId = userId;
      notifyListeners();
    }
  }

  Future<void> confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => const LogoutConfirmationDialog(),
    );

    if (shouldLogout == true) {
      await logout();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {

  // =====================================================
  // SERVICE
  // =====================================================

  final AuthService _authService =
      AuthService();

  // =====================================================
  // STATE
  // =====================================================

  bool _isLoading = false;

  String? _errorMessage;

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  User? get currentUser =>
      _authService.currentUser;

  Stream<User?> get authStateChanges =>
      _authService.authStateChanges;

  // =====================================================
  // GOOGLE LOGIN
  // =====================================================

  Future<bool> signInWithGoogle() async {

    try {

      _isLoading = true;

      _errorMessage = null;

      notifyListeners();

      await _authService.signInWithGoogle();

      return true;

    } catch (e) {

      _errorMessage = e.toString();

      return false;

    } finally {

      _isLoading = false;

      notifyListeners();
    }
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<void> signOut() async {

    await _authService.signOut();

    notifyListeners();
  }
}